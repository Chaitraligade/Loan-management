class LoansController < ApplicationController

  before_action :authenticate_user!
 
  layout "application"
  include ActionController::MimeResponds
 
  def index
    @loans = current_user.admin? ? Loan.all : current_user.loans.select(:id, :amount, :duration, :status, :repaid_at, :credit_score, :risk_level, :user_loan_id)

    respond_to do |format|
      format.html do
        @loan_details = fetch_blockchain_loan_details
      end
      format.json { render json: @loans }
    end
  end

  def new
    @loan = Loan.new
    # @institutions = Institution.all
    @institutions = Institution.all.presence || []
  end

  def create
    # Initialize the loan object for the current user
    @loan = current_user.loans.new(loan_params)
    @loan.user = current_user
    @loan.monthly_income ||= current_user.monthly_income # Fallback if monthly_income is not set
    puts "Institution ID: #{@loan.institution_id}"  # Log institution ID for debugging

    # Ensure institution is present and fetch contract address
    begin
      institution = Institution.find_by(id: @loan.institution_id)
      raise "Institution not found" if institution.nil?
      
      @contract_address = institution.contract_address
      @contract_address = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0' 
      raise "Missing contract address" if @contract_address.blank?
  
      # Check if the contract address is valid (must start with 0x and be 42 characters long)
      if !@contract_address.start_with?("0x") || @contract_address.length != 42
        raise "Invalid contract address format"
      end
      
      # Try converting to a checksum Ethereum address
      # @contract_address = Eth::Address.new(@contract_address).checksum
      puts "Contract Address: #{@contract_address}"  # Log contract address for debugging
  
    end
  
    # Attempt to save the loan
    if @loan.save
      # If loan is approved, handle blockchain integration
      Notification.create(user: current_user, message: "Your loan application has been submitted.", read: false)

     
      if @loan.approved?
        begin
          handle_blockchain_integration(@loan)
        rescue => e
          # Rails.logger.error("Blockchain integration failed: #{e.message}")
          # flash[:alert] = "Blockchain integration failed: #{e.message}"
        end
      end
      # Redirect to the loans path with a success message
      redirect_to loans_path, notice: "Loan submitted successfully. Risk: #{@loan.risk_level.capitalize}"
    else
      # If loan save fails, render the form again with error messages
      @institutions = Institution.all
      log_errors(@loan)
      flash.now[:alert] = "Failed to create loan: #{@loan.errors.full_messages.join(', ')}"
      render :new
    end
  end
  
  
  def pay
    @loan = Loan.find(params[:id])
    # logic to process payment here
    @loan.update(status: 'repaid', repaid_at: Time.current)
  
    redirect_to loans_path, notice: "Loan ##{@loan.id} has been marked as paid."
  end
  

  private
  

  def loan_params
    params.require(:loan).permit(:amount, :due_date, :duration, :institution_id, :monthly_income)
  end

  def contract_exists?(address)
    # Check if a contract exists at the given address
    begin
      contract = Eth::Contract.at(address)
      !contract.nil?  # If contract exists, return true
    rescue => e
      false  # If any error occurs (like contract not found), return false
    end
  end

  def fetch_blockchain_loan_details
    loan = current_user.loans.find_by(status: :approved)
    return nil unless loan&.contract_address.present?

    service = Blockchain::LoanContractService.new
    begin
      details = service.get_loan_details(loan.contract_address.to_s)
      
      if details.is_a?(Hash) && details.symbolize_keys.slice(:borrower, :amount, :approved).present?
        {
          borrower: details[:borrower],
          amount: details[:amount],
          approved: details[:approved]
        }
      else
        flash.now[:alert] = "Blockchain returned invalid loan details."
        nil
      end
    rescue => e
      Rails.logger.error("Blockchain fetch error: #{e.message}")
      flash.now[:alert] = "Error fetching blockchain loan: #{e.message}"
      nil
    end
  end

  def handle_blockchain_integration(loan)
    service = Blockchain::LoanContractService.new
    begin
      tx_hash = service.record_loan(current_user.eth_address, loan.amount.to_i)
      Rails.logger.info("Blockchain transaction success: #{tx_hash}")
    rescue => e
      Rails.logger.error("Blockchain sync failed: #{e.message}")
      flash[:alert] = "Blockchain sync failed: #{e.message}"
    end
  end

  def log_errors(loan)
    Rails.logger.error("Loan save failed: #{loan.errors.full_messages.join(', ')}")
  end
end
