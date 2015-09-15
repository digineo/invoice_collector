# encoding: UTF-8

module Fetcher

  class Strato < Base

    START = 'https://www.strato.de/apps/CustomerService'

    def login
      page  = get(START)
      form  = page.forms.first
      form.identifier = @account.username
      form.passwd     = @account.password

      # Einloggen
      page  = @agent.submit(form, form.buttons.first)

      # Login fehlgeschlagen?
      raise LoginException unless page.uri.to_s.ends_with?('node=kds_CustomerEntryPage')

      @session_id = CGI.parse(page.uri.query)["sessionID"].first.to_s
    end

    def list
      page = get "/apps/CustomerService?sessionID=#{@session_id}&node=OnlineInvoice&source=menu"

      invoices = []

      for row in page.at!("table.sf-table tbody").search("tr")

        cells = row.search("td")
        links = row.search("a")

        next if cells.size != 6

        pdf_link = links.find{|l| l['title'] =~ /pdf/i }
        sig_link = links.find{|l| l['title'] =~ /signatur/i }

        invoices << build_invoice(
          :href     => pdf_link['href'],
          :href_sig => sig_link ? sig_link['href'] : nil,
          :number => links.first.text.strip,
          :date   => Date.parse(cells[0].text),
          :amount => extract_amount(cells[3].text)
        )
      end

      invoices
    end

    def logout
      get "/apps/CustomerService?sessionID=#{@session_id}&node=kds_Logout"
    end

  end

end
