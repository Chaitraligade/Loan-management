class HomeController < ApplicationController
  def index
    @loan = Loan.new
    if current_user
      @loans = current_user.loans
    else
      @loans = []  # Avoid nil in the view
    end
  end
end
