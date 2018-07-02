require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    let(:expense) { {'some' => 'data'} }
    let(:date) { '2018-06-25' }

    describe 'POST /expenses' do
      context 'when the expenses are successfully required' do
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)
          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('expense_id' => 417)
        end

        it 'responds with 200 OK' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          parsed = JSON.parse(last_response.body)
          expect(parsed).to include('error' => 'Expense incomplete')
        end

        it 'responds with 422 unprocessable entity' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET /expenses/:date' do
      context 'when expenses exist on the give date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(%w[expense_1 expense_2])
        end

        it 'returns the expense records as JSON' do
          get '/expenses/2018-06-25'
          parsed = JSON.parse(last_response.body)
          expect(parsed).to eq(%w[expense_1 expense_2])
        end

        it 'responds with a 200 OK' do
          get '/expenses/2018-06-25'
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the give date' do
        before do
          allow(ledger).to receive(:expenses_on)
          .with(date)
          .and_return([])
        end
        it 'returns an empty array as JSON' do
          get '/expenses/2018-06-25'
          parsed = JSON.parse(last_response.body)
          expect(parsed).to eq([])
        end
        it 'responds with a 200 OK' do
          get '/expenses/2018-06-25'
          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
