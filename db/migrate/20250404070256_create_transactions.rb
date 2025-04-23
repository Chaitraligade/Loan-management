class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :loan, null: false, foreign_key: true
      t.string :tx_hash
      t.string :action
      t.string :status
      t.text :error_message

      t.timestamps
    end
  end
end
