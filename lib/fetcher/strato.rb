module Fetcher
  
  class Strato < Base
    
    START = 'https://config.stratoserver.net/'
    
    def login
      page  = @agent.get(START)
      form  = page.form('main')
      form.domainname = @account.username
      form.pass       = @account.password
      
      # Einloggen
      page = @agent.submit(form)
      
      # Login fehlgeschlagen?
      raise LoginException if page.uri.to_s.ends_with?('/index.php')
      
      # wichtige Links
      @invoices_link = page.links.find{|l|l.text=='Online invoices'}
      @logout_link   = page.links.find{|l|l.text=='Logout'}
    end
    
    def list
      page = @invoices_link.click.iframes.first.click
      
      invoices = []
      
      for row in page.search("tr")
        
        cells = row.search("td")
        next if cells.empty?
        
        link = cells[0].search("a").first
        next if !link || link.text !~ /^DRP/
        
        invoices << build_invoice(
          :href   => link['href'],
          :number => link.text,
          :date   => Date.parse(cells[2].text),
          :amount => extract_amount(cells[3].text)
        )
      end
      
      invoices
    end
    
    def get(invoice)
      @agent.get('https://dms.strfit.de/'+invoice.href)
    end
    
    def logout
      @logout_link.click
    end
    
  end
  
end