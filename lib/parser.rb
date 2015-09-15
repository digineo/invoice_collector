# encoding: UTF-8

# Parst PDFs, um den Rechnungsbetrag zu ermitteln
module Parser

  # Liste der geladenen Parser
  @@modules = []

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

  # wandelt einen Geldbetrag in einen Float um
  # 42,50 => 42.5
  def self.normalize_amount(value)
    return unless value
    value.to_s.match(/[\d.,]*\d+[.,]\d+/)[0].gsub(/[.,]/,'').to_f/100
  end

  # Versucht den Rechnungsbetrag der Rechnung zu ermitteln
  def self.extract_amount(invoice)
    # Alle Parser-Module durchlaufen
    for m in modules
      amount = m.new(invoice).amount
      # zurückgeben, wenn gefunden
      return normalize_amount(amount) if amount
    end
    nil
  end

end

require_dependency "#{Rails.root}/lib/parser/base"

# Alle Fetcher laden
for file in Dir.glob("#{Rails.root}/lib/parser/*.rb")
  require_dependency file
end
