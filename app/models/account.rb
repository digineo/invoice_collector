class Account < ActiveRecord::Base
  
  has_many :invoices
  
  # lädt neue Rechnungen runter
  def fetch_invoices
    invoices = []
    
    for invoice in fetcher.list
      # existiert schon?
      next if self.invoices.find_by_number(invoice.number)
      
      transaction do
        i = self.invoices.create! \
          :number => invoice.number,
          :date   => invoice.date,
          :amount => invoice.amount
        
        i.save_pdf(invoice.pdf)
        invoices << i
      end
    end
    
    invoices
  end
  
  def fetcher
    @fetcher ||= "Fetcher::#{self.module.camelize}".constantize.new(self)
  end
  
end
