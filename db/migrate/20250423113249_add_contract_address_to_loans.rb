class AddContractAddressToLoans < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :contract_address, :string
  end
end
