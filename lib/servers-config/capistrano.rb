require 'servers-config'

module Capistrano
  module ServersConfig
    def self.extend(configuration)
      configuration.load do
        Capistrano::Configuration.instance.load do
          def load_servers(filename)
            ServersConfig.load_config(filename)
            ServersConfig.each_role do |role, hosts|
              role "_#{role}".to_sym, *hosts
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::ServersGroups.extend(Capistrano::Configuration.instance)
end

