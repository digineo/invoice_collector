module Fetcher
  
  class Hosteurope < Base
    
    START = 'https://kis.hosteurope.de/'
    
    def list
      page  = @agent.get(START)
      form  = page.form('f')
      form.kdnummer = @account.username
      form.passwd   = @account.password
      
      # Einloggen
      page = @agent.submit(form)
      
      # Login fehlgeschlagen?
      raise LoginException if page.uri.to_s.ends_with?('/index.php')
      
      # Link zur Rechnungsübersicht
      page = @agent.get('/kundenkonto/rechnungen/')
      
      invoices = []
      
      for row in page.search("tr")
        
        cells = row.search("td")
        next if cells.empty?
        
        input = cells[0].search("input[name=belegnr]").first
        next if !input
        
        number = input["value"].to_s
        
        invoices << build_invoice(
          :href   => "/kundenkonto/rechnungen/index.php?inline=yes&belegnr="+number,
          :number => number,
          :date   => Date.parse(cells[3].text),
          :amount => cells[5].text.split.first.sub(',','.').to_f
        )
      end
      
      invoices
    end
    
    def get(invoice)
      @agent.get(invoice.href)
    end
    
    protected
    
    def after_initialize
      @agent = Mechanize.new
    end
    
  end
  
end