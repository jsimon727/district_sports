Rails.application.routes.draw do
  root to: 'programs#index'
  resources :programs
  get 'auth/google_oauth2/callback', to: "omniauth#callback"
  get 'auth/google_oauth2/redirect', to: "omniauth#redirect"
  get 'auth/google_oauth2/calendar', to: "omniauth#calendar"
end
