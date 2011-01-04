module Fetcher
  
  class Strato < Base
    
    START = 'https://config.stratoserver.net/'
    
    def login
      page  = get(START)
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
      attempts = 0
      
      begin
        page = @invoices_link.click.iframes.first.click
      rescue Mechanize::ResponseCodeError:
        # funk
        if attempts < 3
          attempts += 1
          retry
        end
      end
      
      invoices = []
      
      for row in page.at!("table[id=ctl00_ContentPlaceHolder1_content]").search("tr")
        
        cells = row.search("td")
        
        next if cells.size != 6
        
        links = cells[0].search("a")
        
        pdf_link = links.find{|l| l['title'] =~ /PDF/ }
        sig_link = links.find{|l| l['title'] =~ /Signatur/ }
        
        invoices << build_invoice(
          :href     => pdf_link['href'],
          :href_sig => sig_link['href'],
          :number => links.first.text,
          :date   => Date.parse(cells[2].text),
          :amount => extract_amount(cells[3].text)
        )
      end
      
      invoices
    end
    
    def download(invoice, href)
      get('https://dms.strfit.de/'+href)
    end
    
    def logout
      @logout_link.click
    end
    
  end
  
end