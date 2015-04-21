# encoding: UTF-8

module Fetcher

  class DhlBusiness < Base

    START = 'https://www.dhl-geschaeftskundenportal.de/'

    def login
      page  = get(START)
      form  = page.forms.first

      form.fields.find{|f| f.name =~ /username/ }.value = @account.username
      form.fields.find{|f| f.name =~ /password/ }.value = @account.password

      # Einloggen
      page = @agent.submit(form)

      # Login fehlgeschlagen?
      raise LoginException if page.body.include?("Anmelden")
    end

    def list
      # Link zur Rechnungsübersicht
      page = get('/gkpl/appmanager/gkpl/customerDesktop?_nfpb=true&_pageLabel=gkpl_portal_page_billing')

      # Größeren Zeitraum auswählen
      form = page.forms.find{|form| form.action =~ /searchWithCalendar/ }
      form.fields.find{|f| Mechanize::Form::SelectList === f && f.name =~ /timeInterval/ }.value = "-3m"
      page = form.submit

      invoices = []

      page.at!("table.datagrid").search("tr").each do |row|
        next if row['class'].include?("header")
        cells = row.elements

        number = row.at!("input[name=billingId]")['value']
        next if number !~ /^\d+$/

        invoices << build_invoice(
          :href   => page.forms.find{|f| f.action=~/pdf/i && f.fields.any?{|f| f.value == number } },
          :number => number,
          :date   => Date.parse(cells[0].text),
          :amount => extract_amount(cells[3].text)
        )
      end

      invoices
    end

    def logout
      #get('/wi/54cd/logout.php')
    end

  end

end