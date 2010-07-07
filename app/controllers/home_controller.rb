class HomeController < ApplicationController
  
  def index
    @invoices = Invoice.latest
  end
  
end