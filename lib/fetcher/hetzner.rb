# encoding: UTF-8

module Fetcher

  class Hetzner < Base

    START = 'https://robot.your-server.de/'

    def login
      # erst die Startseite aufrufen
      get(START)

      # Jetzt einloggen
      page = @agent.post(START+'login/check?user='+CGI.escape(@account.username)+'&password='+CGI.escape(@account.password))

      # Login fehlgeschlagen?
      raise LoginException if page.uri.path != '/'
    end

    def list
      # Rechnungsübersicht aufrufen
      page = get('/invoice') # /invoice/index/page/2

      invoices = []

      page.search("div[class=box_wide]").each do |row|

        match  = row.child["onclick"].match %r(/invoice/download/number/(\w+)/date/(\w+))
        next unless match
        number = match[1]
        date   = Date.parse(match[2])
        href   = "/invoice/deliver?number=#{number}&date=#{match[2]}&type=pdf"

        invoices << build_invoice(
          :href   => href,
          :number => number,
          :date   => date
        )
      end

      invoices
    end

    def logout
      get('/login/logout')
    end

  end

end
