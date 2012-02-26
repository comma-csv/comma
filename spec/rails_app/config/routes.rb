Rails.application.routes.draw do
  # Resources for testing
  resources :users, :only => [:index]

  match "with_custom_options", :to => "users#with_custom_options"
  match "with_custom_style", :to => "users#with_custom_style"

  root :to => "users#index"
end
