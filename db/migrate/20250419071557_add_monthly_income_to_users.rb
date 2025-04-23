class AddMonthlyIncomeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :monthly_income, :integer
  end
end
