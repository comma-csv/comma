# frozen_string_literal: true

class Post < ActiveRecord::Base
  has_one :user

  comma do
    title
    description

    user :full_name
  end
end

class User < ActiveRecord::Base
  comma do
    first_name
    last_name
    full_name 'Name'
  end

  comma :shortened do
    first_name
    last_name
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end

MIGRATION_CLASS =
  if Rails::VERSION::STRING =~ /^[56].*/
    ActiveRecord::Migration[4.2]
  else
    ActiveRecord::Migration
  end

class CreateTables < MIGRATION_CLASS
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
ActiveRecord::Migration.verbose = false
CreateTables.up
