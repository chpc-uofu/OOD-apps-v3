class MoabShowqClientNotAvailable < MoabShowqClient
  def initialize(id, title, message)
    self.active_jobs = self.eligible_jobs = self.blocked_jobs = self.procs_used = self.procs_avail = self.nodes_used = self.nodes_avail = 0
    self.cluster_id = id
    self.cluster_title = title
    self.error_message = message
    self
  end
end
