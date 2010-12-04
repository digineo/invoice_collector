module Parser
  class Sipgate < Base
    
    def amount
      return unless text.include?('http://www.sipgate.de')
      text.scan(/(\d+,\d+) EUR/).last
    end
    
  end
end