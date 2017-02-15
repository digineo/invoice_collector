# encoding: UTF-8

module Fetcher

  class Hexonet < Base

    START = 'https://wi.hexonet.net/wi/54cd/include.php'

    def login
      page  = get(START)
      form  = page.forms.first
      form.LOGIN_USER     = @account.username
      form.LOGIN_PASSWORD = @account.password

      # Einloggen
      page = @agent.submit(form)

      # Login fehlgeschlagen?
      raise LoginException if page.title =~ /Anmelden/
    end

    def list
      # Link zur Rechnungsübersicht
      offset   = 0
      invoices = []
      begin
        page = get("/wi/54cd/xirca/invoice/invoicelist.php?c_first=#{offset}")

        for row in page.at!("table[align=center][width='600']").search("tr")

          cells = row.search("td")
          next if cells.empty?

          link = cells[0].at("a")
          next if !link

          number = link.text
          next if number !~ /^\d+$/

          invoices << build_invoice(
            href:   link['href'],
            number: number,
            date:   cells[1].text,
            amount: cells[3].text,
          )
        end
        offset += 100
      end while offset == invoices.count

      invoices
    end

    def logout
      get('/wi/54cd/logout.php')
    end

  end

end
