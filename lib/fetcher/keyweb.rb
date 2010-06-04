module Fetcher
  
  class Keyweb < Base
    
    START = 'https://kcm.keyweb.de/index.cgi'
    
    def list
      page  = @agent.get(START)
      form  = page.forms.first
      form.loginname   = @account.username
      form.loginpasswd = @account.password
      
      # Einloggen
      page = @agent.submit(form)
      
      # Link zur Rechnungsübersicht
      link = page.links_with(:href => /rechnungonline/)[0]
      
      # Login fehlgeschlagen?
      raise LoginException unless link
      page = link.click
      
      invoices = []
      
      for obj in page.search("form[name=RNR]")
        
        cells = obj.search("td")
        next if cells.empty?
        
        link = cells[0].search("a").first
        next if !link
        
        number = cells[6].text.match(/\d+/)[0]
        
        invoices << build_invoice(
          :href   => link['href'],
          :number => number,
          :date   => Date.parse(cells[4].text),
          :amount => extract_amount(cells[2].text)
        )
      end
      
      invoices
    end
    
  end
  
end