class AccountsController < InheritedResources::Base

  def update
    update! { collection_path }
  end

  def create
    create! { collection_path }
  end

end
