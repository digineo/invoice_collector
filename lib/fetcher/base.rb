module Fetcher

  # Basisklasse für Fetcher
  class Base

    delegate :get, :post, to: :@agent

    def self.inherited(subclass)
      Fetcher.module_loaded subclass
    end

    def initialize(account)
      @account  = account
      @agent  ||= Mechanize.new
      #@agent.log = Logger.new $stderr
    end

    # Startet die Session
    # schlägt das Login fehlt, wird eine Fetcher::LoginException geworfen
    def login
      raise NotImplementedError
    end

    # Gibt eine Liste der verfügbaren Rechnungen zurück
    def list
      raise NotImplementedError
    end

    # Lädt eine Rechnung oder Signatur herunter
    def download(invoice,href)
      if href.respond_to?(:submit)
        href.submit
      else
        get(href)
      end
    end

    # Beendet die Session
    def logout
      raise NotImplementedError
    end

    protected

    def build_invoice(attributes)
      Invoice.new self, attributes
    end

  end

end
