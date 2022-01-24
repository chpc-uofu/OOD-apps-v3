# Utility class for getting numerical data regarding GPU usage in the set of clusters that allow job submission using Slurm
#

class GPUClusterStatusSlurm

  attr_reader :gpus_unallocated, :total_gpus, :full_nodes_available, :queued_jobs_requesting_gpus, :error_message

  # Set the object to the server.
  #
  # @param cluster [OodCore::Clusters]
  #
  # @return [GPUClusterStatus]
  def initialize(cluster)
    @oodClustersAdapter = nil
    @server = "/usr/bin"
    @cluster_id = cluster.id
    @cluster_title = cluster.metadata.title || cluster.id.titleize
   self
  end

  def setup
    #calc_total_gpus
    #calc_gpus_unallocated
    #calc_full_nodes_avail
    #calc_queued_jobs_requesting_GPUs
    self
  rescue => e
    GPUClusterStatusNotAvailable.new(@cluster_id, @cluster_title, e)
  end

  # @return [Pathname] pbs bin pathname
  def pbs_bin
    Pathname.new(@server['bin'].to_s)
  end

  # Defines a method for writing a pbsnodes command line to a terminal.
  #
  # @param cluster_server [String]
  def pbsnodes(cluster_server)
    #cmd = pbs_bin.join("pbsnodes").to_s
    args = ["-s", cluster_server, ":gpu"]
    o, e, s = Open3.capture3(cmd, *args)
    s.success? ? o : raise(CommandFailed, e)
  rescue Errno::ENOENT => e
     raise InvalidCommand, e.message
  end

  # @return [String] Information regarding cluster nodes
  def nodes_info
    #pbsnodes(@cluster_title.downcase + "-batch.ten.osc.edu")
  end

  # Calculate total number of GPUs on a cluster
  # @return [Integer] total number of gpus in a cluster
  def calc_total_gpus
    @total_gpus = 0
    #if @cluster_title.eql?("Ruby")
    #   # For the Ruby cluster, pbsnodes takes into account two debug nodes with two GPUs along with the other Ruby GPU nodes. The debug nodes will not be considered in the total GPUs and unallocated GPUs calculation, as they cannot be allocated as part of a regular job request with other GPU nodes. Here np = 20 is the number of processors for a GPU node rather than a debug node (np = 16) in a Ruby cluster.
    #   @total_gpus = nodes_info.scan(/np = 20/).size
    #  else
    #   @total_gpus = nodes_info.lines("\n\n").size
    #end
  end

  # Calculate number of unallocated GPUs with atleast one core available
  # @return [Integer] the number of unallocated GPUs
  def calc_gpus_unallocated
    @gpus_unallocated = 0
    #if @cluster_title.eql?('Owens')
    #  @gpus_unallocated = nodes_info.lines("\n\n").select { |node|
    #    !node.include?("dedicated_threads = 28") && node.include?("Unallocated") }.size
    # elsif @cluster_title.eql?('Pitzer')
    #  @gpus_unallocated = nodes_info.lines("\n\n").select { |node| !node.include?("dedicated_threads = 40") }.to_s.scan(/gpu_state=Unallocated/).size
    # else @cluster_title.eql?('Ruby')
    #  # See line 62. Excluding the two debug nodes from the calculation.
    #  @gpus_unallocated = nodes_info.lines("\n\n").select { |node| node.include?("Unallocated") && !node.include?("dedicated_threads = 20") && node.include?("np = 20") }.size
    #  @oodClustersAdapter.info_all_each { |job| p job}
    #end
  end

  # Calculate number of full nodes (nodes with all cores free) available that contain one or more GPUs available
  # @return [Integer] the number of full nodes available
  def calc_full_nodes_avail
    @full_nodes_available = 0
    #if @cluster_title.eql?("Ruby")
    #  # See line 62
    #@full_nodes_available = nodes_info.lines("\n\n").select { |node| node.include?("dedicated_threads = 0") && node.include?("np = 20") && node.include?("gpu_state=Unallocated")}.size
    #else
    #@full_nodes_available = nodes_info.lines("\n\n").select { |node| node.include?("dedicated_threads = 0") && node.include?("gpu_state=Unallocated") }.size
    #end
  end

  # Calculates number of jobs that have requested one or more GPUs that are currently queued
  # @return [Integer] the number of queued jobs requesting GPUs
  def calc_queued_jobs_requesting_GPUs
    @queued_jobs_requesting_gpus = 0
    #@queued_jobs_requesting_gpus = 0
    #@oodClustersAdapter.info_all_each { |job| queued_jobs_requesting_gpus_counter(job) }
    #@queued_jobs_requesting_gpus
  end

  # Checks to see whether a job is queued and requesting a gpu
  #
  # @param job [OodCore::Job::Info]
  # @return true if job requested a gpu and is queued otherwise false
  def is_job_requesting_gpus_and_queued(job)
    false
    # job.status.queued? && job.native[:Resource_List][:nodes].include?("gpus")
  end

  # Return the allocated GPUs as percent of available GPUs
  #
  # @return [Float] The percentage GPUs used
  def gpus_percent
    ((0.10).to_f) * 100
    #((total_gpus - full_nodes_available).to_f / total_gpus.to_f) * 100
  end

  # Return the percentage of queued jobs requesting gpus
  #
  # @return [Float] The percentage GPUs queued
  def percent_of_queued_jobs_requesting_gpus(available_jobs)
    ((0.15).to_f) * 100
    #(queued_jobs_requesting_gpus.to_f / available_jobs) * 100
  end

  # Return the percentage of queued jobs not requesting gpus
  #
  # @return [Float] The percentage
  def percent_of_queued_jobs_not_requesting_gpus(available_jobs, eligible_jobs)
    #@queued_jobs_requesting_no_gpus = (eligible_jobs - queued_jobs_requesting_gpus).abs()
    #(@queued_jobs_requesting_no_gpus.to_f / available_jobs) * 100
  end

  private

    attr_accessor :oodClustersAdapter

    # Helper Methods

    # Helper method for counting the number of queued gpus and jobs requesting gpus
    #
    # @param job [OodCore::Job::Info]
    def queued_jobs_requesting_gpus_counter(job)
      if is_job_requesting_gpus_and_queued(job)
        #@queued_jobs_requesting_gpus += 1
        return 0
      end
    end
end
