module Fetcher
  
  class Schlundtech < Base
    
    START = 'https://login.schlundtech.de/'
    
    def login
      page  = @agent.get(START)
      form  = page.form('login_form')
      form.user     = @account.username
      form.password = @account.password
      
      # Einloggen
      page = form.submit
      
      # Login fehlgeschlagen?
      raise LoginException if page.search("div[id=login_name]").empty?
    end
    
    def list
      page = @agent.get('/billing/')
      
      invoices = []
      
      for row in page.search("table[width='98%']/tr")
        
        link  = row.search("a")[1]
        cells = row.search("td")
        
        next unless link
        
        invoices << build_invoice(
          :href   => link['href'],
          :number => link.text.strip,
          :date   => cells[3].text,
          :amount => extract_amount(cells[4].text)
        )
      end
      
      invoices
    end
    
    def logout
      @agent.get('/login/logout.php')
    end
    
  end
  
end