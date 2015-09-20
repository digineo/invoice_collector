# encoding: UTF-8

module Fetcher

  class Schlundtech < Base

    START = 'https://login.schlundtech.de/'

    def login
      page  = get(START)
      form  = page.form('login_form')
      form.user     = @account.username
      form.password = @account.password

      # Einloggen
      page = form.submit

      # Login fehlgeschlagen?
      raise LoginException unless page.at("div[id=login_name]")
    end

    def list
      page = get('/billing/')

      invoices = []

      for row in page.search("table[width='98%']/tr")

        links = row.search("a")
        link  = links[1]
        cells = row.search("td")

        next unless link

        invoices << build_invoice(
          href:     link['href'],
          number:   link.text.strip,
          date:     cells[3].text,
          amount:   cells[4].text,
        )
      end

      invoices
    end

    def logout
      get('/login/logout.php')
    end

  end

end
