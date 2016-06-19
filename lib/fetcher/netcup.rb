module Fetcher

  class Netcup < Base

    START = 'https://ccp.netcup.net/run/'

    def login
      page = get(START)
      form = page.forms.first
      form.ccp_user     = @account.username
      form.ccp_password = @account.password

      # Einloggen
      page = @agent.submit(form)

      # Login fehlgeschlagen?
      raise LoginException unless page.body.to_s.include?('Willkommen')
    end

    def list
      # Link zur Rechnungsübersicht
      page = get "/run/rechnungen.php"

      invoices = []
      page.at("#content table").search("tr[class]").each do |row|
        link  = row.at!("a[href*=pdf]")
        cells = row.elements

        invoices << build_invoice(
          href:    link['href'],
          number:  link['href'].match(/&rnr=(.+)$/)[1],
          date:    cells[5].text,
          amount:  cells[6].text,
        )
      end

      invoices
    end

    def logout
      get '/run/logout.php'
    end

  end

end
