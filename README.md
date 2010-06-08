# Invoice Collector

Deine zentrale Sammelstelle für Online-Rechnungen.
Der InvoiceCollector loggt sich für dich bei verschiedenen Anbietern ein und lädt die vorgefundenen PDF-Rechnungen in ein lokales Archiv.
Je nach Anbieter werden auch Datum, Nummer und Betrag der Rechnung gespeichert.

## Unterstütze Anbieter

* arcor (Vodafone D2 GmbH)
* affilinet (affilinet GmbH)
* binlayer (Binlayer GmbH)
* hetzner (Hetzner Online AG)
* hexonet (HEXONET GmbH)
* hosteurope (Host Europe GmbH)
* keyweb (Keyweb AG)
* linklift (LinkLift Ltd.)
* simplytel (simply Communication GmbH)
* sipgate (Sipgate GmbH)
* strato (Strato AG)
* swb (swb AG)
* textbroker (Sario Marketing GmbH)
* vodafone (Vodafone D2 GmbH)

## Installation

Voraussetzungen sind `git, rake, ruby, rubygems` sowie das `rails`-gem in der Version 2.3.8.
Für die Druckunterstützung wird außerdem `lpr-cups` mit einem installierten Drucker benötigt.

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

### Frontend
starten mit:

    script/server

beenden mit STRG+C

## Erweiterung
Vermisst du einen Anbieter mit Online-Rechnungen?
Dann erstell einfach ein weiteres Modul unter `/lib/fetcher/`, welches von `Fetcher::Base` erbt.
