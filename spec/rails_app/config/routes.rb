Rails.application.routes.draw do
  # Resources for testing
  resources :users, :only => [:index]

  match "with_custom_options", :to => "users#with_custom_options"

  root :to => "users#index"
end
