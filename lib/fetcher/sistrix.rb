# encoding: UTF-8

module Fetcher

  class Sistrix < Base

    START = 'https://tools.sistrix.de/toolbox_account/login'

    def login
      page  = get(START)
      form  = page.forms.first
      form.user = @account.username
      form.pass = @account.password

      # Einloggen
      page  = @agent.submit(form, form.buttons.first)

      # Login fehlgeschlagen?
      raise LoginException if page.forms.any?
    end

    def list
      page = get "/toolbox/invoices"

      invoices = []

      for row in page.at!("table.ntable").search("tr[class='']")

        cells = row.search("td")

        invoices << build_invoice(
          :href   => row.at("a")['href'],
          :number => cells[2].text.strip,
          :date   => Date.parse(cells[1].text)
        )
      end

      invoices
    end

    def logout
      get("/").link_with(:text => /Abmelden/i).click
    end

  end

end
