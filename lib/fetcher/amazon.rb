module Fetcher

  class Amazon < Base

    START = 'https://www.amazon.de/gp/css/order-history'

    MONTHS = {
      "Januar"    => "01",
      "Februar"   => "02",
      "März"      => "03",
      "April"     => "04",
      "Mai"       => "05",
      "Juni"      => "06",
      "Juli"      => "07",
      "August"    => "08",
      "September" => "09",
      "Oktober"   => "10",
      "November"  => "11",
      "Dezember"  => "12",
    }

    PER_PAGE  = 10
    FILTER    = "months-6" # year-2015 / months-6
    RECIPIENT = nil

    def login
      @agent.user_agent_alias = 'Mac Safari'
      @agent.follow_meta_refresh = true
      @agent.redirect_ok = true

      page = get(START)
      form = page.forms.first
      form.email    = @account.username
      form.password = @account.password
      form['ap_signin_existing_radio'] = "1"

      # Einloggen
      page = form.submit
      page = get(START)

      # Login fehlgeschlagen?
      raise LoginException unless page.uri.to_s.starts_with?(START)
    end

    def list
      invoices = []
      page     = 0

      begin
        orders = get("/gp/your-account/order-history?ie=UTF8&orderFilter=#{FILTER}&startIndex=#{page * PER_PAGE}").search(".order")
        orders.each do |order|
          columns = order.search(".a-column").map(&:elements).map{|elements| elements.map(&:text).map(&:strip) if elements.size == 2 }.compact.to_h
          amount  = columns["Summe"]
          date    = columns["Bestellung aufgegeben"]
          link    = order.at!("a[href*=invoice]")

          next if link.text =~ /(anfordern|nicht verfügbar)/

          href    = link['href']
          number  = href.match(/orderId=([\d-]+)/)[1]

          if RECIPIENT
            details = get("https://www.amazon.de/gp/css/summary/print.html?ie=UTF8&orderID=#{number}")
            address = details.search(".displayAddressDiv").last.text
            next if address !~ RECIPIENT
          end

          invoices << build_invoice(
            href:   "https://www.amazon.de#{href}",
            number: number,
            date:   self.class.parse_date(date),
            amount: amount,
          )
        end

        page += 1
      end while orders.any?

      invoices
    end

    def self.parse_date(str)
      d, m, y = str.split
      Date.parse("#{d}#{MONTHS[m]}.#{y}")
    end

    def logout
      get 'https://www.amazon.de/gp/flex/sign-out.html'
    end

  end

end
