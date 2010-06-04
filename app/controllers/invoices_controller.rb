class InvoicesController < InheritedResources::Base
  
  belongs_to :account
  
  def index
    @sum = end_of_association_chain.sum_amount
    super
  end
  
  def show
    super do |format|
      format.pdf {
        send_file resource.filename, :filename => resource.number+'.pdf'
      }
    end
  end


end