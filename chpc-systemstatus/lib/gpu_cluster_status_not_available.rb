class GPUClusterStatusNotAvailable < GPUClusterStatus
  def initialize(id, title, message)
    @total_gpus = 0
    @gpus_unallocated = 0
    @full_nodes_available = 0
    @queued_gpus = 0
    @queued_jobs_req_gpus = 0
    @cluster_id = id
    @cluster_title = title
    @error_message = message
    self
  end
end