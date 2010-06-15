class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :module, :null => false
      t.boolean :active,    :null => false, :default => true
      t.boolean :autoprint, :null => false, :default => false
      t.string :username, :password, :null => false
      t.timestamps :null => false
    end
    change_table :accounts do |t|
      t.index [:module,:username], :unique => true
    end
  end

  def self.down
    drop_table :accounts
  end
end
