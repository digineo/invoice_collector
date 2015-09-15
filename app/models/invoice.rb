class Invoice < ActiveRecord::Base

  belongs_to :account

  has_attached_file :original,  :path => ':rails_root/data/invoices/:id/original.pdf'
  has_attached_file :signature, :path => ':rails_root/data/invoices/:id/signature.:extension'

  validates_presence_of :account_id
  validates_format_of   :number, :with => /^[A-Z0-9._-]+$/i
  validates_attachment_presence :original

  scope :latest, :order => 'date DESC', :limit => 10

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
