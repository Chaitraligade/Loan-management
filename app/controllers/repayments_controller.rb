class RepaymentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @loan = Loan.find(params[:loan_id])
    @repayment = @loan.repayments.find(params[:repayment_id])

    if @repayment.paid?
      redirect_to loans_path, alert: "This repayment has already been made."
      return
    end

    # Simulate Ethereum repayment here (optional)
    begin
      # Blockchain interaction (optional)
      # tx = EthereumService.new(current_user).repay(@loan, @repayment.amount)
      # raise "Blockchain repayment failed" unless tx.success?

      @repayment.update!(status: "paid", paid_at: Time.current)

      flash[:notice] = "Repayment successful."
    rescue => e
      flash[:alert] = "Repayment failed: #{e.message}"
    end

    redirect_to loans_path
  end
end
