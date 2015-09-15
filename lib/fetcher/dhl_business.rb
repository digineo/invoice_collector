# encoding: UTF-8

module Fetcher

  class DhlBusiness

    Fetcher.module_loaded self

    def initialize(account)
      @account  = account
    end

    def login
      session.visit    "https://www.dhl-geschaeftskundenportal.de/"
      session.fill_in  'Benutzername', with: @account.username
      session.fill_in  'Passwort',     with: @account.password
      session.click_on "Anmelden"
      session.has_content? "Startseite"
      sleep 1
    end

    def list
      invoices = []

      session.click_on "Services"
      session.click_on "Rechnungssuche"
      session.has_content? "Startseite"
      session.select   '3 Monate'
      session.click_on "Suchen"
      session.execute_script 'AdfDhtmlPage.prototype._doFullPostback = function(a,b,c){
      for(var i=0; i < a.elements.length; i++){
        var e = a.elements[i];
        if(e.name)
          b[e.name] = e.value;
      }
      window.data={
        action: a.action,
        params: b,
      }}'

      session.find("table[summary=Rechnugen]").find_all("tr").each do |row|
        session.execute_script 'delete window.data'

        cells  = row.find_all("td")
        date   = cells[0].text
        number = cells[1].text
        amount = cells[4].text
        cells[5].find("a").click

        while true
          data = session.evaluate_script("JSON.stringify(window.data)")
          if data
            data = JSON.parse(data)
            break
          end
          sleep 0.1
        end

        # Download invoice
        # Lazy loading does not work
        uri   = URI.parse(data['action'])
        https = Net::HTTP.new(uri.host, 443)
        https.use_ssl = true
        # https.set_debug_output $stderr
        req = Net::HTTP::Post.new(uri.path + "?" + uri.query, headers)
        req.form_data = data['params']

        body = https.request(req)
        body.instance_variable_set "@filename", "#{number}.pdf"
        def body.filename
          @filename
        end

        invoices << Invoice.new(self,
          href:   body,
          number: number,
          date:   date,
          amount: amount.match(/[\d.,]*\d+[.,]\d+/)[0].gsub(/[.,]/,'').to_f/100 * 1.19,
        )
      end

      invoices
    rescue
      session.save_and_open_screenshot
      session.save_and_open_page
      raise
    end

    def logout
    end

    def download(invoice,data)
      data
    end

    def headers
      {
        "Cookie"  =>  session.driver.cookies.map{|_,c| "#{c.name}=#{c.value}" }.join("; ")
      }
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

  end

end
