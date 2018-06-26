# frozen_string_literal: true

require 'rack/test'
require 'json'

require_relative '../../app/api'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API' do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)

      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))

      expense.merge('id' => parsed['expense_id'])
    end

    it 'records submitted expenses' do
      pending 'Need to persist expenses'

      coffee = post_expense(
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date' => '2018-06-25'
      )

      zoo = post_expense(
        'payee' => 'Zoo',
        'amount' => 15.45,
        'date' => '2018-06-26'
      )

      groceries = post_expense(
        'payee' => 'Whole Foods',
        'amount' => 9.25,
        'date' => '2018-06-26'
      )

      post '/expenses', JSON.generate(coffee)
      expect(last_response.status).to eq(200)
      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))

      post '/expenses', JSON.generate(zoo)
      expect(last_response.status).to eq(200)
      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))

      post '/expenses', JSON.generate(groceries)
      expect(last_response.status).to eq(200)
      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))

      get '/expenses/2018-06-26'
      expect(last_response.status).to eq(200)
      expenses = JSON.parse(last_response.body)
      expect(expenses).to contain_exactly(groceries, zoo)
    end
  end
end