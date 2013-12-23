class Repo < ActiveRecord::Base
  has_many :git_commits
end
