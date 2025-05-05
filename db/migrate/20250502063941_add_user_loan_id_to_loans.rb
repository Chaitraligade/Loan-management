class AddUserLoanIdToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :user_loan_id, :integer
  end
end
