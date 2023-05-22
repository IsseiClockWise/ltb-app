Rails.application.routes.draw do
  resources :todos

  post 'callback' => 'line_bot#callback'

  root "todos#index"
end
