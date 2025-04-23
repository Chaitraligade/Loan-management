class CreateLoanProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :loan_products do |t|
      t.references :institution, null: false, foreign_key: true
      t.string :name
      t.decimal :interest_rate
      t.integer :duration
      t.decimal :max_amount

      t.timestamps
    end
  end
end
