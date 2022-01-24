# Utility class for getting numerical data from showq
#
# @author Brian L. McMichael
# @version 0.1.0
class MoabShowqClient

  attr_reader :active_jobs, :eligible_jobs, :blocked_jobs, :procs_used, :procs_avail, :nodes_used, :nodes_avail, :error_message, :dashboard_url, :cluster_id, :cluster_title, :friendly_error_message

  # Set the object to the server.
  #
  # @param [OodAppkit::Cluster]
  #
  # @return [MoabShowqClient] self
  def initialize(cluster)
    @server = cluster.custom_config[:moab]
    if cluster.custom_config.key?(:grafana)
      @dashboard_url = "/clusters/#{cluster.id}/grafana"
    elsif cluster.custom_config.key?(:ganglia)
      @dashboard_url = "/clusters/#{cluster.id}/hour/report_moab_nodes"
    end
    @cluster_id = cluster.id
    @cluster_title = cluster.metadata.title || cluster.id.titleize
    @job_scheduler = cluster.job_config[:adapter]
    self
  end

  def job_scheduler_name
    return @job_scheduler
  end

  def setup
    doc = REXML::Document.new(showq_summary_xml)
    self.active_jobs = doc.root.elements["queue[@option='active']"].attributes["count"].to_i
    self.eligible_jobs = doc.root.elements["queue[@option='eligible']"].attributes["count"].to_i
    self.blocked_jobs = doc.root.elements["queue[@option='blocked']"].attributes["count"].to_i

    self.procs_used = doc.root.elements["cluster"].attributes["LocalAllocProcs"].to_i
    self.procs_avail = doc.root.elements["cluster"].attributes["LocalUpProcs"].to_i
    self.nodes_used = doc.root.elements["cluster"].attributes["LocalActiveNodes"].to_i 
    self.nodes_avail = doc.root.elements["cluster"].attributes["LocalUpNodes"].to_i
    self
  rescue => e
    # TODO Add logging and a flash message that was removed from the controller
    MoabShowqClientNotAvailable.new(cluster_id, cluster_title, e)
  end
  
  # Total nodes available
  #
  # @return [Integer] the total number of nodes up
  def available_nodes
    nodes_avail
  end

  # Total number of processors
  #
  # @return [Integer] the total number of processors
  def available_procs
    procs_avail
  end

  # Return moab lib pathname
  def moab_lib
    Pathname.new(@server['lib'].to_s)
  end
  
  # Return moab bin pathname
  def moab_bin
    Pathname.new(@server['bin'].to_s)
  end
  
  # Return moab home directory pathname
  def moab_home 
    Pathname.new(@server['homedir'].to_s)
  end

  # Return 'showq -s --xml' output in xml format
  def showq_summary_xml
    cmd = moab_bin.join("showq").to_s
    args = ["-s", "--host=#{@server['host']}", "--xml"]
    env= {
        "LD_LIBRARY_PATH" => "#{moab_lib}:#{ENV['LD_LIBRARY_PATH']}",
        "MOABHOMEDIR" => "#{moab_home}"
     }.merge(env.to_h)
    o, e, s = Open3.capture3(env, cmd, *args)
    s.success? ? o : raise(CommandFailed, e)
  rescue Errno::ENOENT => e
    raise InvalidCommand, e.message
  end
  
  # Return the active jobs as percent of available jobs
  #
  # @return [Float] The percentage active as float
  def active_percent
    (active_jobs.to_f / available_jobs.to_f) * 100
  end

  # Return the eligible jobs as percent of available jobs
  #
  # @return [Float] The percentage eligible as float
  def eligible_percent
    (eligible_jobs.to_f / available_jobs.to_f) * 100
  end

  # Total active + eligible
  #
  # @return [Integer] the total number of active/eligible jobs
  def available_jobs
    active_jobs + eligible_jobs
  end

  # Return the processor usage as percent
  #
  # @return [Float] The number of processors used as float
  def procs_percent
    (procs_used.to_f / procs_avail.to_f) * 100
  end

  # Return the node usage as percent
  #
  # @return [Float] The number of nodes used as float
  def nodes_percent
    (nodes_used.to_f / nodes_avail.to_f) * 100
  end
  
  # Return cluster title + error message
  #
  # @return nil or constructed error message
  def friendly_error_message
    error_message.nil? ? nil : "#{cluster_title} Cluster: #{error_message}"
  end

  private

    attr_writer :active_jobs, :eligible_jobs, :blocked_jobs, :procs_used, :procs_avail, :nodes_used, :nodes_avail,:error_message, :cluster_id, :cluster_title

    # assign 0 if the input is nil or empty
    def assign(match_string)
      !match_string.blank? ? match_string : 0
    end

end
