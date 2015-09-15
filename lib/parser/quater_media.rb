# encoding: UTF-8

module Parser
  class QuaterMedia < Base

    def amount
      return unless text.starts_with?('QUARTER MEDIA GmbH')
      block = text.split("\n\n").find{|b| b =~ /^\d{2}\/\d{4}/ }
      block.split("\n").last
    end

  end
end
