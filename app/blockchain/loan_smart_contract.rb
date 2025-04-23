# app/services/blockchain/loan_contract_service.rb

module Blockchain
  class LoanContractService
    def initialize
      @contract_address = "0x5FbDB2315678afecb367f032d93F642f64180aa3" # Replace with your actual deployed address
      @abi = JSON.parse(File.read(Rails.root.join("app", "blockchain", "artifacts", "contracts", "LoanContract.sol", "LoanContract.json")))["abi"]
      @client = Eth::Client.create("http://localhost:8545")
      @key = Eth::Key.new priv: ENV["PRIVATE_KEY"] || "0x59c6995e998f97a5a0044966f094538c5f27a8e9be0df61e6f7b67458dfd7e16"
      @contract = Eth::Contract.from_abi(name: "LoanContract", address: @contract_address, abi: @abi)
    end

    def get_loan_details(loan_id)
      # Assuming you have a method that calls the smart contract
      # Replace this with actual interaction with the blockchain
      contract = self.client.contract
      details = contract.call("getLoanDetails", loan_id)
  
      return details if details.present?
      nil
    rescue => e
      Rails.logger.error("Blockchain error: #{e.message}")
      nil
    end
    def borrower
      @client.call(@contract, "borrower")
    end

    def amount
      @client.call(@contract, "amount")
    end

    def create_loan(user, loan)
      tx = Transaction.create!(user: user, loan: loan, action: "create_loan", status: "pending")
    
      begin
        result = @contract.send_transaction.createLoan(loan.amount, loan.due_date.to_i)

        tx.update!(tx_hash: result.id, status: "success")
      rescue => e
        tx.update!(status: "failed", error_message: e.message)
        raise
      end
    end
    
    def repay_loan(user, loan)
      tx = Transaction.create!(user: user, loan: loan, action: "repay", status: "pending")
    
      begin
        result = @contract.transact.from(user.eth_address).repayLoan(loan.id)
        tx.update!(tx_hash: result.id, status: "success")
      rescue => e
        tx.update!(status: "failed", error_message: e.message)
        raise
      end
    end
    
    def approve_loan(user_eth_address, loan_id)
      @contract.transact.from(user_eth_address).approveLoan(loan_id)
    end
  end
end
