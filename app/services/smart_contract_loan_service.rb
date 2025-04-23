# app/services/smart_contract_loan_service.rb
class SmartContractLoanService
  def self.record_loan(loan)
    return unless loan.approved?

    client = Ethereum::HttpClient.new('http://localhost:7545') # Ganache or similar
    key = Eth::Key.new priv: 'YOUR_PRIVATE_KEY' # Use environment variable instead

    contract_address = '0xYourContractAddress'
    abi = JSON.parse(File.read('path/to/contract_abi.json'))

    contract = Ethereum::Contract.create(client: client, address: contract_address, abi: abi)
    contract.transact({ from: key.address })  # Example - customize per contract
           .addLoan(loan.id, loan.amount, loan.user.eth_address)
  end
end
