Rails.application.routes.draw do
  get 'home', to: 'home#index'
  resources :timestamps
  resources :tokens
  root "home#index"
end
