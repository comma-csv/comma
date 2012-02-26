require 'spec_helper'

if defined?(ActionController) && defined?(Rails)

  describe UsersController do

    describe "rails setup" do

      it 'should capture the CSV renderer provided by Rails' do
        mock_users = [mock_model(User), mock_model(User)]
        User.stub!(:all).and_return(mock_users)

        mock_users.should_receive(:to_comma).once

        get :index, :format => :csv
      end

    end

    describe "basic controller" do
      before(:each) do
        @user_1 = User.create!(:first_name => 'Fred', :last_name => 'Flintstone')
        @user_2 = User.create!(:first_name => 'Wilma', :last_name => 'Flintstone')
      end

      it 'should not affect html requested' do
        get :index

        response.status.should        == 200
        response.content_type.should  == 'text/html'
        response.body.should          == 'Users!'
      end

      it "should return a csv when requested" do
        get :index, :format => :csv

        response.status.should            == 200
        response.content_type.should      == 'text/csv'
        response.request.fullpath.should  == '/users.csv'

        expected_content =<<-CSV.gsub(/^\s+/,'')
        First name,Last name,Name
        Fred,Flintstone,Fred Flintstone
        Wilma,Flintstone,Wilma Flintstone
        CSV

        response.body.should              == expected_content
      end

    end
  end
end