class CreateRepoTable < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :tag

      t.timestamps
    end
  end
end
