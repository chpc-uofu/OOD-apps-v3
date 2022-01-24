require 'sinatra'
require 'ood_core'
require 'rexml/document'
require 'open3'
require 'pathname'

require_relative 'lib/moab_showq_client'
require_relative 'lib/gpu_cluster_status'
require_relative 'lib/gpu_cluster_status_not_available'
require_relative 'lib/moab_showq_client_not_available'
require_relative 'lib/ganglia'
require_relative 'lib/gpu_cluster_status_slurm'
require_relative 'lib/slurm_squeue_client'

# more details see ood_appkit lib/ood_appkit/configuration.rb
begin
# CLUSTERS = OodCore::Clusters.new(OodCore::Clusters.load_file(ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d').select(&:job_allow?)
#   .select { |c| c.custom_config[:moab] || c.job_config[:adapter] == "slurm" }
#   .reject { |c| c.metadata.hidden }
# )
 CLUSTERS = OodCore::Clusters.new(OodCore::Clusters.load_file(ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d').select(&:job_allow?) 
   .select { |c| c.custom_config[:moab] || c.job_config[:adapter] == "slurm" } 
   .reject { |c| c.metadata.hidden } 
   .sort_by {|cluster| [cluster.metadata.priority.to_i, cluster.id]}
 ) 

rescue OodCore::ConfigurationNotFound
  CLUSTERS = OodCore::Clusters.new([])
end

helpers do
  def dashboard_title
    ENV['OOD_DASHBOARD_TITLE'] || "Open OnDemand"
  end

  def dashboard_url
    "/pun/sys/dashboard/"
  end

  def public_url
     ENV['OOD_PUBLIC_URL'] || "/public"
  end

  def graph_time
      {:hour => 'Hour', :two_hours => '2 Hours', :four_hours => '4 Hours', :day => 'Day', :week => 'Week', :month => 'Month', :year => 'Year'}
  end
  
  def graph_types
    {:report_moab_nodes => 'Nodes', :report_moab_jobs => 'Jobs', :report_load => 'Load', :report_network => 'Network'}
  end

  def app_version
    @app_version ||= (version_from_file(settings.root) || version_from_git(settings.root) || "").strip
  end

  def version_from_file(dir)
    file = Pathname.new(dir).join("VERSION")
    file.read if file.file?
  end

  def version_from_git(dir)
    Dir.chdir(Pathname.new(dir)) do
      version = `git describe --always --tags 2>/dev/null`
      version.to_s.strip.empty? ? nil : version
    end
  rescue Errno::ENOENT
    nil
  end
end

get '/clusters/:id/:time/:type' do
  @id=params[:id].to_sym
  graph_time.keys.include?(params[:time].to_sym) ? @time=params[:time].to_sym : @time=:hour
  graph_types.keys.include?(params[:type].to_sym) ? @type=params[:type].to_sym : @type=:report_moab_nodes
  cluster = CLUSTERS[@id]
  if cluster.nil? || ! cluster.custom_config.key?(:ganglia)
    raise Sinatra::NotFound
  end
  @ganglia = Ganglia.new(cluster).send(@time)
  erb :system_status
end

get '/clusters/:id/grafana' do
  @id = params[:id].to_sym
  cluster = CLUSTERS[@id]
  if cluster.nil? || ! cluster.custom_config.key?(:grafana)
    raise Sinatra::NotFound
  end
  grafana = cluster.custom_config[:grafana]
  dashboard_url = "#{grafana['dashboard']['uid']}/#{grafana['dashboard']['name']}"
  theme = grafana['theme'] || 'light'
  grafana_url = "#{grafana['host']}/d/#{dashboard_url}?orgId=#{grafana['orgId']}&theme=#{theme}&var-cluster=#{grafana.fetch('cluster_override', @id)}"
  redirect(grafana_url)
end

# redirect to /clusters/:id/hour/report_moab_nodes page
get '/clusters/:id*' do
  redirect(to("/clusters/#{params[:id]}/hour/report_moab_nodes"))
end

# redirect to /clusters page
get '/' do
  redirect(to('/clusters'))
end

get '/clusters' do
  @clusters = CLUSTERS.map { |cluster|
    if cluster.custom_config[:moab]
      MoabShowqClient.new(cluster).setup
    else
      SlurmSqueueClient.new(cluster).setup
    end
  }
  @gpustats = CLUSTERS.map { |cluster|
    if cluster.custom_config[:moab]
      GPUClusterStatus.new(cluster)
    else
      GPUClusterStatusSlurm.new(cluster)
    end
  }
  @error_messages = (@clusters.map{ |cluster| cluster.friendly_error_message}).compact

  erb :index
end

# 404 not found
not_found do
  erb :'404'
end

# 500 internal server error
error do
  erb :'500'
end
