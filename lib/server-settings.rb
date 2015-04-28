# -*- coding: utf-8 -*-
require 'yaml'
require "server-settings/version"
require "server-settings/role"

class ServerSettings

  def initialize
    @roles = {}
  end

  def << (role)
    @roles[role.name] = role
  end

  def each
    @roles.each do |name, role|
      yield(name, role)
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

  class << self
    def load_config(file)
      load_from_yaml(IO.read(file))
    end

    def load_from_yaml(yaml)
      config = YAML.load(yaml)
      config.each do |role, config|
        instance << role_klass(config).new(role, config)
      end
    end

    def each_role
      @servers_config.each do |role, config|
        yield(role, config.hosts)
      end
    end

    def role_klass(config)
      if config.has_key?("hosts")
        Role
      else
        RoleDB
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

