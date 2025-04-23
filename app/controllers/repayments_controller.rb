class RepaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_loan

  def new
    @repayment = @loan.repayments.new
  end

  def create
    @repayment = @loan.repayments.new(repayment_params)
    @repayment.user = current_user
    @repayment.paid_at = Time.current
  
    if @repayment.amount <= @loan.remaining_balance
      if @repayment.save
        @loan.remaining_balance -= @repayment.amount
        @loan.status = "paid" if @loan.remaining_balance <= 0
        @loan.save!
        redirect_to @loan, notice: "Repayment successful."
      else
        Rails.logger.debug "❌ Repayment Save Failed: #{@repayment.errors.full_messages}"
        flash.now[:alert] = "Validation errors: #{@repayment.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Repayment amount cannot be greater than remaining balance."
      render :new, status: :unprocessable_entity
    end
  end  

  private

  def set_loan
    @loan = Loan.find(params[:loan_id])
  end

  def repayment_params
    params.require(:repayment).permit(:amount)
  end
end
