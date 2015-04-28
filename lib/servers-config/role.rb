class ServersConfig

  class Role
    attr_reader :name, :config

    def initialize(role, config)
      @name = role
      @config = load(config)
    end

    def load(config); config; end

    def hosts
      @config["hosts"] if @config.has_key?("hosts")
    end

    def to_a
      hosts
    end

    def host
      hosts.first
    end

    def method_missing(name, *args, &block)
      key = name.to_s
      return nil unless @config.has_key? key
      @config[key]
    end

    def settings
      conf_names = @config.keys.select{|s| s != "hosts"}
      Hash[*conf_names.map do |conf_name|
             [ "%#{conf_name}", @config[conf_name].to_s]
           end.flatten]
    end

    def with_format(format)
      hosts.map do |host|
        replacemap = { '%host' => host }.merge(settings)
        replacemap.inject(format) do |string, mapping|
          string.gsub(*mapping)
        end
      end
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
