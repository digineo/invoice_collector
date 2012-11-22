class AddWebhookUrlToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :webhook_data, :string
  end

  def self.down
    remove_column :accounts, :webhook_data
  end
end
