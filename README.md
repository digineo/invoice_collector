# Invoice Collector

Deine zentrale Sammelstelle für Online-Rechnungen.
Der InvoiceCollector loggt sich für dich bei verschiedenen Anbietern ein und lädt die vorgefundenen PDF-Rechnungen in ein lokales Archiv.
Je nach Anbieter werden auch Datum, Nummer, Betrag und Signatur der Rechnung gespeichert.

## Unterstütze Anbieter

* arcor (Vodafone D2 GmbH)
* affilinet (affilinet GmbH)
* binlayer (Binlayer GmbH)
* hetzner (Hetzner Online AG)
* hexonet (HEXONET GmbH)
* hosteurope (Host Europe GmbH)
* keyweb (Keyweb AG)
* linklift (LinkLift Ltd.)
* schlundtech (Schlund Technologies GmbH)
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
    rake gems:install
    rake db:create
    rake db:migrate

## Bedienung

### Rechnungen einsammeln
    script/runner Account.fetch_all

Wenn eine `Fetcher::LoginException` geworfen wird, sind möglicherweise die Zugangsdaten für den angezeigten Account ungültig.

### Frontend

Das Frontend wird gestartet mit:

    script/server -b 127.0.0.1

Damit ist es per unter `http://localhost:3000/` erreichbar.
Beenden werden kann es mit `STRG + C`.

## Erweiterung
Vermisst du einen Anbieter mit Online-Rechnungen?
Dann erstell einfach ein weiteres Modul unter `/lib/fetcher/`, welches von `Fetcher::Base` erbt.
