class AddDurationToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :duration, :integer
  end
end
