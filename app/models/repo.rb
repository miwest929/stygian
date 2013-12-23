class Repo < ActiveRecord::Base
  has_many :commits, foreign_key: 'repo_id', class_name: 'GitCommit'

  def for_each_commit
    self.commits.reverse.each do |c|
      system("cd #{Rails.root}/tmp/#{tag} && git show #{c.commit_id} > commit#{c.commit_id}.txt")
      diff = File.readlines("#{Rails.root}/tmp/#{self.tag}/commit#{c.commit_id}.txt")

      yield(c, diff)
    end
  end
end
