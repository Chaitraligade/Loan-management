ActiveAdmin.register Loan do
  permit_params :amount, :due_date, :status, :user_id, :institution_id

  index do
    id_column
    column :amount
    # column :due_date
    column :status
    column :user do |loan|
      loan.user.present? ? loan.user.email : "No user"
    end
    column :institution do |loan|
      loan.institution.present? ? loan.institution.name : "No institution"
    end
    actions
  end

  show do
    attributes_table do
      row :amount
      # row :due_date
      row :status
      row("Approved?") { |loan| loan.status == 'approved' ? "Yes" : "No" }
      row :user
      row :institution
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :amount, input_html: { min: 0.01 }
      # f.input :due_date, as: :datepicker
      f.input :status, as: :select, collection: Loan.statuses.keys
      # f.input :user
      f.input :institution, as: :select, collection: Institution.all.collect { |i| [i.name, i.id] }
    end
    f.actions
  end

  filter :user
  filter :status
  filter :institution
  filter :created_at

  member_action :approve, method: :put do
    loan = Loan.find(params[:id])
    loan.update(status: :approved)
    redirect_to admin_loan_path(loan), notice: "Loan approved successfully."
  end

  member_action :reject, method: :put do
    loan = Loan.find(params[:id])
    loan.update(status: :rejected)
    redirect_to admin_loan_path(loan), notice: "Loan rejected!"
  end

  action_item :approve, only: :show do
    link_to 'Approve', approve_admin_loan_path(loan), method: :put if loan.status != 'approved'
  end

  action_item :reject, only: :show do
    link_to 'Reject', reject_admin_loan_path(loan), method: :put if loan.status != 'rejected'
  end
end
