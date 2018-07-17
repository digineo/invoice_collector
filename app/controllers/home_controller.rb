class HomeController < ApplicationController

  def index
    @invoices = Invoice.limit(10)
  end

end
