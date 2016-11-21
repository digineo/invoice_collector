module Fetcher

  class JacobElektronik < Base

    START = 'https://direkt.jacob.de/login.html'

    def login
      page = get(START)
      form = page.forms_with(method: 'POST').first
      form.logindata    = @account.username
      form.passworddata = @account.password

      # Einloggen
      page = @agent.submit(form)

      # Login fehlgeschlagen?
      raise LoginException unless page.body.to_s.include?('Sie wurden erfolgreich')
    end

    def list
      # Link zur Rechnungsübersicht
      page = get "/bestellstatus.html"

      invoices = []
      page.search(".topline tr").each do |row|
        link  = row.at("a[href*=Rechnung]")
        cells = row.search("./td")
        next unless link

        invoices << build_invoice(
          href:    link['href'],
          number:  link.text,
          date:    cells[2].text,
          amount:  cells[3].text.match(/\d+,\d+/).try(:[], 0)
        )
      end

      invoices
    end

    def logout
      get '/account/logout'
    end

  end

end
