class RemoveInterestRateFromLoans < ActiveRecord::Migration[7.1]
  def change
    remove_column :loans, :interest_rate, :decimal
  end
end
