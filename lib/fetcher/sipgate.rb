module Fetcher
  
  class Sipgate < Base
    
    START = 'https://secure.sipgate.de/user/index.php'
    
    def login
      page  = @agent.get(START)
      form  = page.form('login')
      form.uname = @account.username
      form.passw = @account.password
      
      # Einloggen
      page = form.submit
      
      # Login fehlgeschlagen?
      raise LoginException if page.uri.path != '/user/start.php'
    end
    
    def list
      page = @agent.get('/user/invoice.php') # ?year=2009
      
      invoices = []
      
      for row in page.search("table[class=newtable]/tr")
        
        link  = row.search("a").first
        next unless link
        
        invoices << build_invoice(
          :href   => link['href'],
          :number => link['href'].match(/&nr=(\w+)$/)[1],
          :date   => link.text.match(/Rechnung vom (\S+)/)[1]
        )
      end
      
      invoices
    end
    
    def logout
      @agent.get('/user/logout.php')
    end
    
  end
  
end