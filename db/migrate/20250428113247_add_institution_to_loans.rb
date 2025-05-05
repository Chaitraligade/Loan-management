class AddInstitutionToLoans < ActiveRecord::Migration[7.1]
  def change
    add_reference :loans, :institution, null: false, foreign_key: true
  end
end
