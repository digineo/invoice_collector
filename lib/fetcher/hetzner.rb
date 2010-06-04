module Fetcher
  
  class Hetzner < Base
    
    START = 'https://robot.your-server.de/'
    
    def list
      # erst die Startseite aufrufen
      @agent.get(START)
      
      # Jetzt einloggen
      page = @agent.post(START+'login/check?user='+CGI.escape(@account.username)+'&password='+CGI.escape(@account.password))
      
      # Login fehlgeschlagen?
      raise LoginException if page.uri.path != '/'
      
      # Rechnungsübersicht aufrufen
      page = @agent.get('/invoice')
      
      invoices = []
      
      for row in page.search("div[class=box_wide]")
        
        match  = row.child["onclick"].match %r(/invoice/download/number/(\w+)/date/(\w+)) rescue next
        number = match[1]
        date   = Date.parse(match[2])
        href   = "/invoice/deliver?number=#{number}&date=#{match[2]}"
        
        invoices << build_invoice(
          :href   => href,
          :number => number,
          :date   => date
        )
      end
      
      invoices
    end
    
  end
  
end