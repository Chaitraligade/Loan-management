class AddContractAddressToInstitutions < ActiveRecord::Migration[7.1]
  def change
    add_column :institutions, :contract_address, :string
  end
end
