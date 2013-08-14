Rails.application.routes.draw do
  # Resources for testing
  resources :users, :only => [:index]

  get "with_custom_options", :to => "users#with_custom_options"
  get "with_custom_style", :to => "users#with_custom_style"

  root :to => "users#index"
end
