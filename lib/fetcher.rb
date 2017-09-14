# encoding: UTF-8

# Sammelt Rechnungen ein
module Fetcher

  # Liste der geladenen Module
  @@modules = []

  class LoginException < StandardError
  end

  # Ein Modul wurde geladen
  def self.module_loaded(subclass)
    @@modules << subclass
  end

  def self.modules
    @@modules
  end

  def self.module_names
    @@modules.collect{|m|m.to_s.split("::",2).last}
  end

end

require_dependency "#{Rails.root}/lib/fetcher/invoice"

# Alle Fetcher laden
for file in Dir.glob("#{Rails.root}/lib/fetcher/*.rb")
  require_dependency file
end
