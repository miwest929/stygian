namespace :register do
  desc "Register a repo to be visualized"
  task :repo => :environment do
    raise StandardError.new("Must specify a path for the repo") unless ENV['path']
    path = ENV['path']

    GitHistory.parse(path)
  end
end
