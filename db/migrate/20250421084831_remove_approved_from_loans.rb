class RemoveApprovedFromLoans < ActiveRecord::Migration[7.1]
  def change
    remove_column :loans, :approved, :boolean
  end
end
