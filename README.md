# Invoice Collector

Deine zentrale Sammelstelle für Online-Rechnungen.
Der InvoiceCollector loggt sich für dich bei verschiedenen Anbieter ein und lädt alle Rechnungen in ein lokales Archiv.

## Unterstütze Anbieter
* Arcor
* Affilinet
* Hetzner
* Hexonet
* HostEurope
* Keyweb
* SimplyTel
* Strato

## Installation

    git clone http://github.com/digineo/invoice_collector.git
    cd invoice_collector
    mkdir -p data/invoices
    rake gems:install
    rake db:create

## Bedienung

### Anlegen von Accounts

Zum Sammeln von Rechnungen müssen nur noch Accounts angelegt werden:

    script/console
    > Account.create! :module => 'arcor', :username => 'foo', :password => 'bar'
    > exit

### Rechnungen einsammeln
    script/runner Account.fetch_all

## Erweiterung
Vermisst du einen Anbieter mit Online-Rechnungen?
Dann erstell einfach ein weiteres Modul unter `/lib/fetcher/`, welches von `Fetcher::Base` erbt.
