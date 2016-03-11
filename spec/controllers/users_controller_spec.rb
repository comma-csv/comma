# frozen_string_literal: true

require 'spec_helper'

if defined?(Rails)

  RSpec.describe UsersController, type: :controller do # rubocop:disable Metrics/BlockLength
    describe 'rails setup' do
      it 'should capture the CSV renderer provided by Rails' do
        mock_users = [mock_model(User), mock_model(User)]
        allow(User).to receive(:all).and_return(mock_users)

        expect(mock_users).to receive(:to_comma).once

        get :index, format: :csv
      end
    end

    describe 'controller' do # rubocop:disable Metrics/BlockLength
      before(:all) do
        @user_1 = User.create!(first_name: 'Fred', last_name: 'Flintstone')
        @user_2 = User.create!(first_name: 'Wilma', last_name: 'Flintstone')
      end

      it 'should not affect html requested' do
        get :index

        expect(response.status).to eq 200
        expect(response.content_type).to eq 'text/html'
        expect(response.body).to eq 'Users!'
      end

      it 'should return a csv when requested' do
        get :index, format: :csv

        expect(response.status).to eq 200
        expect(response.content_type).to eq 'text/csv'
        expect(response.header['Content-Disposition']).to include('filename="data.csv"')

        expected_content = <<-CSV.gsub(/^\s+/, '')
        First name,Last name,Name
        Fred,Flintstone,Fred Flintstone
        Wilma,Flintstone,Wilma Flintstone
        CSV

        expect(response.body).to eq expected_content
      end

      describe 'with comma options' do
        it 'should allow the style to be chosen from the renderer' do
          # Must be passed in same format (string/symbol) eg:
          # format.csv  { render User.all, :style => :shortened }

          get :with_custom_style, format: :csv

          expected_content = <<-CSV.gsub(/^\s+/, '')
          First name,Last name
          Fred,Flintstone
          Wilma,Flintstone
          CSV

          expect(response.body).to eq expected_content
        end
      end

      describe 'with custom options' do # rubocop:disable Metrics/BlockLength
        def is_rails_4?
          Rails::VERSION::STRING =~ /^4.*/
        end

        def get_(name, **args)
          if is_rails_4? && args[:params]
            args.merge!(args[:params])
            args.delete(:params)
          end
          get name, **args
        end

        it 'should allow a filename to be set' do
          get_ :with_custom_options, format: :csv, params: { custom_options: { filename: 'my_custom_name' } }

          expect(response.status).to eq 200
          expect(response.content_type).to eq 'text/csv'
          expect(response.header['Content-Disposition']).to include('filename="my_custom_name.csv"')
        end

        it 'should allow a custom filename with spaces' do
          require 'shellwords'
          params = { custom_options: { filename: 'filename with a lot of spaces' } }
          get_ :with_custom_options, format: :csv, params: params

          expect(response.status).to eq 200
          expect(response.content_type).to eq 'text/csv'
          expect(response.header['Content-Disposition']).to include('filename="filename with a lot of spaces.csv"')

          filename_string = response.header['Content-Disposition'].split('=').last
          # shellsplit honors quoted strings
          expect(filename_string.shellsplit.length).to eq 1
        end

        it 'should allow a file extension to be set' do
          get_ :with_custom_options, format: :csv, params: { custom_options: { extension: :txt } }

          expect(response.status).to eq 200
          expect(response.content_type).to eq 'text/csv'
          expect(response.header['Content-Disposition']).to include('filename="data.txt"')
        end

        it 'should allow mime type to be set' do
          get_ :with_custom_options, format: :csv, params: { custom_options: { mime_type: 'text/plain' } }
          expect(response.status).to eq 200
          expect(response.content_type).to eq 'text/plain'
        end

        it 'should allow bom to be set' do
          get_ :with_custom_options, format: :csv, params: { custom_options: { with_bom: true } }

          expected_content = <<-CSV.gsub(/^\s+/, '')
          \xEF\xBB\xBFFirst name,Last name,Name
          Fred,Flintstone,Fred Flintstone
          Wilma,Flintstone,Wilma Flintstone
          CSV

          expect(response.body). to eq expected_content
        end

        describe 'headers' do
          it 'should allow toggling on' do
            get_ :with_custom_options, format: :csv, params: { custom_options: { write_headers: 'true' } }

            expect(response.status).to eq 200
            expect(response.content_type).to eq 'text/csv'

            expected_content = <<-CSV.gsub(/^\s+/, '')
            First name,Last name,Name
            Fred,Flintstone,Fred Flintstone
            Wilma,Flintstone,Wilma Flintstone
            CSV

            expect(response.body).to eq expected_content
          end

          it 'should allow toggling off' do
            get_ :with_custom_options, format: :csv, params: { custom_options: { write_headers: false } }

            expect(response.status).to eq 200
            expect(response.content_type).to eq 'text/csv'

            expected_content = <<-CSV.gsub(/^\s+/, '')
            Fred,Flintstone,Fred Flintstone
            Wilma,Flintstone,Wilma Flintstone
            CSV

            expect(response.body).to eq expected_content
          end
        end

        it 'should allow forcing of quotes' do
          get_ :with_custom_options, format: :csv, params: { custom_options: { force_quotes: true } }

          expect(response.status).to eq 200
          expect(response.content_type).to eq 'text/csv'

          expected_content = <<-CSV.gsub(/^\s+/, '')
          "First name","Last name","Name"
          "Fred","Flintstone","Fred Flintstone"
          "Wilma","Flintstone","Wilma Flintstone"
          CSV

          expect(response.body).to eq expected_content
        end

        it 'should allow combinations of options' do
          params = {
            custom_options: {
              write_headers: false,
              force_quotes: true,
              col_sep: '||',
              row_sep: "ENDOFLINE\n"
            }
          }
          get_ :with_custom_options, format: :csv, params: params

          expect(response.status).to eq 200
          expect(response.content_type).to eq 'text/csv'

          expected_content = <<-CSV.gsub(/^\s+/, '')
          "Fred"||"Flintstone"||"Fred Flintstone"ENDOFLINE
          "Wilma"||"Flintstone"||"Wilma Flintstone"ENDOFLINE
          CSV

          expect(response.body).to eq expected_content
        end
      end
    end
  end
end
