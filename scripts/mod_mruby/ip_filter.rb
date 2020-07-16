#
# Extenstion mehtos for mruby-ipaddr
#
class IPAddr
  # ( Example )
  # IPAddr.new('192.168.56.0/25')
  # #<IPAddr: IPv4:192.168.56.0/255.255.255.128>
  # @mask => "\377\377\377\200"
  # @mask.unpack('C*') => [255, 255, 255, 128]
  #                          8 +  8 +  8 +  1 = 25
  def network_address_length
     orderd_mask_values = [0 , 128, 192, 224, 240, 248, 252, 254, 255]
     @mask.unpack('C*').inject(0){|plen,o| plen+=(orderd_mask_values.index(o.to_i) || 8)}
  end

  def host_address?
     network_address_length == 32
  end

  def same_network?(other)
    return false unless other.is_a?(IPAddr)
    if self.host_address? && other.host_address?
      self == other
    else
      if other.host_address?
        other_network = other.mask(network_address_length)
        @addr == other_network.instance_variable_get('@addr')
      else
        @addr == other.instance_variable_get('@addr')
      end
    end
  end
end

#
# IP Filtering class
#
class IPFilter
  def initialize(apache_req, apache_con)
    @apache_req, @apache_con = apache_req, apache_con
    # loading filter rules.
    database_yml_path = File.join(File.dirname(__FILE__).split('/plugins/redmine_ip_filtering').first, 'config/database.yml')
    database_yml = File.open(database_yml_path) {|f| YAML.load(f.read)}
    conf = database_yml['production']
    db = MySQL::Database.new(conf['host'].to_s, conf['username'].to_s, conf['password'].to_s, conf['database'].to_s)
    rows = db.execute('select ipaddr from filter_rules')
    @valid_addresses = []
    while row = rows.next; @valid_addresses << row[0]; end
    rows.close; db.close
  end

  def valid_access?(remote_ip)
    return true if @valid_addresses.empty?

    @valid_addresses.each do |valid_address|
      valid_ipaddr = IPAddr.new(valid_address)
      remote_ipaddr = IPAddr.new(remote_ip)
      return true if valid_ipaddr.same_network?(remote_ipaddr)
    end
    return false
  end

  def execute!
    if valid_access?(@apache_req.headers_in['X-Forwarded-For'] || @apache_con.remote_ip)
      Apache::return(Apache::OK)
    else
      #Apache::return(Apache::HTTP_UNAUTHORIZED)
      Apache::return(Apache::HTTP_FORBIDDEN)
    end
  rescue => e
    Apache.errlogger Apache::APLOG_ERR, e.message
    Apache::return(Apache::HTTP_INTERNAL_SERVER_ERROR)
  end
end

#
# execute IP Filter
#
IPFilter.new(Apache::Request.new, Apache::Connection.new).execute!
