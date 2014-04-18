require 'messaging/kafka'
require 'micro_services/factory'

namespace :services do
  task :run => :environment do
    service_name = ENV['name']
    raise "Must provide the name of service to run through environment variable" unless service_name

    service = MicroService::Factory.create(service_name)
    Messaging::Kafka.new.run {|message_data| service.process(message_data)}

    raise "Service with name #{service_name} doesn't exist." unless service
  end
end
