class CreateGitCommitTable < ActiveRecord::Migration
  def change
    create_table :git_commit_tables do |t|
      t.string :author
      t.string :commit_id
      t.string :commit_date
      t.string :message
      t.integer :repo_id
    end
  end
end
