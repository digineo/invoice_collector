module Parser
  class AAAHosting < Base
    
    def amount
      return unless text.starts_with?('AAA-Hosting')
      text.scan(/Gesamtbetrag(\s+\d+,\d+)+/).last
    end
    
  end
end