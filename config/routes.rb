ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  map.resources :accounts do |accounts|
    accounts.resources :invoices, :member => {:print => :post, :signature => :get}
  end
  
  map.resources :imap_accounts
  map.resources :imap_filters
  
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

end
