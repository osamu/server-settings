require 'spec_helper'
require 'server-settings'

describe ServerSettings do
  describe ServerSettings::Host do
    it 'can parse host:port expression' do
      host = ServerSettings::Host.parse("1.1.1.1:80")
      expect(host.host).to eq("1.1.1.1")
      expect(host.port).to eq("80")
    end

    it 'can parse host only expression' do
      host = ServerSettings::Host.parse("1.1.1.1")
      expect(host.host).to eq("1.1.1.1")
      expect(host.port).to eq(nil)
    end

    it 'can parse host expression with settings' do
      role_settings = { "port" => "1000" }
      host = ServerSettings::Host.parse("1.1.1.1", role_settings)
      expect(host.host).to eq("1.1.1.1")
      expect(host.port).to eq("1000")
    end
  end

  describe ServerSettings::HostCollection do
    it 'hold Host list like array' do
      role_settings = nil
      role_hosts = [ '1.1.1.1', '2.2.2.2', '3.3.3.3']
      collection = ServerSettings::HostCollection.new(role_hosts, role_settings)
      expect(collection.count).to eq(3)
      expect(collection.first.host).to eq("1.1.1.1")
    end

    it 'can apendable and selectable' do
      collection1 = ServerSettings::HostCollection.new( [ '1.1.1.1', '2.2.2.2', '3.3.3.3'],
                                                        { "port" => "8080",
                                                          "availability_zone" => "DC1"})
      collection2 = ServerSettings::HostCollection.new( [ '4.4.4.4', '5.5.5.5', '6.6.6.6'],
                                                        { "port" =>  "80",
                                                          "availability_zone" => "DC2"})
      collection = collection1 + collection2
      expect(collection.select {|host|  host.availability_zone == "DC2" }.count ).to eq(3)
    end

    it 'can convert host expression with format' do
      collection = ServerSettings::HostCollection.new( [ '1.1.1.1', '2.2.2.2', '3.3.3.3'],
                                                       { "port" => "8080",
                                                         "availability_zone" => "DC1" })
      expect(collection.with_format("%host:%port")).to eq( ['1.1.1.1:8080', '2.2.2.2:8080', '3.3.3.3:8080'] )
    end

  end
end

