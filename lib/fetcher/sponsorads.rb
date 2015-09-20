# encoding: UTF-8

module Fetcher

  class SponsorAds < Base

    START = 'http://sponsorads.de/users.php'

    def login
      page  = get(START)
      form  = page.forms.first
      form.auth_user = @account.username
      form.auth_pass = @account.password

      # Einloggen
      page = form.submit

      # Login fehlgeschlagen?
      raise LoginException if page.at("input[name=auth_user]")
    end

    def list
      # Rechnungsübersicht aufrufen
      page     = get('/users.php?t=showPayments')

      invoices = []
      rows     = page.at!("table[cellpadding='6']").children

      # Tabellenkopf abschneiden
      rows.shift

      for row in rows

        cells = row.search("./td")
        link  = cells.last.at("a")
        next if !link

        invoices << build_invoice(
          href:   link['href'],
          number: cells[0].text,
          date:   cells[2].text,
          amount: row.at!("td/b").text,
        )
      end

      invoices
    end

    def logout
      get('users.php?a=doLogout')
    end

  end

end
