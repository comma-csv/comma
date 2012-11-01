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

    describe "controller" do
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
        response.header["Content-Disposition"].should include('filename=data.csv')

        expected_content =<<-CSV.gsub(/^\s+/,'')
        First name,Last name,Name
        Fred,Flintstone,Fred Flintstone
        Wilma,Flintstone,Wilma Flintstone
        CSV

        response.body.should              == expected_content
      end

      describe 'with comma options' do

        it 'should allow the style to be chosen from the renderer' do
          #Must be passed in same format (string/symbol) eg:
          # format.csv  { render User.all, :style => :shortened }

          get :with_custom_style, :format => :csv

          expected_content =<<-CSV.gsub(/^\s+/,'')
          First name,Last name
          Fred,Flintstone
          Wilma,Flintstone
          CSV

          response.body.should              == expected_content
        end

      end

      describe 'with custom options' do

        it 'should allow a filename to be set' do
          get :with_custom_options, :format => :csv, :custom_options => { :filename => 'my_custom_name' }

          response.status.should            == 200
          response.content_type.should      == 'text/csv'
          response.header["Content-Disposition"].should include('filename=my_custom_name.csv')
        end

        it 'should allow a file extension to be set' do
          get :with_custom_options, :format => :csv, :custom_options => { :extension => :txt }

          response.status.should            == 200
          response.content_type.should      == 'text/csv'
          response.header["Content-Disposition"].should include('filename=data.txt')
        end

        it 'should allow mime type to be set' do
          get :with_custom_options, :format => :csv, :custom_options => { :mime_type => Mime::TEXT }
          response.status.should            == 200
          response.content_type.should      == 'text/plain'
        end

        describe 'headers' do

          it 'should allow toggling on' do
            get :with_custom_options, :format => :csv, :custom_options => { :write_headers => 'true' }

            response.status.should            == 200
            response.content_type.should      == 'text/csv'

            expected_content =<<-CSV.gsub(/^\s+/,'')
            First name,Last name,Name
            Fred,Flintstone,Fred Flintstone
            Wilma,Flintstone,Wilma Flintstone
            CSV

            response.body.should              == expected_content
          end

          it 'should allow toggling off' do
            get :with_custom_options, :format => :csv, :custom_options => {:write_headers => false}

            response.status.should            == 200
            response.content_type.should      == 'text/csv'

            expected_content =<<-CSV.gsub(/^\s+/,'')
            Fred,Flintstone,Fred Flintstone
            Wilma,Flintstone,Wilma Flintstone
            CSV

            response.body.should              == expected_content
          end

        end

        it 'should allow forcing of quotes' do
          get :with_custom_options, :format => :csv, :custom_options => { :force_quotes => true }

          response.status.should            == 200
          response.content_type.should      == 'text/csv'

          expected_content =<<-CSV.gsub(/^\s+/,'')
          "First name","Last name","Name"
          "Fred","Flintstone","Fred Flintstone"
          "Wilma","Flintstone","Wilma Flintstone"
          CSV

          response.body.should              == expected_content
        end

        it 'should allow combinations of options' do
          get :with_custom_options, :format => :csv, :custom_options => { :write_headers => false, :force_quotes => true, :col_sep => '||', :row_sep => "ENDOFLINE\n" }

          response.status.should            == 200
          response.content_type.should      == 'text/csv'

          expected_content =<<-CSV.gsub(/^\s+/,'')
          "Fred"||"Flintstone"||"Fred Flintstone"ENDOFLINE
          "Wilma"||"Flintstone"||"Wilma Flintstone"ENDOFLINE
          CSV

          response.body.should              == expected_content
        end

      end

    end

  end
end
