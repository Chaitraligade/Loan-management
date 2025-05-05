class AddDetailsToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :purpose, :string
    add_column :loans, :employment_status, :string
    add_column :loans, :employer_name, :string
  end
end
