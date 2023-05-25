Rails.application.routes.draw do
  resources :todos

  post '/line/webhook', to: 'line#webhook'

  root "todos#index"
end
