class Invoice < ActiveRecord::Base

  belongs_to :account

  has_attached_file    :original,  :path => ':rails_root/data/invoices/:id/original.pdf'
  do_not_validate_attachment_file_type :original

  validates_presence_of :account_id
  validates_format_of   :number, :with => /\A[A-Z0-9\.\/_-]+\z/i
  validates_attachment_presence :original

  default_scope ->{ order("date DESC") }

  # Rechnungsbetrag ermitteln, falls er noch fehlt
  # geht wegen Paperclip nicht im after_create
  after_save :update_amount!

  # Datei an den Drucker schicken
  def print(args='')
    unless system("lpr #{original.path} #{args}")
      raise "printing failed with status #{$?.to_i}"
    end
  end

  # Gibt die Rechnung als Plaintext zurück
  def text
    @text ||= `pdftotext '#{original.path}' -`
  end

  # Versucht den Rechungsbetrag zu ermitteln, wenn er noch fehlt
  def update_amount!
    return amount if amount

    self.amount ||= Parser.extract_amount(self)
    save! if amount

    self.amount
  end

end

require_dependency 'invoice/callbacks'

Invoice.send :include, Invoice::Callbacks
