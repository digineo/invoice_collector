module Fetcher

  class Invoice

    attr_reader :href, :number, :date, :amount

    def initialize(fetcher, attributes)
      @fetcher  = fetcher

      attributes.each do |key,value|
        case key
        when :href, :number
          # nothing special
        when :amount
          if String === value
            value = value.match(/[\d.,]*\d+[.,]\d+/)[0].gsub(/[.,]/,'').to_f/100
          end
        when :date
          if String === value
            value = Date.parse(value)
          end
        else
          raise ArgumentError, "invalid key: #{key}"
        end

        instance_variable_set "@#{key}", value
      end
    end

    # Datei mit Dateiname und Inhalt
    def original
      file(@href) if @href
    end

    protected

    def file(href)
      file = @fetcher.download(self,href)

      # Mechanize <-> Paperclip Monkeypatch
      def file.original_filename; filename.gsub('"',''); end
      def file.content_type; end
      unless file.respond_to?(:size)
        def file.size; body.size; end
      end

      def file.to_tempfile
        tempfile = Paperclip::Tempfile.new(File.basename(original_filename))
        tempfile.binmode
        tempfile.puts(body)
        tempfile
      end

      def file.read
        body
      end

      file
    end

  end

end
