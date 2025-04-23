class LoanRepaymentService
  def self.call(loan, repayment_amount)
    contract = Ethereum::Contract.create(
      name: 'LoanContract',
      address: '0xYourContractAddress',
      abi: JSON.parse(File.read('path/to/loan_contract_abi.json'))
    )

    contract.transact.and_wait.repayLoan(
      loan.id,                 # Loan ID
      repayment_amount,         # Amount being repaid
      { from: loan.user.eth_address } # Sender address
    )
  end
end
