module Fetcher
  
  class Base
    
    def initialize(account)
      @account  = account
      @agent  ||= Mechanize.new
    end
    
    def list
      raise NotImplementedError
    end
    
    def get(invoice)
      @agent.get(invoice.href)
    end
    
    protected
    
    def after_initialize
      
    end
    
    def build_invoice(attributes)
      Invoice.new self, attributes
    end
    
    # extrahiert einen betrag aus dem text
    def extract_amount(value)
      value.match(/[\d.,]*\d+[.,]\d+/)[0].gsub(/[.,]/,'').to_f/100
    end
    
  end
  
end