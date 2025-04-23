class LoansController < ApplicationController
  before_action :authenticate_user!
  layout "application"
  include ActionController::MimeResponds

  def index
    if current_user.admin?
      @loans = Loan.all
    else
      @loans = current_user.loans.select(:id, :amount, :duration, :status, :repaid_at, :credit_score, :risk_level)
    end
    respond_to do |format|
      format.html do
        # Blockchain-related code (kept as it is)
        begin
          service = Blockchain::LoanContractService.new
          details = service.get_loan_details(1)

          if details.present?
            @borrower = details[0]
            @amount = details[1]
            @approved = details[2]
          else
            flash[:alert] = "No loan details found on the blockchain."
          end
        rescue => e
          Rails.logger.error("Blockchain error: #{e.message}")
          flash[:alert] = "Failed to fetch loan details: #{e.message}"
        end
      end

      format.json { render json: @loans }
    end
  end

  def new
    @loan = Loan.new
  end

  def show
    @loan = Loan.find(params[:id])
  end

  def create
    institution = Institution.find(@loan.institution_id)
    @loan = current_user.loans.new(loan_params)
  
    # AI Risk Assessment
    score = RiskAssessmentService.assess(current_user, @loan)
    @loan.credit_score = score[:score]
    @loan.risk_level = score[:risk_level]
  
    # Set status based on risk level
    case score[:risk_level].to_s.downcase
    when 'low', 'medium'
      @loan.status = :approved
    when 'high', 'unknown'
      @loan.status = :rejected
    else
      @loan.status = :pending
    end
  
    if @loan.save
      if @loan.approved?
        begin
          Blockchain::LoanContractService.new.record_loan(@loan)
        rescue => e
          Rails.logger.error("Blockchain error while recording loan: #{e.message}")
          flash[:alert] = "Loan saved, but blockchain recording failed: #{e.message}"
        end
      end
  
      redirect_to loans_path, notice: "Loan submitted. Risk: #{@loan.risk_level&.capitalize || 'Unknown'}"
    else
      render :new
    end
  end
  

  def borrower
    service = Blockchain::LoanContractService.new

    begin
      borrower_address = service.client.call(service.contract, "borrower")
      render json: { borrower: borrower_address }
    rescue => e
      Rails.logger.error("Error fetching borrower: #{e.message}")
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def assess_risk
    score = ExperianService.new(current_user).get_credit_score

    if score
      render json: { risk_score: score["riskScore"] }, status: :ok
    else
      render json: { error: "Unable to retrieve score" }, status: :unprocessable_entity
    end
  end

  def approve
    @loan = Loan.find(params[:id])

    if @loan.update(status: :approved)
      flash[:notice] = "Loan approved successfully."
    else
      flash[:alert] = "Unable to approve loan."
    end

    redirect_to loans_path
  end

  private

  def loan_params
    params.require(:loan).permit(:amount, :due_date, :duration, :interest_rate)
  end
end
