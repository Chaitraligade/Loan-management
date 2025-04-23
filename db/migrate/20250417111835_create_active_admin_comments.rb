class CreateActiveAdminComments < ActiveRecord::Migration[7.1]
  def change
    create_table :active_admin_comments do |t|
      t.references :resource, polymorphic: true, index: true
      t.references :author, polymorphic: true, index: true
      t.text :body
      t.timestamps
    end
  end
end
