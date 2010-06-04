module Fetcher
  
  class Hexonet < Base
    
    START = 'https://wi.hexonet.net/wi/54cd/include.php'
    
    def list
      page  = @agent.get(START)
      form  = page.forms.first
      form.LOGIN_USER     = @account.username
      form.LOGIN_PASSWORD = @account.password
      
      # Einloggen
      page = @agent.submit(form)
      
      # Login fehlgeschlagen?
      raise LoginException if page.title =~ /Anmelden/
      
      # Link zur Rechnungsübersicht
      page = @agent.get('/wi/54cd/xirca/invoice/invoicelist.php')
      
      invoices = []
      
      for row in page.search("table[align=center][width='600']/tr")
        
        cells = row.search("td")
        next if cells.empty?
        
        link = cells[0].search("a").first
        next if !link
        
        number = link.text
        next if number !~ /^\d+$/
        
        invoices << build_invoice(
          :href   => link['href'],
          :number => number,
          :date   => Date.parse(cells[1].text),
          :amount => extract_amount(cells[3].text)
        )
      end
      
      invoices
    end
    
  end
  
end