module Fetcher
  
  class Linklift < Base
    
    START = 'https://www.linklift.de/einloggen/'
    
    def login
      page  = @agent.get(START)
      form  = page.form('mainform')
      form.LL_email    = @account.username
      form.LL_password = @account.password
      
      # Einloggen
      page = form.submit
      
      # Login fehlgeschlagen?
      raise LoginException if page.search("h1").text=='Einloggen'
    end
    
    def list
      page = @agent.get('/mein-konto/rechnungen/?t=adv')
      
      h3 = page.search("h3").first.text
      raise "ungültige seite: #{h3}" if h3 != 'Meine Rechnungen'
      
      invoices = []
      
      for row in page.search("div[class=ll_default_small]/table/tbody/tr")
        
        cells = row.search("td")
        link  = row.search("a").find{|a| a['href'] =~ /pdf/ }
        next unless link
        
        kind   = cells[0].text
        amount = extract_amount(cells[4].text)
        
        case kind
          when 'Rechnung'
            # nichts
          when 'Gutschrift'
            amount *= -1
          else
            raise "ungültiger Typ: #{kind}"
        end
        
        invoices << build_invoice(
          :href   => link['href'],
          :number => cells[2].text,
          :date   => cells[1].text,
          :amount => amount
        )
      end
      
      invoices
    end
    
    def logout
      @agent.get('/ausloggen/')
    end
    
  end
  
end