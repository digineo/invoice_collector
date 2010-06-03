module Fetcher
  
  class Invoice
    
    attr_reader :href, :number, :date, :amount
    
    def initialize(fetcher,attributes)
      @fetcher = fetcher
      @href    = attributes[:href]
      @number  = attributes[:number]
      @date    = attributes[:date]
      @amount  = attributes[:amount]
    end
    
    # Datei mit Dateiname und Inhalt
    def file
      @fetcher.get(self)
    end
    
    # PDF-Daten
    def pdf
      file.body
    end
    
  end
  
end