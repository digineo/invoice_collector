module Fetcher
  
  class Hetzner < Base
    
    START = 'https://robot.your-server.de/'
    
    def login
      # erst die Startseite aufrufen
      @agent.get(START)
      
      # Jetzt einloggen
      page = @agent.post(START+'login/check?user='+CGI.escape(@account.username)+'&password='+CGI.escape(@account.password))
      
      # Login fehlgeschlagen?
      raise LoginException if page.uri.path != '/'
    end
    
    def list
      # Rechnungsübersicht aufrufen
      page = @agent.get('/invoice') # /invoice/index/page/2
      
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
    
    def logout
      @agent.get('/login/logout')
    end
    
  end
  
end