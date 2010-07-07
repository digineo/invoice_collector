class Invoice < ActiveRecord::Base
  
  belongs_to :account
  
  has_attached_file :original,  :path => ':rails_root/data/invoices/:id/original.pdf'
  has_attached_file :signature, :path => ':rails_root/data/invoices/:id/signature.:extension'
  
  validates_presence_of :account_id
  validates_format_of   :number, :with => /^[A-Z0-9_-]+$/i
  validates_attachment_presence :original
  
  named_scope :latest, :order => 'date DESC', :limit => 10
  
  def print(args='')
   # Datei an den Drucker schicken
    unless system("lpr #{original.path} #{args}")
      raise "printing failed with status #{$?.to_i}"
    end
  end
  
end
