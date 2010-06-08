# Invoice Collector

Deine zentrale Sammelstelle für Online-Rechnungen.
Der InvoiceCollector loggt sich für dich bei verschiedenen Anbietern ein und lädt die vorgefundenen PDF-Rechnungen in ein lokales Archiv.
Je nach Anbieter werden auch Datum, Nummer und Betrag der Rechnung gespeichert.

## Unterstütze Anbieter
* Arcor
* Affilinet
* Binlayer
* Hetzner
* Hexonet
* HostEurope
* Keyweb
* LinkLift
* SimplyTel
* Strato
* Vodafone

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
