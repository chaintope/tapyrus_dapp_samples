Rails.application.routes.draw do
  get 'home', to: 'home#index'
  resources :tokens, only: [:index, :new, :create] do
    collection do
      get :transfer, to: 'tokens#new'
      post :transfer
    end
  end
  resources :wallets, only: [:index, :create]
  root "home#index"
end
