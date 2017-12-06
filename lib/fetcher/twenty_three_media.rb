module Fetcher

  class TwentyThreeMedia < Base

    START = 'https://captain.23media.de/login'

    def login
      page  = get START
      form  = page.forms.find{|f| f.action =~ /login/ }
      form._username = @account.username
      form._password = @account.password

      # Einloggen
      page  = form.submit

      # Login fehlgeschlagen?
      raise LoginException unless page.body.to_s.include?('Dashboard')
    end

    def list
      page = get '/en/accounting/creditor/invoice/datatable'
      JSON.parse(page.body).map do |row|
        build_invoice(
          date:   row[0],
          number: row[1],
          amount: (Parser.normalize_amount(row[3])*1.19).round(2),
          href:   row.last.match(%r(href="([^"]+)"))[1],
        )
      end
    end

    def logout
      get '/logout'
    end
  end
end
