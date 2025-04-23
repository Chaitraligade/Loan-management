require 'eth'

module Blockchain
  class LoanContractService
    def initialize
      @key = Eth::Key.new(priv: ENV['ETH_PRIVATE_KEY'])
      @client = Eth::Client.create("http://localhost:8545")
    
      @contract_address = ENV['LOAN_CONTRACT_ADDRESS']
    
      abi_path = Rails.root.join("app/blockchain/LoanContract.abi")
      abi = JSON.parse(File.read(abi_path))  # Read as a raw JSON string
      @contract = Eth::Contract.from_abi(name: "LoanContract", address: @contract_address, abi: abi["abi"])
      
    end
    
    def record_loan(loan)
      function = @contract.abi.find { |f| f["name"] == "disburseLoan" && f["type"] == "function" }
      raise "Function 'disburseLoan' not found in ABI" unless function
    
      data = Eth::Abi.encode(
        ['uint256', 'uint256', 'uint256', 'string'],
        [loan.id, loan.user_id, loan.amount.to_i, loan.status]
      )
    
      nonce = @client.get_nonce(@key.address)
      gas_price = @client.eth_gas_price["result"].to_i(16)
      chain_id = @client.eth_chain_id["result"].to_i(16)  # ✅ dynamically fetch
    
      tx = Eth::Tx.new({
        nonce: nonce,
        gas_price: gas_price,
        gas_limit: 3_000_000,
        to: @contract.address,
        value: 0,
        data: data,
        chain_id: chain_id
      })
    
      tx.sign(@key)
      tx_hash = @client.eth_send_raw_transaction(tx.hex)["result"]  # ✅ no "0x" prefix
    
      puts "✅ Loan recorded on blockchain: #{tx_hash}"
      tx_hash
    rescue => e
      Rails.logger.error("record_loan failed: #{e.message}")
      raise
    end
    

    def get_loan_details(loan_id)
      @client.call(@contract, "getLoanDetails", loan_id)
    rescue => e
      Rails.logger.error("get_loan_details failed: #{e.message}")
      nil
    end

    def get_loan_amount(loan_id)
      details = get_loan_details(loan_id)
      details ? details[1] : nil
    end

    def approved?(loan_id)
      details = get_loan_details(loan_id)
      details ? details[2] : nil
    end

    def request_loan(borrower_address, amount)
      key = Eth::Key.new priv: ENV['BLOCKCHAIN_PRIVATE_KEY']
      sender_address = key.address
      client = Eth::Client.create("http://localhost:8545")

      abi = JSON.parse(File.read(Rails.root.join("app", "blockchain", "LoanContractABI.json")))
      contract_address = ENV['LOAN_CONTRACT_ADDRESS']

      function = abi.find { |f| f["name"] == "requestLoan" && f["type"] == "function" }
      raise "Function not found in ABI" unless function

      encoder = Eth::Abi::Encoder.new(function)
      data = encoder.encode(borrower_address, amount.to_i)

      nonce = client.get_nonce(sender_address)
      gas_price = client.gas_price
      tx = Eth::Tx.new({
        nonce: nonce,
        gas_price: gas_price,
        gas_limit: 300_000,
        to: contract_address,
        value: 0,
        data: data
      })

      tx.sign key
      tx_hash = client.send_raw_transaction(tx.hex)
      puts "✅ Loan transaction sent with hash: #{tx_hash}"

      return tx_hash
    rescue => e
      puts "🔥 Blockchain error in request_loan: #{e.message}"
      raise e
    end

    def approve_loan(loan_id)
      loan_id_hex = loan_id.to_i.to_s(16).rjust(64, '0')

      selector = Digest::Keccak.hexdigest(256, "approveLoan(uint256)")[0..7]
      data = "0x#{selector}#{loan_id_hex}"

      tx = Eth::Tx.new({
        data: data,
        gas_limit: 100_000,
        gas_price: 20_000_000_000,
        nonce: @client.get_nonce(@key.address),
        to: @contract.address,
        value: 0
      })

      tx.sign(@key)
      tx_hash = @client.send_raw_transaction(tx.hex)
      Rails.logger.info("Loan approved, tx hash: #{tx_hash}")
      tx_hash
    rescue => e
      Rails.logger.error("Blockchain error in approve_loan: #{e.message}")
      raise
    end

    def contract
      @contract
    end

    def client
      @client
    end
  end
end

