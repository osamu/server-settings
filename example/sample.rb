require 'servers-config'
require 'pp'

yaml =<<EOF
redis:
  port: 6379
  hosts:
   - 192.168.100.1

app:
  protocol: http
  user: hogehoge
  port: 8080
  hosts:
   - 192.168.100.1/user=hoge&port=8080

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
EOF

# Load Configuration
ServersConfig.load_from_yaml(yaml)

# Define Host format
#ServersConfig.host_format[:default] = "%host:%port"
#ServersConfig.host_format[:redis] = "redis://%host:%port"

# Role and Host accessor
p ServersConfig.redis.hosts
p ServersConfig.app.with_format("%protocol://%user@%host:%port")

# Role Iterator
ServersConfig.each_role do |role, role_config|
  puts "#{role}"
  puts role_config
end

# Database Configuration
p ServersConfig.database.hosts


