InvoiceCollector::Application.routes.draw do

  resources :accounts do
    resources :invoices do
      member do
        get :signature
        post :print
      end
    end
  end

  resources :imap_accounts
  resources :imap_filters

  match '/' => 'home#index'
end
