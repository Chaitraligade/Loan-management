class AddInterestRateToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :interest_rate, :decimal
  end
end
