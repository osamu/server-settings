# -*- coding: utf-8 -*-
require 'yaml'
require "servers-config/version"

class ServersConfig

  def initialize
    @roles = {}
  end

  def << (config)
    @roles[config.role] = config
  end

  def each
    @roles.each do |role, config|
      yield(role, config)
    end
  end

  def has_key?(role)
    @roles.has_key?(role)
  end

  def method_missing(name, *args, &block)
    key = name.to_s
    return nil  unless has_key? key
    @roles[key]
  end

  class Config
    attr_reader :role, :config
    def initialize(role, config)
      @role = role
      @config = load(config)
    end

    def load(config); config; end

    def hosts
      @config["hosts"] if @config.has_key?("hosts")
    end

    def to_a
      hosts
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

  class ConfigDB < Config

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

  class << self
    def load_config(file)
      load_from_yaml(IO.read(file))
    end

    def load_from_yaml(yaml)
      config = YAML.load(yaml)
      config.each do |role, config|
        instance << config_klass(config).new(role, config)
      end
    end

    def each_role
      @servers_config.each do |role, config|
        yield(role, config.hosts)
      end
    end

    def config_klass(config)
      if config.has_key?("hosts")
        Config
      else
        ConfigDB
      end
    end

    private

    def instance
      return @servers_config if @servers_config
      @servers_config = self.new
      return @servers_config
    end

    def method_missing(name, *args, &block)
      instance.send(name, *args, &block)
    end
  end
end

