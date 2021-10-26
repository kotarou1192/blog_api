Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post '/users/login', to: 'login#create'
  resources :users, only: %i[show create destroy update]
  post '/account/want_to_create', to: 'user_creation#create'
end
