require_relative '../../../app/ledger'
require_relative '../../../config/sequel'
require_relative '../../../support/db'

module ExpenseTracker
  RSpec.describe Ledger do
    let(:ledger) { Ledger.new }
    let(:expenses) do
      'payee': 'Starbucks',
      'amount': 5.75,
      'date' : '2017-06-10'
    end

    describe '#record' do
    end
  end
end
