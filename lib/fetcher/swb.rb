module Fetcher
  
  class Swb < Base
    
    START = 'https://www.swb-gruppe.de/online-service/hb/css/startLogin.jsp'
    
    def login
      page  = get(START)
      form  = page.form('frm_login')
      form['Process.User.RegGPNumber'] = @account.username
      form['Process.User.Password']    = @account.password
      
      # Einloggen
      page = form.submit
      
      # Login fehlgeschlagen?
      raise LoginException if page.search("h3").first.text =~ /Login/
    end
    
    def list
      page = post('DokAnsicht')
      
      h3 = page.at("h3").text
      raise "ungültige Seite: #{h3}" if h3 != 'Dokumente'
      
      invoices = []
      
      for row in page.search("table[class=tbl-downloads]/tbody/tr")
        
        cells  = row.search("td")
        link   = row.at("a")
        params = link['href'].match(/download\('(.+)','(.+)'\)/)
        
        invoices << build_invoice(
          :href   => 'docs/' + params[1] + '?docTypeId=' + params[2],
          :number => params[1],
          :date   => cells[1].text.match(/Rechnung vom ([\d\.]{10})/)[1]
        )
      end
      
      invoices
    end
    
    def logout
      post 'Logout'
    end
    
    private
    
    def post(action)
      @agent.post(
        "/online-service/hb/css/do?action=save&proc=Startseite%20Online-Service&current=mainmenu&UID=&go2=1",
        "goto=1&Process.User.Selection=#{action}&typosize=elements&Process.User.Topic=&isGotoNextScreen=false&currentScreen=0",
        'Content-Type' => 'application/x-www-form-urlencoded'
      )
    end
    
  end
  
end