module Fetcher
  
  class Vodafone < Base
    
    START = 'https://www.vodafone.de/mvd/'
    
    def list
      page  = @agent.get(START)
      form  = page.form('loginBox')
      form.fields.find{|f|f.name=='name'}.value = @account.username
      form.password = @account.password
      
      # Einloggen
      page = form.submit
      
      # Login fehlgeschlagen?
      raise LoginException if page.uri.path.include?('/login/')
      
      # klappt erst beim zweiten mal
      2.times do
        page = @agent.get('/proxy42/portal/navigation.po?path=0.0.1.1')
      end
      
      invoices = []
      
      for row in page.search("div[id=divTab1]/table/tbody/tr")
        
        cells = row.search("td")
        next if cells.empty?
        
        links = row.search("a")
        next if links.empty?
        
        href = links.last['href']
        next if href !~ /download/
        
        date = Date.parse(cells[0].text)
        
        invoices << build_invoice(
          :href   => href,
          :number => date.to_s.gsub('-',''),
          :date   => date,
          :amount => extract_amount(cells[1].text)
        )
      end
      
      invoices
    end
    
  end
  
end