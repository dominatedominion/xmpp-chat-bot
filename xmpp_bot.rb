require 'blather/client'
require 'optparse'
require 'yaml'

Blather.logger = Logger.new $stdout
Blather.logger.level = Logger::DEBUG

@reconnection_attempts = 0

if File.exists?("config.yml")
  config = YAML.load_file("config.yml")

  @jabber_id = config["connection"]["jabber_id"] || nil
  @resource = config["connection"]["resource"] || nil
  @password = config["connection"]["password"] || nil
  @host = config["connection"]["host"] || nil
  @port = config["connection"]["port"] || nil
  @certs = config["connection"]["certs"] || nil
  @connect_timeout = config["connection"]["connect_timeout"] || nil
end

setup "#{@jabber_id}/#{@resource}", @password, @host, @port, @certs, @connect_timeout

when_ready do
  puts "Client Connected!"
  # initialize on initial connection
  @reconnection_attempts = 0
  write_to_stream "kirillian's test XMPP bot SUCCESSFUL!!!"
end

disconnected do
  reconnect_time = ((2**@reconnection_attempts) - 1) > 60 ? 60 : ((2**@reconnection_attempts) - 1)
  puts "Client Disconnected...Attempting reconnect in #{reconnect_time.to_s}s"
  @reconnection_attempts += 1
  sleep(reconnect_time)
  client.connect
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

stanza_error do |error|
  puts "ERROR MESSAGE: #{error.inspect}"
end

stream_error do |error|
  puts "STREAM ERROR MESSAGE: #{error.inspect}"
end