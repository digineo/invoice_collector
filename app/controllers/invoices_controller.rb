class InvoicesController < InheritedResources::Base

  actions :index, :show
  respond_to :html, :xml, :json

  belongs_to :account

  def index
    @sum = end_of_association_chain.sum_amount
    super
  end

  def show
    super do |format|
      format.pdf {
        # Download der Rechnung
        send_file resource.original.path,
          :disposition => 'inline',
          :type        => :pdf,
          :filename    => resource.number+'.pdf'
      }
    end
  end

  # Download der Signatur
  def signature
    filename = resource.signature_file_name.split('.')
    filename[0] = resource.number

    send_file resource.original.path,
      :filename    => filename.join(".")
  end

  def print
    resource.print
    respond_to do |format|
      format.xml { head :ok }
      format.html {
        flash[:notice] = "Rechnung #{resource.number} wird gedruckt"
        redirect_to [@account, :invoices]
      }
    end
  end

end
