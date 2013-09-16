# -*- coding: utf-8 -*-
require 'action_controller/railtie'
require 'action_view/railtie'

# orm configs
require 'rails_app/active_record/config' if defined?(ActiveRecord)

app = Class.new(Rails::Application)
app.config.secret_token = '6f6acf0443f74fd0aa8ff07a7c2fbe0a'
app.config.session_store :cookie_store, :key => '_rails_app_session'
app.config.active_support.deprecation = :log
app.config.eager_load = false
app.config.root = File.dirname(__FILE__)
Rails.backtrace_cleaner.remove_silencers!
app.initialize!

app.routes.draw do
  resources :users, :only => [:index]
  get 'with_custom_options', :to => 'users#with_custom_options'
  get 'with_custom_style', :to => 'users#with_custom_style'
  root :to => 'users#index'
end

# models
require 'rails_app/active_record/models' if defined?(ActiveRecord)

# controllers
class ApplicationController < ActionController::Base; end
class UsersController < ApplicationController
  def index
    respond_to do |format|
      format.html { render :text => 'Users!' }
      format.csv  { render :csv => User.all  }
    end
  end

  def with_custom_options
    render_options = {:csv => User.all}.update(params[:custom_options].symbolize_keys)

    respond_to do |format|
      format.csv  { render render_options }
    end
  end

  def with_custom_style
    respond_to do |format|
      format.csv  { render :csv => User.all, :style => :shortened }
    end
  end
end

# helpers
Object.const_set(:ApplicationHelper, Module.new)
