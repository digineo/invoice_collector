# encoding: UTF-8

module Fetcher

  class Affilinet < Base

    START = 'http://www.affili.net/'

    def login
      page   = get(START)
      form   = page.forms.first
      fields = form.fields
      fields.find{|f|f.name =~ /Login/}.value    = @account.username
      fields.find{|f|f.name =~ /Password/}.value = @account.password

      # Einloggen
      page = form.submit(form.buttons.first)

      # Login fehlgeschlagen?
      raise LoginException unless page.uri.to_s.ends_with?('/Start/default.aspx')
    end

    def list
      # Rechnungsübersicht
      page = get('/Account/payments.aspx')

      invoices = []

      for row in page.at!('table[class=PaymentTable]/tbody').search('tr[valign=middle]')

        cells = row.search("td")
        link  = row.at("a")

        # Auszahlungen, die noch "in Bearbeitung" sind, haben noch keinen PDF-Link
        next if !link || link.text != 'PDF'

        invoices << build_invoice(
          :href   => link['href'].split("=").last,
          :number => cells[2].text,
          :date   => Date.parse(cells[0].text),
          :amount => extract_amount(cells[7].text)
        )
      end

      invoices
    end

    def logout
      get('/Login/Logout.aspx')
    end

  end

end
