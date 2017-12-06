# encoding: UTF-8

require 'mail'
require 'net/imap'

module Fetcher

  class Imap < Base

    DATE_PATTERN = /(\d\d)\.(\d{4})\.(\d\d)/

    def initialize(account)
      @account         = account.imap_account
      @filter          = account.imap_filter
      @subject_regexp  = @filter.subject_regexp
      @filename_regexp = @filter.filename_regexp
    end

    def login
      #@imap = Net::IMAP.new(@account.host, @account.port, @account.ssl)
      #@imap.authenticate('LOGIN', @account.username, @account.password)
      @imap = Net::IMAP.new(@account.host, @account.port, @account.ssl, nil, false)
      @imap.authenticate('PLAIN', @account.username, @account.password)
      @imap.examine('INBOX')
    end

    def list
      invoices = []

      # Nachrichten suchen
      message_ids = @imap.search(@filter.search_attr)

      # keine Nachrichten gefunden?
      return invoices if message_ids.empty?

      # Umschlag und Body-Struktur runterladen
      for mail in @imap.fetch(message_ids,["UID","ENVELOPE","BODYSTRUCTURE"])

        attributes = mail.attr
        envelope   = attributes["ENVELOPE"]
        subject    = Mail::Encodings.value_decode(envelope.subject)
        body       = attributes["BODYSTRUCTURE"]
        attachment = find_attachment(body.parts, @filename_regexp )

        # attachment nicht gefunden oder betreff passt nicht?
        next if !attachment || subject !~ @subject_regexp

        invoices << build_invoice(
          :href   => attributes["UID"],
          :number => part_name(attachment).match(@filename_regexp)[1],
          # Datum aus dem Betreff nehmen, wenn nicht vorhanden dann Datum der Email
          :date   => subject.match(DATE_PATTERN) ? Date.parse(subject) : envelope.date.to_date
        )
      end

      invoices
    end

    def download(invoice, uid)
      # Email komplett runterladen
      msg  = @imap.uid_fetch(uid,'RFC822')[0].attr['RFC822']
      mail = Mail::Message.new(msg)

      # Anhang holen
      read_attachment mail.attachments.find{|a|a.filename =~ @filename_regexp }
    end

    def logout
      @imap.logout
    end

    protected

    # Findet ein Attachment, dessen Namen auf den übergebenen regulären Ausdruck passt
    def find_attachment(parts, regex)
      parts.each do |part|
        return part if part_name(part) =~ regex
      end

      nil
    end

    # Ermittelt den (Datei)Namen eines Parts
    def part_name(part)
      parts = [part]
      parts << part.disposition if part.respond_to?(:disposition)
      parts << part.parts.first if part.respond_to?(:parts)

      for p in parts.compact
        param = p.param || next
        filename = param["NAME"] || param["FILENAME"]
        return filename if filename
      end

      nil
    end

    # Liest das Attachment aus und sorgt dafür,
    # dass es von Paperclip gespeichert werden kann
    def read_attachment(attachment)
      data = attachment.read

      # Dateiname setzen
      data.instance_variable_set("@filename", attachment.filename)
      def data.filename
        @filename
      end

      def data.body
        self
      end

      data
    end

  end

end
