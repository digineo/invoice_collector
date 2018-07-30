module Fetcher

  class Telekom < Base

    LOGIN          = 'https://www.telekom.de/kundencenter/login'
    RECHNUNG_START = 'https://kundencenter.telekom.de/kundencenter/gk/rechnung/start.html'

    def login
      page        = get(LOGIN)
      form        = page.forms[0]
      form.pw_usr = @account.username
      page        = form.submit

      form        = page.forms[1]
      form.pw_pwd = @account.password
      page        = form.submit

      # Login fehlgeschlagen?
      raise LoginException if page.uri.to_s != 'https://www.telekom.de/kundencenter/startseite'
    end

    def list
      # Rechnungsübersicht
      get(RECHNUNG_START)

      page = xhr

      while uri = page['redirect'] do
        # puts "follow #{uri}"
        tid  = get(uri).uri.query.match(/tid=(\w+)/)[1]
        page = xhr(parameter: {tid: tid})
      end

      page['data']['Rechnungskonten'].map{|konto| konto['UebersichtsDokumente'] }.flatten.map do |record|
        build_invoice(
          href:   record['Id'],
          number: %w(RechnungsJahr RechnungsMonat).map{|k| record[k] }.join("-"),
          date:   record['RechnungsDatum'],
          amount: record['GesamtBetrag'],
        )
      end
    end

    # Lädt eine Rechnung herunter
    def download(invoice, href)
      page = xhr(
        parameter:     {action: 'change'},
        format:        'PDF',
        change_action: 'DownloadUebersichtsDokumente',
        doc_ids:       href,
      )
      get(page['data']['DownloadDaten']['DownloadUrl'])
    end

    def xhr(parameter: {}, format: '', doc_ids: '', change_action: '')
      body = {
        "pageid":  "REO_M1000",
        "referer": URI.parse(RECHNUNG_START).path,
        "request": ["rechnung"],
        "data": {
          "DokumentFormat":    format,
          "DokumentAuftragId": "",
          "DokumentIds":       doc_ids,
          "DigitaleSignatur":  false,
          "ChangeAction":      change_action,
          "Zeitraum":          "200",
          "RequestCounter":    1,
        },
      }

      if parameter
        body['parameter'] = parameter
      end

      while true do
        response = @agent.post(
          "/app/json", body.to_json,
          'Content-Type'        => 'application/json; charset=UTF-8',
          'Referer'             => RECHNUNG_START,
          'X-Requested-With'    => 'XMLHttpRequest',
        )
        res = JSON.parse(response.body)

        if wait = res['wait']
          # puts "sleeping #{wait}"
          sleep(wait/1000)
        else
          return res
        end
      end
    end

    def logout
      get('https://accounts.login.idm.telekom.com/sessionmessage/logout')
    end

  end

end
