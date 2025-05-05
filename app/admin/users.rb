# app/admin/users.rb
ActiveAdmin.register User do
  index do
    selectable_column
    id_column
    column :email
    column :admin
    actions
  end

  filter :email
  filter :role, as: :select, collection: User.roles.keys
  filter :created_at
  filter :updated_at
  filter :institution_id
  
  form do |f|
    f.inputs "User Details" do
      f.input :email
      f.input :admin
    end
    f.actions
  end
end
