class ServerSettings

  class Host
    attr_accessor :host, :port
    def initialize(host,port)
      @host = host
      @port = port
    end

    def self.parse(host_line)
      host, port = host_line.split(/:/)
      self.new(host,port)
    end
  end

  class HostCollection < Array
    def initialize(hosts, role_config)
      @role_config = role_config
      hosts.each do |host_exp|
        self.push Host.parse(host_exp)
      end
    end

    def with_format(format)
      self.map do |host|
        replacemap = @role_config
        replacemap['%host'] = host.host
        replacemap['%port'] = host.port if host.port
        replacemap.inject(format) do |string, mapping|
          string.gsub(*mapping)
        end
      end
    end
  end

end
