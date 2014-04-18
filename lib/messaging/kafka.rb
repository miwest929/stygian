require 'kafka'

module Messaging
  class Kafka
    attr_accessor :topic

    def initialize(topic = nil)
      @topic = topic
    end

    def run
      consumer = ::Kafka::Consumer.new

      consumer.loop do |messages|
        messages.each {|m| yield(m.payload)}
      end
    end
  end
end
