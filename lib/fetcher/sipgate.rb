# encoding: UTF-8

module Fetcher

  class Sipgate < Base

    START = 'https://secure.sipgate.de/user/index.php'

    def login
      page  = get(START)
      form  = page.form('login')
      form.uname = @account.username
      form.passw = @account.password

      # Einloggen
      page = form.submit

      # Login fehlgeschlagen?
      raise LoginException if page.uri.path != '/user/start.php'
    end

    def list
      page = get('/user/invoice.php') # ?year=2009

      invoices = []

      for row in page.at!("table[class=newtable]").search("tr")

        link  = row.at("a")
        next unless link

        invoices << build_invoice(
          :href   => link['href'],
          :number => link['href'].match(/&nr=(\w+)$/)[1],
          :date   => link.text.match(/Rechnung vom (\S+)/)[1]
        )
      end

      invoices
    end

    def logout
      get('/user/logout.php')
    end

  end

end
