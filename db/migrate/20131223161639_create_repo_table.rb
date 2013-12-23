class CreateRepoTable < ActiveRecord::Migration
  def change
    create_table :repo_tables do |t|
      t.string :tag

      t.timestamps
    end
  end
end
