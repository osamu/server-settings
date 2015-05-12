class ServerSettings

  class Host
    attr_accessor :host, :port, :config
    def initialize(host, port, config)
      @host = host
      @port = if config and config.has_key?("port")
                port || config["port"]
              else
                port
              end
      @config = config
    end

    def self.parse(host_line, config = {})
      host, port = host_line.split(/:/)
      self.new(host,port, config)
    end

    def method_missing(name, *args, &block)
      key = name.to_s
      return nil  unless @config.has_key? key
      @config[key]
    end
  end

  class HostCollection < Array
    def initialize(hosts, role_config)
      hosts.each do |host_exp|
        self.push Host.parse(host_exp, role_config)
      end
    end

    def with_format(format)
      self.map do |host|
        replacemap = Hash[host.config.map { |k,v| ["%#{k}", v] }]
        replacemap['%host'] = host.host
        replacemap['%port'] = host.port if host.port
        replacemap.inject(format) do |string, mapping|
          string.gsub(*mapping)
        end
      end
    end
  end

end
