require 'kafka'
require 'messaging/kafka'

namespace :kafka do
  task :produce => :environment do
    producer = Kafka::Producer.new

    COUCHDB_DB.documents['rows'].each_with_index do |commit, index|
      commit_json = COUCHDB_DB.get(commit['id']).to_json
      msg = Kafka::Message.new(commit_json)
      producer.push(msg)

      display_progress("Pushed #{index+1} commits to Kafka", index + 1, 100)
    end
  end

  task :consume => :environment do
    puts "Ready to consume commit messages..."
    Messaging::Kafka.new.run {|message_data| puts message_data}
  end

  def display_progress(msg, count, increment)
    puts msg if (count % increment == 0)
  end
end
