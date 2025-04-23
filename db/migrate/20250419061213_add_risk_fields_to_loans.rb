class AddRiskFieldsToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :credit_score, :integer
    add_column :loans, :risk_level, :string
    # add_column :loans, :approved, :boolean
  end
end
