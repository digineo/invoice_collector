# encoding: UTF-8

module Parser
  class Plutex < Base

    def amount
      return if text !~ /\nPLUTEX GmbH.+Bremen/i
      text.scan(/(Gesamtbetrag|Rechnungsbetrag)\s+(\d+,\d+)/).last.last rescue nil
    end

  end
end
