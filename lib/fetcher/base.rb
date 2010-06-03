module Fetcher
  
  class Base
    
    def initialize(account)
      @account = account
      after_initialize
    end
    
    def list
      raise NotImplementedError
    end
    
    def get(invoice)
      raise NotImplementedError
    end
    
    protected
    
    def after_initialize
      
    end
    
    def build_invoice(attributes)
      Invoice.new self, attributes
    end
    
  end
  
end