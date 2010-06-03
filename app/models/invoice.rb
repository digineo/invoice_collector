class Invoice < ActiveRecord::Base
  
  validates_presence_of :account_id
  validates_format_of   :number, :with => /^[A-Z0-9]+$/i
  
  def save_pdf(data)
    File.open(filename, 'w') {|f| f.write(data) }
  end
  
  def filename
    "#{RAILS_ROOT}/data/invoices/#{id}.pdf"
  end
  
  def print
    `lpr #{filename}`
  end
  
end
