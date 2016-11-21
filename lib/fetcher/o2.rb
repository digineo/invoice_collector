# encoding: UTF-8

module Fetcher

  class O2 < Base

    START = 'https://login.o2online.de/auth/login'

    def login
      # erst die Startseite aufrufen
      page = get START

      # Jetzt einloggen
      form          = page.forms.first
      form.IDToken1 = @account.username
      form.IDToken2 = @account.password
      page = form.submit

      # Login fehlgeschlagen?
      raise LoginException if page.uri.path != '/'
    end

    def list
      page = get '/invoice'
      raise "x"
    end

    def logout
      get('/login/logout')
    end

  end

end
