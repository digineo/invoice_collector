# encoding: UTF-8

module Fetcher

  class Oekopost < Base

    START = 'https://www.oekopost.de/login/'

    def login
      page  = get(START)
      form  = page.forms.first
      form.username = @account.username
      form.password = @account.password

      # Einloggen
      page = @agent.submit(form)

      # Login fehlgeschlagen?
      raise LoginException unless page.at("#userInfo")
    end

    def list
      # Link zur Rechnungsübersicht
      page = get('/user/account/invoices/')
      rows = page.at!("#invoicesBox table").search("tr")
      rows.shift

      invoices = []

      for row in rows
        cells = row.search("td")
        link  = cells[0].at!("a")

        number = link.text
        next if number !~ /^[\d\.]+$/

        date = case cells[1].text
          when /Heute/ then Date.today
          else Date.parse(cells[1].text)
        end

        invoices << build_invoice(
          :href   => link['href'],
          :number => number,
          :date   => date
        )
      end

      invoices
    end

    def logout
      get('/user/logout/')
    end

  end

end
