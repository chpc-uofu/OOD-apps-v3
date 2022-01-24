# Utility class for building string requests to the Ganglia Server via object
#
# @author Brian L. McMichael
# @version 0.1.0
#
# TODO: Add 'glegend' option to show/hide the legend
class Ganglia

  # Initializer for the Ganglia interface object
  #
  # Default server:   First
  # Default report:   CPU Report
  # Default range:    One Hour
  # Default size:     Small
  #
  # @param [OodAppkit::Cluster]
  #
  # @return [Ganglia] self
  def initialize(cluster)
    @host = cluster
    @server = cluster.custom_config[:ganglia]
    self.hour
    self.report_cpu
    self.small
    self
  end

  # returns the name of the server being managed by this object
  #
  # @return [String] server name
  def server_id
    @host.id
  end

  def required_params
    params = ''
    @server['req_query'].each do |key, val|
      params += "&#{key}=#{val}"
    end
    params
  end

  def ganglia_host
    "#{@server['scheme']}#{@server['host']}/#{@server['segments'].join('')}?#{required_params}"
  end

  # Define the time-ago range for the data.
  #
  # The following options are the only ranges the ganglia server will accept.
  #
  # @option 'hour'
  # @option '2hr'
  # @option '4hr'
  # @option 'day'
  # @option 'week'
  # @option 'month'
  # @option 'year'
  #
  # @return [Ganglia] self
  def range(ganglia_range)
    @range = ganglia_range
    self
  end

  # Set the range to one hour
  #
  # @return [Ganglia] self
  def hour
    self.range('hour')
  end

  # Set the range to two hours
  #
  # @return [Ganglia] self
  def two_hours
    self.range('2hr')
  end

  # Set the range to four hours
  #
  # @return [Ganglia] self
  def four_hours
    self.range('4hr')
  end

  # Set the range to 24 hours
  #
  # @return [Ganglia] self
  def day
    self.range('day')
  end

  # Set the range to a week
  #
  # @return [Ganglia] self
  def week
    self.range('week')
  end

  # Set the range to a month
  #
  # @return [Ganglia] self
  def month
    self.range('month')
  end

  # Set the range to a year
  #
  # @return [Ganglia] self
  def year
    self.range('year')
  end

  # Define the report types available on the ganglia server
  #
  # The following options are the only report types the ganglia server will accept.
  #
  # @option 'cpu_report'
  # @option 'load_report'
  # @option 'mem_report'
  # @option 'network_report'
  # @option 'packet_report'
  #
  # @return [Ganglia] self
  def report(option)
    @report_type = option
    self
  end

  # Set the report type to CPU report
  #
  # @return [Ganglia] self
  def report_cpu
    self.report('cpu_report')
  end

  # Set the report type to load report
  #
  # @return [Ganglia] self
  def report_load
    self.report('load_report')
  end

  # Set the report type to memory report
  #
  # @return [Ganglia] self
  def report_mem
    self.report('mem_report')
  end

  # Set the report type to network report
  #
  # @return [Ganglia] self
  def report_network
    self.report('network_report')
  end

  # Set the report type to packet report
  #
  # @return [Ganglia] self
  def report_packet
    self.report('packet_report')
  end

  # Set the report type to moab nodes report
  #
  # @return [Ganglia] self
  def report_moab_nodes
    self.report('moab_nodes_report')
  end

  # Set the report type to moab jobs report
  #
  # @return [Ganglia] self
  def report_moab_jobs
    self.report('moab_jobs_report')
  end

  # Set the report type to 'small' as defined by ganglia server
  #
  # @return [Ganglia] self
  def small
    @chart_size = 'small'
    self
  end

  # Set the report type to 'medium' as defined by ganglia server
  #
  # @return [Ganglia] self
  def medium
    @chart_size = 'medium'
    self
  end

  # Set the report type to 'large' as defined by ganglia server
  #
  # @return [Ganglia] self
  def large
    @chart_size = 'large'
    self
  end

  # Set the size of the chart manually.
  #
  # @param [Integer] width The width of the output chart in pixels
  # @param [Integer] height The height of the output chart in pixels
  #
  # @return [Ganglia] self
  def size(width, height)
    if !width.nil? && (width.to_i > 0) && !height.nil? && (height.to_i > 0)
      @width = width
      @height = height
      @chart_size = nil
    end
    self
  end

  def to_s
    "#{ganglia_host}#{range_type}#{report_type}#{chart_size}#{time}"
  end

  # Builds a request that returns a png response from the ganglia server
  #
  # @return [String] The http URL used to request an image response from the ganglia server
  def png
    self.to_s
  end

  # Builds a request that returns a json response from the ganglia server
  #
  # @return [String] The http URL used to request a json response from the ganglia server
  def json
    "#{self.to_s}&json=true"
  end

  private

    def range_type
      "&r=#{@range}"
    end

    def report_type
      "&g=#{@report_type}"
    end

    def chart_size
      if !@chart_size.nil?
        "&z=#{@chart_size}"
      else
        "&width=#{@width}&height=#{@height}"
      end
    end

    # Pass in the open_id user if available
    #def openid_user
    #  if !ENV['REMOTE_USER'].nil?
    #    "&openid_identifier=#{ENV['REMOTE_USER']}"
    #  end
    #end

    # def cluster
    #   "&c=#{@server['cluster_code']}"
    # end

    def time
      current_server_time = Time.now.to_i
      "&timestamp=#{current_server_time}"
    end
end
