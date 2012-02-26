class UsersController < ApplicationController
  def index
    respond_to do |format|
      format.html { render :text => 'Users!' }
      format.csv  { render :csv => User.all  }
    end
  end
end
