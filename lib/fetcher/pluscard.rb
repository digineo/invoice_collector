# encoding: UTF-8

module Fetcher

  class Pluscard < Base

    START = 'https://www.pluscard.de/kris/anmeldung/anmeldung.php'

    def login
      page  = get(START)
      form  = page.form("login")
      form.krednr   = @account.username
      form.kennwort = @account.password

      # Einloggen
      page = form.submit

      # Login fehlgeschlagen?
      raise LoginException if page.uri.path != '/kris/saldo/index.php'

      @csrf    = page.forms[0].CSRFToken

      # mehr als eine Kreditkarte vorhanden?
      @numbers = page.search("input[name=krednr]").collect{|input| input["value"] }
    end

    def list
      if @numbers.any?
        @numbers.inject([]) do |result,number|
          result += list_by_number(number)
        end
      else
        list_by_number
      end
    end

    def list_by_number(number=nil)
      invoices = []
      select_card number if number

      page = get '/kris/abrechnung/index.php'

      return [] if page.body.include?("Es liegen keine Abrechnungen vor.")

      # Zeilen ohne die Spaltenüberschriften
      rows = page.at!("table[cellspacing='1']").elements[1..-1]

      rows.each do |row|
        link = row.at!("a")
        href = link['href']
        date = row.search("./td")[1].text

        if href =~ /neue_abrechnung/
          # zwischenseite aufrufen *seufz*
          page = get href
          link = page.links.find{|l| l.href =~ /\/download\/.+\.pdf/}
          href = link.href
        end

        invoices << build_invoice(
          :href   => "#{href}|#{number}",
          :number => href.match(/(xxx[^\/]+)\.pdf/)[1],
          :date   => date
        )
      end
      invoices
    end

    def logout
      get '/kris/abmelden/index.php'
    end

    def download(invoice,href)
      download_url, number = href.split("|")
      select_card number if number != ""
      get download_url
    end

    protected

    # Wählt eine Kreditkarte aus, die ausgewählte wird in der Session gespeichert
    def select_card(number)
      get '/kris/common/navigation.php', abrechnung_neu: "J", krednr: number
    end

    def get(path, params={})
      url = path.sub(/^\.\./,'/kris')
      url << "?" << params.merge(CSRFToken: @csrf).to_param if @csrf && !url.include?("?")
      super url
    end

  end

end
