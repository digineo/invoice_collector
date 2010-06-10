class AccountsController < InheritedResources::Base
  
  def update
    update! { :accounts }
  end
  
  def create
    create! { :accounts }
  end
  
end