Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :auth, only: %i[create destroy]
  resources :users, only: %i[show create destroy update]
  post '/account/want_to_create', to: 'user_creation#create'

  if Rails.env == 'development'
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
