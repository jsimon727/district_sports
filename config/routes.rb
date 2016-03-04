Rails.application.routes.draw do
  root to: 'programs#index'
  resources :programs, only: [:index]
  resources :calendars, only: [:create]
  mount Resque::Server, :at => "/resque"
end
