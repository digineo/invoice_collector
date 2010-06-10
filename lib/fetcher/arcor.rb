module Fetcher
  
  class Arcor < Base
    
    START = 'https://www.arcor.de/login/webbill_login.jsp'
    
    def login
      page  = @agent.get(START)
      form  = page.form('login')
      form.user_name = @account.username
      form.password  = @account.password
      
      # Einloggen
      page = form.submit
      
      # Login fehlgeschlagen?
      raise LoginException if page.uri.path.include?('/login/')
    end
    
    def list
      page = nil
      # ja, erst beim dritten mal kommt die gewünschte seite
      3.times do
        page = @agent.get('https://www.webbill.arcor.de/webbill/jahresCheck.sap')
      end
      
      invoices = []
      
      for row in page.search("form[name=billsForm]/table/tr")
        
        cells = row.search("td")
        next if cells.empty?
        
        links = row.search("a")
        next if links.empty?
        
        href = links.last['href']
        next if href !~ /Download/
        
        invoices << build_invoice(
          :href   => href,
          :number => cells[1].text.match(/Rechnung\D(\d+)/)[1],
          :date   => Date.parse(cells[0].text),
          :amount => extract_amount(cells[2].text)
        )
      end
      
      invoices
    end
    
    def logout
      @agent.get('/webbill/wblogout.sap')
    end
    
  end
  
end