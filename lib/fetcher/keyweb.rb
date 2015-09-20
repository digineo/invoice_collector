# encoding: UTF-8

module Fetcher

  class Keyweb < Base

    START = 'https://kcm.keyweb.de/index.cgi'

    def login
      page  = get(START)
      form  = page.forms.first
      form.loginname   = @account.username
      form.loginpasswd = @account.password

      # Einloggen
      page = @agent.submit(form)

      # Link zur Rechnungsübersicht
      @invoices_link = page.links_with(:href => /rechnungonline/)[0]

      # Login fehlgeschlagen?
      raise LoginException unless @invoices_link
    end

    def list
      page = @invoices_link.click

      invoices = []

      for obj in page.search("form[name=RNR]")

        cells = obj.search("td")
        next if cells.empty?

        link = cells[0].at("a")
        next if !link

        number = cells[6].text.match(/\d+/)[0]

        invoices << build_invoice(
          href:   link['href'],
          number: number,
          date:   cells[4].text,
          amount: cells[2].text,
        )
      end

      invoices
    end

    def logout
      # gibt es nicht
    end

  end

end
