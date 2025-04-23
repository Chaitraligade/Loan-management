class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
      devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

         has_many :transactions
         has_many :loans, dependent: :destroy
         belongs_to :institution, optional: true
         enum role: { borrower: 0, institution_admin: 1, super_admin: 2 }
         def admin?
          self.admin  # returns true if the user is an admin, false otherwise
        end
        
end
