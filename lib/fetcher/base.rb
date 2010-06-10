module Fetcher
  
  # Basisklasse für Fetcher
  class Base
    
    def self.inherited(subclass)
      Fetcher.module_loaded subclass
    end
    
    def initialize(account)
      @account  = account
      @agent  ||= Mechanize.new
    end
    
    # Startet die Session
    # schlägt das Login fehlt, wird eine Fetcher::LoginException geworfen
    def login
      raise NotImplementedError
    end
    
    # Gibt eine Liste der verfügbaren Rechnungen zurück
    def list
      raise NotImplementedError
    end
    
    # Lädt eine Rechnung oder Signatur herunter
    def download(invoice,href)
      get(href)
    end
    
    # Beendet die Session
    def logout
      raise NotImplementedError
    end
    
    protected
    
    # macht einen HTTP-Request
    def get(path)
      @agent.get(path)
    end
    
    def build_invoice(attributes)
      Invoice.new self, attributes
    end
    
    # extrahiert einen Betrag aus dem text
    def extract_amount(value)
      value.match(/[\d.,]*\d+[.,]\d+/)[0].gsub(/[.,]/,'').to_f/100
    end
    
  end
  
end