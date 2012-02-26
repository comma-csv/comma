Rails.application.routes.draw do
  # Resources for testing
  resources :users, :only => [:index]

  root :to => "users#index"
end
