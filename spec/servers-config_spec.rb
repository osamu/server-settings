require 'spec_helper'
require 'servers-config'

describe ServersConfig do
  let (:server_config) {
          yaml_text = <<-EOF
role1:
  port: 1000
  hosts:
    - 1.1.1.1
    - 2.2.2.2
role2:
  hosts:
    - 3.3.3.3
EOF
  }

  describe "config_load" do
    before do
      yaml = YAML.load(server_config)
      filepath = "config.yml"
      allow(IO).to receive(:read).with(filepath).and_return(server_config)
    end

    it 'can load yaml file' do
      ServersConfig.load_config("config.yml")
    end

    ## TODO check invalid yaml
  end

  describe "role accessor" do
    it 'return array of hosts corresponds to role' do
      ServersConfig.load_from_yaml(server_config)
      expect(ServersConfig.role1.to_a).to eq(["1.1.1.1", "2.2.2.2"])
    end
  end

  describe "each role" do
    it 'can iterate each server' do
      ServersConfig.load_from_yaml(server_config)
      expect { |b|  ServersConfig.each_role(&b) }.to  yield_successive_args([ "role1", ServersConfig::Config],
                                                                            [ "role2", ServersConfig::Config])
    end
  end

  describe "with_format" do
    it 'can format host string with configuration params' do
      ServersConfig.load_from_yaml(server_config)
      expect(ServersConfig.role1.with_format("%host:%port")).to eq(["1.1.1.1:1000", "2.2.2.2:1000"])
    end
  end
end
