class Repo < ActiveRecord::Base
  has_many :commits, foreign_key: 'repo_id', class_name: 'GitCommit'
end
