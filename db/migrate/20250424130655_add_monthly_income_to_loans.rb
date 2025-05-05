class AddMonthlyIncomeToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :monthly_income, :integer
  end
end
