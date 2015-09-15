# encoding: UTF-8

module Parser
  class Hetzner < Base

    def amount
      return unless text.include?('http://www.hetzner.de')
      text.scan(/(\d+,\d+) Euro/).last
    end

  end
end
