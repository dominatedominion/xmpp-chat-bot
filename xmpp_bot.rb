require 'blather/client'
require 'optparse'

if File.exists?("config.yml")
  config = YAML.load_file("config.yml")

  @jabber_id = config["connection"]["node"] || nil
  @password = config["connection"]["password"] || nil
  @host = config["connection"]["host"] || nil
  @port = config["connection"]["port"] || nil
  @certs = config["connection"]["certs"] || nil
  @connect_timeout = config["connection"]["connect_timeout"] || nil
end

OptionParser.new do |o|
  o.on('-j', '--jabber_id JABBER_ID', 'use JABBER_ID to connect') do |jabber_id|
    @jabber_id = jabber_id
  end

  o.on('-p', '--password PASSWORD', 'use PASSWORD to authenticate') do |password|
    @password = password
  end

  o.on('-h', '--host HOST', 'connect to HOST') do |host|
    @host = host
  end

  o.on('--port PORT', 'connect to HOST on PORT') do |port|
    @port = port
  end

  o.on('-c', '--certs CERTS', 'authenticate using CERTS') do |certs|
    @certs = certs
  end

  o.on('-t', '--timeout TIMEOUT', 'timeout connection attempt after TIMEOUT seconds') do |timeout|
    @connect_timeout = timeout
  end

  o.separator ""
  o.separator "HELP"

  o.on_tail("-h", , "--h", "--help", "Show this message") do
    puts o
    exit
  end
end.parse!

setup @jabber_id, @password, @host, @port, @certs, @connect_timeout

when_ready do
  # initialize on initial connection
  write_to_stream "kirillian's test XMPP bot SUCCESSFUL!!!"
end

disconnected do
  client.reconnect
end

client.register_handler(:ready)
client.register_handler(:disconnected)

# Auto approve subscription requests
subscription :request? do |stanza|
  write_to_stream stanza.approve!
end

# Log message
message :chat?, :body do |message|
  puts message.inspect
end
