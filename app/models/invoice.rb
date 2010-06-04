class Invoice < ActiveRecord::Base
  
  validates_presence_of :account_id
  validates_format_of   :number, :with => /^[A-Z0-9-]+$/i
  
  after_destroy :delete_pdf
  
  def save_pdf(data)
    File.open(filename, 'w') {|f| f.write(data) }
  end
  
  def filename
    "#{RAILS_ROOT}/data/invoices/#{id}.pdf"
  end
  
  def print
    `lpr #{filename}`
  end
  
  protected
  
  def delete_pdf
    File.unlink(filename)
  end
  
end
