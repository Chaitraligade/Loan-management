class AddStatusToRepayments < ActiveRecord::Migration[7.1]
  def change
    add_column :repayments, :status, :integer
  end
end
