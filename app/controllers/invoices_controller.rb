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
        send_file resource.filename,
          :disposition => 'inline',
          :type        => :pdf,
          :filename    => resource.number+'.pdf'
      }
    end
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