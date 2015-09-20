class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.references :account, :null => false
      t.string   :number
      t.date     :date
      t.decimal  :amount, :precision => 9, :scale => 2
      t.string   :original_file_name, :null => false
      t.datetime :created_at, :null => false
    end
    change_table :invoices do |t|
      t.index [:account_id,:number], :unique => true
      t.index [:account_id,:date]
    end
  end

  def self.down
    drop_table :invoices
  end
end
