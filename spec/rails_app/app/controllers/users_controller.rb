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
