class ServerSettings

  class Role
    attr_reader :name, :config

    def initialize(role, config)
      @name = role
      @config = load(config)
    end

    def load(config)
      role_options = config.keys.select{|s| s != "hosts"}
      @settings = Hash[*role_options.map do |option_name|
                         [ "%#{option_name}", config[option_name].to_s]
                       end.flatten]
      if config.has_key?("hosts")
        config["hosts"]= HostCollection.new(config["hosts"], @settings)
      end
      config
    end

    def hosts
      @config["hosts"] if @config.has_key?("hosts")
    end

    def host
      hosts.first
    end

    def method_missing(name, *args, &block)
      key = name.to_s
      return nil unless @config.has_key? key
      @config[key]
    end

    def with_format(format)
      hosts.with_format(format)
    end

  end

  class RoleDB < Role

    def databases
      @config.keys.select { |a| a.kind_of?(String) }
    end

    def db_config_each
      databases.map do |db|
        config = @config[db]
        if config && config.has_key?(:host)
          yield(config)
        else
          config.map do |nest_db, nest_config|
            yield(nest_config)
          end
        end
      end
    end

    def hosts
      db_config_each do |config|
        config[:host]
      end.flatten
    end

    # database.rb data strcutre
    def configurations
      parent_config_keys = @config.keys.select {|s| s.is_a?(Symbol)}
      parent_config = Hash[*parent_config_keys.map {|s| [s, @config[s]] }.flatten]
      db_config_each do |config|
        parent_config.each do |key,value|
          next if config.has_key?(key)
          config[key] = value
        end
      end
      return @config
    end

  end
end
