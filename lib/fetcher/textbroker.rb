module Fetcher
  
  class Textbroker < Base
    
    START = 'https://www.textbroker.de/'
    
    def login
      page  = get(START)
      form  = page.form('login-kunden')
      form.e_mail = @account.username
      form.pass   = @account.password
      
      # Einloggen
      page = form.submit
      
      # Login fehlgeschlagen?
      raise LoginException if page.uri.path != '/c/home.php'
    end
    
    def list
      page = get('/c/invoices.php')
      
      invoices = []
      
      for row in page.search("table[class=basic]/tr")
        
        cells = row.search("td")
        link  = row.at("a")
        next unless link
        
        invoices << build_invoice(
          :href   => '/c/' + link['href'],
          :number => link.text.match(/Rechnung (\S+)/)[1],
          :date   => cells[1].text,
          :amount => extract_amount(cells[3].text)
        )
      end
      
      invoices
    end
    
    def logout
      get('/c/logout.php')
    end
    
  end
  
end