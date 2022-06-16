Rails.application.routes.draw do
  get 'home', to: 'home#index'
  resources :timestamps
  root "home#index"
end
