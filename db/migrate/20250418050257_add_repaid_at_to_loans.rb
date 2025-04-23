class AddRepaidAtToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :repaid_at, :datetime
  end
end
