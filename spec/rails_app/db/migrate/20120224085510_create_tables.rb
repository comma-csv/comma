
class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string      :first_name
      t.string      :last_name

      t.timestamps
    end

    create_table :posts do |t|
      t.references :user
      t.string :title
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
    drop_table :users
  end
end
