# ServersConfig

ServersConfiguration is useful configuration scheme for any where.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'servers-config'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install servers-config

## Usage

### Prepare
First of all, you must define servers and role in YAML

```yaml
(rolename):
  (option_param): (option_value)
  (...)
  hosts:
    - host1
    - host2
```

### For Dalli

```yaml
memcached_servers:
  port: 11211
  hosts:
    - 192.168.100.1
    - 192.168.100.2
```

```ruby
ServersConfig.load_config("config/production/server-config.yaml")

ActiveSupport::Cache::DalliStore.new ServersConfig.memcached_servers.with_format("%host:%port"), options

```

### For Resque host
```yaml
redis_endpoint:
  port: 6379
  hosts:
   - 192.168.100.1
```
When hosts have single record, host accessor return string value
instend of Array.
```
Resque.redis = ServersConfig.redis_endpoint.with_format("%host:%port")

```
### For ActiveRecord DB

```yaml
database:
  :adapter: mysql2
  :encoding: utf8
  :reconnect: true
  :database: dbname-master
  :pool: 1
  :username: user
  :password: pass
  :host: 192.168.100.1
  master:
    :host: 192.168.100.2
  user:
    :database: dbname-user
    :host: 192.168.100.3

```

```ruby
ServersConfig.load_config("config/production/server-config.yaml")

ActiveRecord::Base.configurations[:development]  = ServersConfig.database.configurations
```

### For Capistrano
```ruby
require  'servers-config/capistrano'

load_servers("config/production/servers-config.yaml")

```

## For other application configuration

```ruby
ServersConfig.load_config("config/production/server-config.yaml")
ServersConfig.each_role do |role, config|
  puts "#{role}, #{config.hosts}"
end
```

```ruby
puts ServersConfig.memcached_servers.to_a

```
## Contributing

1. Fork it ( https://github.com/[my-github-username]/servers/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
