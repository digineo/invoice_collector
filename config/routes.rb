ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  map.resources :accounts do |accounts|
    accounts.resources :invoices
  end
  
  
  map.root :controller => "accounts"

  # See how all your routes lay out with "rake routes"

end
