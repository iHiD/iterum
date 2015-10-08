require 'propono'

Propono.config do |config|
  config.access_key = "SOME_ACCESS_KEY"
  config.secret_key = "SOME_SECRET_KEY"
  config.queue_region = "eu-west-1"
  config.application_name = "iterum"
  config.udp_host = "test-pergo.meducation.net"
  config.udp_port = "9732"
end

message = { entity: "test", action: "testing", id: 1 }
Propono.publish(:user, message)
sleep(10)

p "Message sent. Listening..."

Propono.listen_to_queue("user") do |message, context|
  raise StandardError.new("Fail!")
end
