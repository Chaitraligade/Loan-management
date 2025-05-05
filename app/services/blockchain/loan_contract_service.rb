require 'eth'
require 'json'

module Blockchain
  class LoanContractService
    def initialize
      @key = Eth::Key.new(priv: ENV['ETH_PRIVATE_KEY'])
      @client = Eth::Client.create("http://localhost:8545")

      @contract_address = ENV['LOAN_CONTRACT_ADDRESS']
      abi_path = Rails.root.join("app/blockchain/LoanContract.abi")
      abi = JSON.parse(File.read(abi_path))
      @contract = Eth::Contract.from_abi(name: "LoanContract", address: @contract_address, abi: abi)
    end

    def get_loan_details(contract_address)
      contract_address = contract_address.to_i
      result = @contract.call.getLoanDetails(contract_address)

      {
        borrower: result[0],
        amount: result[1],
        approved: result[2]
      }
    end

    def request_loan(borrower_address, amount)
      amount = amount.to_i
      Rails.logger.debug("📨 Requesting loan on-chain for borrower=#{borrower_address}, amount=#{amount}")

      data = @contract.transact.requestLoan(borrower_address, amount).data
      send_transaction(data)
    end

    def approve_loan(contract_address)
      contract_address = contract_address.to_i
      Rails.logger.debug("✅ Approving loan ID #{contract_address} on-chain")

      data = @contract.transact.approveLoan(contract_address).data
      send_transaction(data)
    end

    def record_loan(borrower_address, amount)
      request_loan(borrower_address, amount.to_i)
    end

    # Inside BlockchainService
def self.create_loan_contract(loan, credit_score)
  contract_data = {
    amount: loan.amount,
    credit_score: credit_score.to_s,  # Ensure it's a string if expected by the contract
    risk_level: loan.risk_level,
    due_date: loan.due_date.to_s,  # Example of date formatting
    # More fields here...
  }
  blockchain_connection.create_contract(contract_data)
end

    private

    def send_transaction(data)
      nonce = @client.get_nonce(@key.address)
      gas_price = @client.eth_gas_price["result"].to_i(16)
      chain_id = @client.eth_chain_id["result"].to_i(16)

      tx = Eth::Tx.new(
        nonce: nonce,
        gas_price: gas_price,
        gas_limit: 300_000,
        to: @contract.address,
        value: 0,
        data: data,
        chain_id: chain_id
      )

      tx.sign(@key)
      raw_tx = tx.hex
      Rails.logger.debug("📦 Sending raw transaction: #{raw_tx}")

      result = @client.eth_send_raw_transaction(raw_tx)
      if result["error"]
        Rails.logger.error("❌ RPC Error: #{result["error"]["message"]}")
        raise "Blockchain RPC Error: #{result["error"]["message"]}"
      end

      tx_hash = result["result"]
      Rails.logger.info("✅ Transaction hash: #{tx_hash}")
      tx_hash
    end
  end
end
