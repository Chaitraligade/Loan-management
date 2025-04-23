class AddDeviseToAdminUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :admin_users do |t|
      # Only add these columns if they don't already exist
      unless column_exists?(:admin_users, :email)
        t.string :email, default: "", null: false
      end

      unless column_exists?(:admin_users, :encrypted_password)
        t.string :encrypted_password, default: "", null: false
      end

      unless column_exists?(:admin_users, :reset_password_token)
        t.string :reset_password_token
      end

      unless column_exists?(:admin_users, :reset_password_sent_at)
        t.datetime :reset_password_sent_at
      end

      unless column_exists?(:admin_users, :remember_created_at)
        t.datetime :remember_created_at
      end
    end
  end
end

