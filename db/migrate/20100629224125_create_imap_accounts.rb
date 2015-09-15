class CreateImapAccounts < ActiveRecord::Migration
  def self.up
    create_table :imap_accounts do |t|
      t.string :host, :username, :password, :null => false
      t.boolean :ssl,  :null => false, :default => true
      t.integer :port, :null => false, :default => 993
    end
    change_table :imap_accounts do |t|
      t.index [:host,:username], :unique => true
    end

    add_column :accounts, :imap_account_id, :integer
  end

  def self.down
    remove_column :accounts, :imap_account_id
    drop_table :imap_accounts
  end
end
