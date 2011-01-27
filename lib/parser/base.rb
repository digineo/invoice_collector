# encoding: UTF-8

module Parser
  
  # Basisklasse für Parser
  class Base
    
    def self.inherited(subclass)
      Parser.module_loaded subclass
    end
    
    def initialize(invoice)
      @invoice = invoice
    end
    
    # Holt den Gesamtbetrag der Rechnung aus der Text-Repräsentation der Rechnung
    # gibt nil zurück, wenn der Betrag nicht ermittelt werden kann
    def amount
      raise NotImplementedError
    end
    
    protected
    
    # Text-Repräsentation der Rechnung
    def text
      @invoice.text
    end
    
  end
  
end