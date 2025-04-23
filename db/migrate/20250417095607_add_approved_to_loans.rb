class AddApprovedToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :approved, :boolean
  end
end
