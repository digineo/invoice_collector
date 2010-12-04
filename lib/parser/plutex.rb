module Parser
  class Plutex < Base
    
    def amount
      return if text !~ /Plutex GmbH.+Bremen/i
      text.scan(/Gesamtbetrag\s+(\d+,\d+)/).last
    end
    
  end
end