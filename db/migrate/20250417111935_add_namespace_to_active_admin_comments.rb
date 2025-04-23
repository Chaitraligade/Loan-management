class AddNamespaceToActiveAdminComments < ActiveRecord::Migration[7.1]
  def change
    add_column :active_admin_comments, :namespace, :string
  end
end
