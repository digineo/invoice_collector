module Invoice::Callbacks

  def self.included(base)
    base.class_eval do
      attr_accessor :recently_created
      before_save { |obj| obj.recently_created = true }
      after_save  { |obj| obj.after_create_with_paperclip if obj.recently_created }
    end
  end

  def after_create_with_paperclip

    update_amount! unless amount?
    run_webhook if account.webhook_data?

    self.recently_created = nil
  end

  def run_webhook
    data = YAML.load(account.webhook_data).symbolize_keys

    url = WEBHOOK_URL % {
      organization_id: data.delete(:organization_id)
    }

    # Betrag übernehmen, Vorzeichen wechseln wenn gewünscht
    flip_sign             = data.delete(:flip_sign)
    tax_key_number        = data.delete(:tax_key_number)
    contra_account_number = data.delete(:contra_account_number)

    data[:amount] = flip_sign ? -amount : amount if amount?

    if contra_account_number
      data[:positions_attributes] = { 0 => {
        amount:         data[:amount],
        account_number: contra_account_number,
        tax_key_number: tax_key_number,
      }}
    end

    result = RestClient.post url, {
      voucher: data.reverse_merge(
        attachment:       File.open(original.path),
        date:             date,
        reference_number: number,
      )
    }, accept: 'application/json'

#  rescue RestClient::UnprocessableEntity => e
#    puts e.http_body
#    raise e
    #Rails.logger.debug e.body
  end

end
