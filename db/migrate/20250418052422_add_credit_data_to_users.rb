class AddCreditDataToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :credit_score, :integer
    add_column :users, :risk_level, :string
  end
end
