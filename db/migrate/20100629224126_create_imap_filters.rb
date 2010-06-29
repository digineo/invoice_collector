class CreateImapFilters < ActiveRecord::Migration
  def self.up
    create_table :imap_filters do |t|
      t.string :name, :null => false
      t.text   :search, :null => false
      t.string :subject, :filename, :null => false
      t.timestamps :null => false
    end
    
    add_column :accounts, :imap_filter_id, :integer
  end

  def self.down
    remove_column :accounts, :imap_filter_id
    drop_table :imap_filters
  end
end
