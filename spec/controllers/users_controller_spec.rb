require 'spec_helper'

if defined?(ActionController) && defined?(Rails)

  describe UsersController do

    before(:each) do
      @user_1 = User.create!(:first_name => 'Fred', :last_name => 'Flintstone')
      @user_2 = User.create!(:first_name => 'Wilma', :last_name => 'Flintstone')
    end

    describe "basic controller" do

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