class SlurmSqueueClient

  attr_reader :active_jobs, :eligible_jobs, :blocked_jobs, :procs_used, :procs_avail, :nodes_used, :nodes_avail, :error_message, :dashboard_url, :cluster_id, :cluster_title, :friendly_error_message, :owner_nodes_used, :owner_nodes_avail, :owner_nodes_idle, :nodes_idle, :nodes_other, :procs_idle, :procs_other, :owner_procs_used, :owner_procs_idle, :owner_procs_avail, :owner_procs_other, :owner_nodes_other

  # Set the object to the server.
  #
  # @param [OodAppkit::Cluster]
  #
  # @return [SlurmSqueueClient] self
  def initialize(cluster)
    @bin = cluster.job_config[:bin]
  
    if cluster.custom_config.key?(:grafana)
      @dashboard_url = "/clusters/#{cluster.id}/grafana"
    elsif cluster.custom_config.key?(:ganglia)
      @dashboard_url = "/clusters/#{cluster.id}/hour/report_moab_nodes"
    end
  
    @cluster_id = cluster.id
#    File.write("/uufs/chpc.utah.edu/common/home/u0101881/ondemand/dev/osc-systemstatus/log.txt", "#{cluster.id}\n#{cluster.metadata.title}\n", mode: "a")
    @cluster_title = cluster.metadata.title || cluster.id.titleize
    @job_scheduler = cluster.job_config[:adapter]

    self
  end

  def squeue_cmd
    File.join(@bin, 'squeue')
  end

  def sinfo_cmd
    File.join(@bin, 'sinfo')
  end

  # Return job scheduler type from config
  def job_scheduler_name
    @job_scheduler
  end

  # Get pending jobs
  def squeue_jobs_pending
    return @squeue_jobs_pending if defined?(@squeue_jobs_pending)

    o, e, s = Open3.capture3({}, squeue_cmd, '-h', '--all', '--states=PENDING')
    
    s.success? ? @squeue_jobs_pending = o : raise(CommandFailed, e)
  end

  # Get running jobs
  def squeue_jobs_running
    return @squeue_jobs_running if defined?(@squeue_jobs_running)

    o, e, s = Open3.capture3({}, squeue_cmd, '-h', '--all', '--states=RUNNING')
    
    s.success? ? @squeue_jobs_running = o : raise(CommandFailed, e)
  end

  # Get cluster info (node count, core count, etc.)
  def sinfo
    return @sinfo if defined?(@sinfo)

    o, e, s = Open3.capture3({}, sinfo_cmd, "-p", cluster_title.downcase,"-h","-o=\"%C/%F/%D\"")
#    File.write("/uufs/chpc.utah.edu/common/home/u0101881/ondemand/dev/osc-systemstatus/log.txt", "#{cluster_title.downcase}", mode: "a")
    
    s.success? ? @sinfo = o : raise(CommandFailed, e)
  end

  def sinfo_owner
    return @sinfo_owner if defined?(@sinfo_owner)
    o, e, s = Open3.capture3({}, sinfo_cmd, *["-p",cluster_title.downcase+"-guest","-h","-o=\"%C/%F/%D\""])
#    File.write("/uufs/chpc.utah.edu/common/home/u0101881/ondemand/dev/osc-systemstatus/log.txt", "#{o}\n", mode: "a")
# based on the above the "o" is correct
    
    s.success? ? @sinfo_owner = o : raise(CommandFailed, e)
  end

  # Return length of GRES field from SLURM
  # @return [Integer] gres length
  def gres_length
    return @gres_length if defined?(@gres_length)

    o, e, s = Open3.capture3("#{sinfo_cmd} -o '%G' | awk '{ print length }' | sort -n | tail -1")

    if s.success?
      @gres_length = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving GRES lsength from SLURM. Exit status #{s.exitstatus}: #{e.to_s}"
      0
    end
  end

  # Parse and return total number of GPUs in a SLURM cluster
  # @return [Integer] number of GPUs
  def gpus
    return @available_gpus if defined?(@available_gpus)

    o, e, s = Open3.capture3("#{sinfo_cmd} -N -h -p #{cluster_title.downcase}-gpu --Format='nodehost,gres' | cut -d : -f 3 | awk 'BEGIN { FS = \"(\" } ; {num_gpus += $1} END {print num_gpus}'")

#    File.write("/uufs/chpc.utah.edu/common/home/u0101881/ondemand/dev/osc-systemstatus/log.txt", "#{o}\n#{e}\n#{s}\n", mode: "a")
    if s.success?
      @available_gpus = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving available GPUs. Exit status #{s.exitstatus}: #{e.to_s}"
      0
    end
  end

  # Return number of used GPUs
  # 
  # @return [Integer] number of GPUs with status used
  def gpus_used
    return @gpus_used if defined?(@gpus_used)

    o, e, s = Open3.capture3("#{sinfo_cmd} -p #{cluster_title.downcase}-gpu -h --Node --Format='nodehost,gresused' | cut -d : -f 3 | awk 'BEGIN { FS = \"(\" } ; {num_gpus += $1} END {print num_gpus}'")

    if s.success?
      @gpus_used = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving free GPU nodes. Exit status #{s.exitstatus}: #{o.to_s}"
      0
    end
  end

  # Parse and return total number of owner GPUs in a SLURM cluster
  # @return [Integer] number of owner GPUs
  def owner_gpus
    return @owner_available_gpus if defined?(@owner_available_gpus)

    o, e, s = Open3.capture3("#{sinfo_cmd} -N -h -p #{cluster_title.downcase}-gpu-guest --Format='nodehost,gres' | cut -d : -f 3 | awk 'BEGIN { FS = \"(\" } ; {num_gpus += $1} END {print num_gpus}'")

#    File.write("/uufs/chpc.utah.edu/common/home/u0101881/ondemand/dev/osc-systemstatus/log.txt", "#{o}\n#{e}\n#{s}\n", mode: "a")
    if s.success?
      @owner_available_gpus = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving available GPUs. Exit status #{s.exitstatus}: #{e.to_s}"
      0
    end
  end

  # Return number of used owner GPUs
  # 
  # @return [Integer] number of owner GPUs with status used
  def owner_gpus_used
    return @owner_gpus_used if defined?(@owner_gpus_used)

    o, e, s = Open3.capture3("#{sinfo_cmd} -p #{cluster_title.downcase}-gpu-guest -h --Node --Format='nodehost,gresused' | cut -d : -f 3 | awk 'BEGIN { FS = \"(\" } ; {num_gpus += $1} END {print num_gpus}'")

    if s.success?
      @owner_gpus_used = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving free GPU nodes. Exit status #{s.exitstatus}: #{o.to_s}"
      0
    end
  end
  # Parse and return total number of GPU nodes in a SLURM cluster
  # @return [Integer] number of GPU nodes
  def gpu_nodes
    return @available_gpu_nodes if defined?(@available_gpu_nodes)

    o, e, s = Open3.capture3("#{sinfo_cmd} -N -h -p #{cluster_title.downcase}-gpu --Format='nodehost,gres:#{gres_length}' | uniq | grep gpu: | wc -l")

#    File.write("/uufs/chpc.utah.edu/common/home/u0101881/ondemand/dev/osc-systemstatus/log.txt", "#{o}\n#{e}\n#{s}\n", mode: "a")
    if s.success?
      @available_gpu_nodes = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving available GPU nodes. Exit status #{s.exitstatus}: #{e.to_s}"
      0
    end
  end

  # Return number of GPU nodes with mixed or idle status
  # 
  # @return [Integer] number of GPU nodes with status mixed (some CPUs allocated)
  def gpu_nodes_free
    return @gpu_nodes_free if defined?(@gpu_nodes_free)

    o, e, s = Open3.capture3("#{sinfo_cmd} -p #{cluster_title.downcase}-gpu -h --Node --Format='nodehost,gres:#{gres_length},statelong' | uniq | grep gpu: | egrep 'idle' | wc -l")

    if s.success?
      @gpu_nodes_free = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving free GPU nodes. Exit status #{s.exitstatus}: #{o.to_s}"
      0
    end
  end

  # Return number of GPU nodes in use
  # 
  # @return [Integer] gpu nodes in use
  def gpu_nodes_active
    return @gpu_nodes_active if defined?(@gpu_nodes_active)

    @gpu_nodes_active = available_gpu_nodes - gpu_nodes_free
  end

  # Returns percentage of GPU nodes that are available
  # 
  # @return [Float] percentage gpu nodes available
  def gpu_nodes_available_percent
    gpu_nodes > 0 ? ((gpu_nodes - gpu_nodes_free).to_f / gpu_nodes.to_f) * 100 : 0
  end

  # Returns percentage of GPUs that are available
  # 
  # @return [Float] percentage gpus available
  def gpus_available_percent
    gpus > 0 ? ((gpus_used).to_f / gpus.to_f) * 100 : 0
  end

  # Returns percentage of owner GPUs that are available
  # 
  # @return [Float] percentage gpus available
  def owner_gpus_available_percent
    owner_gpus > 0 ? ((owner_gpus_used).to_f / owner_gpus.to_f) * 100 : 0
  end

  # Parse and return total number owner of GPU nodes in a SLURM cluster
  # @return [Integer] number of GPU nodes
  def owner_gpu_nodes
    return @owner_available_gpu_nodes if defined?(@owner_available_gpu_nodes)

    o, e, s = Open3.capture3("#{sinfo_cmd} -N -h -p #{cluster_title.downcase}-gpu-guest --Format='nodehost,gres:#{gres_length}' | uniq | grep gpu: | wc -l")

#    File.write("/uufs/chpc.utah.edu/common/home/u0101881/ondemand/dev/osc-systemstatus/log.txt", "#{o}\n#{e}\n#{s}\n", mode: "a")
    if s.success?
      @owner_available_gpu_nodes = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving available GPU nodes. Exit status #{s.exitstatus}: #{e.to_s}"
      0
    end
  end

  # Return number of GPU nodes with mixed or idle status
  # 
  # @return [Integer] number of GPU nodes with status mixed (some CPUs allocated)
  def owner_gpu_nodes_free
    return @owner_gpu_nodes_free if defined?(@owner_gpu_nodes_free)

    o, e, s = Open3.capture3("#{sinfo_cmd} -p #{cluster_title.downcase}-gpu-guest -h --Node --Format='nodehost,gres:#{gres_length},statelong' | uniq | grep gpu: | egrep 'idle' | wc -l")

    if s.success?
      @owner_gpu_nodes_free = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving free GPU nodes. Exit status #{s.exitstatus}: #{o.to_s}"
      0
    end
  end

  # Return number of GPU nodes in use
  # 
  # @return [Integer] gpu nodes in use
  def owner_gpu_nodes_active
    return @owner_gpu_nodes_active if defined?(@owner_gpu_nodes_active)

    @owner_gpu_nodes_active = owner_available_gpu_nodes - owner_gpu_nodes_free
  end

  # Returns percentage of GPU nodes that are available
  # 
  # @return [Float] percentage gpu nodes available
  def owner_gpu_nodes_available_percent
    owner_gpu_nodes > 0 ? ((owner_gpu_nodes - owner_gpu_nodes_free).to_f / owner_gpu_nodes.to_f) * 100 : 0
  end

  # Number of pending jobs requesting GPUs
  # 
  # @return [Integer] number of pending jobs requesting GPUs
  def gpu_jobs_pending
    return @gpu_jobs_pending if defined?(@gpu_jobs_pending)

    o, e, s = Open3.capture3("#{squeue_cmd} --states=PENDING -O 'jobid,tres-pefr-job:#{gres_length},tres-per-node:#{gres_length},tres-per-socket:#{gres_length},tres-per-task:#{gres_length}' -h | grep gpu: | wc -l")

    if s.success?
      @gpu_jobs_pending = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving pending jobs requesting GPUs. Exit status #{s.exitstatus}: #{o.to_s}"
      0
    end
  end

  # Number of running jobs requesting GPUs
  # 
  # @return [Integer] number of running jobs requesting GPUs
  def gpu_jobs_running
    return @gpu_jobs_running if defined?(@gpu_jobs_running)

    o, e, s = Open3.capture3("#{squeue_cmd} --states=RUNNING -O 'jobid,tres-pefr-job:#{gres_length},tres-per-node:#{gres_length},tres-per-socket:#{gres_length},tres-per-task:#{gres_length}' -h | grep gpu: | wc -l")

    if s.success?
      @gpu_jobs_running = o.to_i
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving pending jobs requesting GPUs. Exit status #{s.exitstatus}: #{o.to_s}"
      0
    end
  end

  def cluster_info
    sinfo_out               = sinfo.split('/')
    running_jobs            = 0
    pending_jobs            = 0
    squeue_jobs_running.split("\n").each{ |line| running_jobs += 1 }
    squeue_jobs_pending.split("\n").each{ |line| pending_jobs += 1 }

    sinfo_out.each{ |line|
      # Strip extra chars returned by Slurm
      line.gsub!('"', '')
      line.gsub!('=', '')
    }
    sinfo_owner_out               = sinfo_owner.split('/')
 
    sinfo_owner_out.each{ |line|
      # Strip extra chars returned by Slurm
      line.gsub!('"', '')
      line.gsub!('=', '')
    }

    {
      procs_used:     sinfo_out[0].to_i,
      procs_idle:     sinfo_out[1].to_i,
      procs_other:    sinfo_out[2].to_i,
      procs_avail:    sinfo_out[3].to_i,
      nodes_used:     sinfo_out[4].to_i,
      nodes_idle:     sinfo_out[5].to_i,
      nodes_other:    sinfo_out[6].to_i,
      nodes_avail:    sinfo_out[7].to_i,
      available_jobs: running_jobs.to_i,
      pending_jobs:   pending_jobs.to_i,
      owner_procs_used:     sinfo_owner_out[0].to_i,
      owner_procs_idle:     sinfo_owner_out[1].to_i,
      owner_procs_other:    sinfo_owner_out[2].to_i,
      owner_procs_avail:    sinfo_owner_out[3].to_i,
      owner_nodes_used:     sinfo_owner_out[4].to_i,
      owner_nodes_idle:     sinfo_owner_out[5].to_i,
      owner_nodes_other:    sinfo_owner_out[6].to_i,
      owner_nodes_avail:    sinfo_owner_out[7].to_i,
    }
#
#   {
#   }
  end

  def setup
    self.active_jobs   = cluster_info[:available_jobs]
    self.eligible_jobs = cluster_info[:pending_jobs]
    self.blocked_jobs  = cluster_info[:blocked_jobs]

    self.procs_used    = cluster_info[:procs_used]
    self.procs_avail   = cluster_info[:procs_avail]
    self.procs_idle    = cluster_info[:procs_idle]
    self.procs_other   = cluster_info[:procs_other]
    self.nodes_used    = cluster_info[:nodes_used]
    self.nodes_idle    = cluster_info[:nodes_idle]
    self.nodes_avail   = cluster_info[:nodes_avail]
    self.nodes_other   = cluster_info[:nodes_other]

    self.owner_nodes_used = cluster_info[:owner_nodes_used]
    self.owner_nodes_idle = cluster_info[:owner_nodes_idle]
    self.owner_nodes_avail = cluster_info[:owner_nodes_avail]
    self.owner_nodes_other = cluster_info[:owner_nodes_other]
    self.owner_procs_used = cluster_info[:owner_procs_used]
    self.owner_procs_idle = cluster_info[:owner_procs_idle]
    self.owner_procs_avail = cluster_info[:owner_procs_avail]
    self.owner_procs_other = cluster_info[:owner_procs_other]
#    File.write("/uufs/chpc.utah.edu/common/home/u0101881/ondemand/dev/osc-systemstatus/log.txt", "#{cluster_info[:owner_nodes_used]}\n", mode: "a")

    self
  # rescue => e
    # TODO Add logging and a flash message that was removed from the controller
    # SlurmSqueueClientNotAvailable.new(cluster_id, cluster_title, e)
  end

  # Return the active jobs as percent of available jobs
  #
  # @return [Float] The percentage active as float
  def active_percent
    available_jobs > 0 ? (active_jobs.to_f / available_jobs.to_f) * 100 : 0
  end

  # Return the eligible jobs as percent of available jobs
  #
  # @return [Float] The percentage eligible as float
  def eligible_percent
    available_jobs > 0 ? (eligible_jobs.to_f / available_jobs.to_f) * 100 : 0
  end

  # Total active + eligible
  #
  # @return [Integer] the total number of active/eligible jobs
  def available_jobs
    active_jobs + eligible_jobs
  end 

  # Total nodes available (idle) and total nodes used
  #
  # @return [Integer] the total number of idle/used jobs
  def available_nodes
    nodes_avail
  end

  # Total number of available and in use procs
  #
  # @return [Integer] the total number of procs 
  def available_procs
    procs_avail
  end

  # Return the processor usage as percent
  #
  # @return [Float] The number of processors used as float
  def procs_percent
    available_procs > 0 ? (procs_used.to_f / available_procs.to_f) * 100 : 0
  end

  # Return the owner processor usage as percent
  #
  # @return [Float] The number of processors used as float
  def owner_procs_percent
    owner_procs_avail > 0 ? (owner_procs_used.to_f / owner_procs_avail.to_f) * 100 : 0
  end

  # Return the node usage as percent
  #
  # @return [Float] The number of nodes used as float
  def nodes_percent
    available_nodes > 0 ? (nodes_used.to_f / available_nodes.to_f) * 100 : 0
  end

  # Return the owner node usage as percent
  #
  # @return [Float] The number of nodes used as float
  def owner_nodes_percent
    owner_nodes_avail > 0 ? (owner_nodes_used.to_f / owner_nodes_avail.to_f) * 100 : 0
  end
  
  # Return cluster title + error message
  #
  # @return nil or constructed error message
  def friendly_error_message
    error_message.nil? ? nil : "#{cluster_title} Cluster: #{error_message}"
  end

  private

    attr_writer :active_jobs, :eligible_jobs, :blocked_jobs, :procs_used, :procs_avail, :nodes_used, :nodes_avail,:error_message, :cluster_id, :cluster_title, :nodes_idle, :owner_nodes_used, :owner_nodes_idle, :owner_nodes_avail, :nodes_other, :procs_idle, :procs_other, :owner_procs_used, :owner_procs_idle, :owner_procs_avail, :owner_procs_other, :owner_nodes_other

    # assign 0 if the input is nil or empty
    def assign(match_string)
      !match_string.blank? ? match_string : 0
    end
end
