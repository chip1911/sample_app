Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'password_resets/create'
  get 'password_resets/update'
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "/help", to: "static_pages#help"
    get "/contact", to: "static_pages#contact"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    resources :users, only: %i(show edit update index destroy)
    resources :account_activations, only: :edit
    resources :password_resets, only: %i(new create edit update)
  end
end
