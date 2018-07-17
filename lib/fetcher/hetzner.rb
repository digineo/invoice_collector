# encoding: UTF-8

module Fetcher

  class Hetzner < Base

    START = 'https://accounts.hetzner.com/'

    def login
      # erst die Startseite aufrufen
      get(START)

      # Jetzt einloggen
      page = @agent.post(START+'login_check', _username: @account.username, _password: @account.password)

      # Login fehlgeschlagen?
      raise LoginException if page.uri.path != '/account/masterdata'
    end

    def list
      # Rechnungsübersicht aufrufen
      page = get('/invoice') # /invoice/index/page/2

      invoices = []

      page.search("ul.invoice-list > li").each do |row|
        invoices << build_invoice(
          number: row['id'],
          href:   row.at!("a[href*=pdf]")['href'],
          date:   row.at!('.invoice-date').text,
          amount: row.at!('.invoice-value').text,
        )
      end

      invoices
    end

    def logout
      get('/logout')
    end

  end

end
