namespace :register do
  desc "Register a repo to be visualized"
  task :repo => :environment do
    begin
      raise StandardError.new("Must specify a path for the repo") unless ENV['path']
      path = ENV['path']

      # tag is the GitHub repo name
      tag = /\/(.*)\.git/.match(path)[1]
      raise "Repo with tag '#{tag}' is already registered." if Repo.find_by_id(tag)

      system("cd #{Rails.root}/tmp && git clone #{path} && cd #{tag} && git log > temphist.txt")
      repo = parse_git_history(tag)
      repo.save
    ensure
      puts "Cleaning up..."
      system("rm -Rf #{Rails.root}/tmp/#{tag}")
    end
  end

  # Returns a Repo object
  def parse_git_history(name)
    repo = Repo.new(tag: name)

    repo.commits = []
    current_commit = nil
    File.readlines("#{Rails.root}/tmp/#{name}/temphist.txt").each do |line|
      # Start of new commit
      if line.starts_with?('commit')
        if current_commit
          current_commit.save
          repo.commits << current_commit
        end

        commit_id = line.split(' ')[1]
        current_commit = GitCommit.new(commit_id: commit_id, message: "")
      elsif line.starts_with?('Author:')
        author = line[7..-1].strip
        current_commit.author = author
      elsif line.starts_with?('Date:')
        date = line[5..-1].strip
        current_commit.commit_date = date
      else
        current_commit.message += line
      end
    end

    if current_commit
      current_commit.save
      repo.commits << current_commit
    end

    repo
  end
end
