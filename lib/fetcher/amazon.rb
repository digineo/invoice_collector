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
      @agent.user_agent_alias = 'Android'
      @agent.follow_meta_refresh = true
      @agent.redirect_ok = true

      page = get(START)
      form = page.forms.first
      form.email    = @account.username
      form.password = @account.password

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

          number       = order.at("a[href*=orderID]")['href'].match(/orderID=([\d-]+)/)[1]
          popover      = order.at!("[data-a-popover*=invoice]")
          popover_page = get(JSON.parse(popover['data-a-popover'])['url'])
          link         = popover_page.at!("a[href*=invoice]")
          href         = link['href']

          next if link.text =~ /(anfordern|nicht verfügbar)/

          if RECIPIENT
            details = get("https://www.amazon.de/gp/css/summary/print.html?ie=UTF8&orderID=#{number}")
            address = details.search(".displayAddressDiv").last.text
            next if address !~ RECIPIENT
          end

          href = "https://www.amazon.de#{href}" if href.starts_with?("/")

          invoices << build_invoice(
            href:   href,
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
