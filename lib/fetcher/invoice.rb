module Fetcher
  
  class Invoice
    
    attr_reader :href, :number, :date, :amount
    
    def initialize(fetcher,attributes)
      @fetcher  = fetcher
      for key in [:href, :href_sig, :number, :date, :amount]
        instance_variable_set("@#{key}", attributes.delete(key))
      end
      
      raise ArgumentError, "ungültige Parameter: #{attributes.keys.join(' ')}" if attributes.any?
    end
    
    # Datei mit Dateiname und Inhalt
    def original
      file(@href) if @href
    end
    
    def signature
      file(@href_sig) if @href_sig
    end
    
    protected
    
    def file(href)
      file = @fetcher.download(self,href)
      
      def file.original_filename; filename.gsub('"',''); end
      def file.content_type; end
      def file.size; body.size; end
      def file.to_tempfile
        tempfile = Paperclip::Tempfile.new(File.basename(original_filename))
        tempfile.binmode
        tempfile.puts(body)
        tempfile
      end
      
      file
    end
    
  end
  
end