class CreateRepayments < ActiveRecord::Migration[7.1]
  def change
    create_table :repayments do |t|
      t.references :loan, null: false, foreign_key: true
      t.decimal :amount
      t.datetime :paid_at

      t.timestamps
    end
  end
end
