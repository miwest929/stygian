namespace :octokit do
  task :load_commits => :environment do
    repo = get_repo_or_raise

    Github.load_commits(repo)
  end

  task :load_patches => :environment do
    repo = get_repo_or_raise
    Github.load_patches(repo)
  end

  task :load_repo => :environment do
    Rake::Task['octokit:load_commits'].invoke
    Rake::Task['octokit:load_patches'].invoke
  end

  def get_repo_or_raise
    repo = ENV['repo']
    raise "Must provide a name for the repository in an env var called 'repo'" unless repo
    repo
  end
end
