require 'rails_helper'

RSpec.describe Blockchain::LoanContractService do
  let(:service) { described_class.new }
  let(:borrower_address) { "0x5FbDB2315678afecb367f032d93F642f64180aa3" } # replace with a valid local Ethereum address
  let(:amount) { 1000 }

  it "records a loan on the blockchain" do
    tx_hash = service.record_loan(borrower_address, amount)
    expect(tx_hash).to match(/^0x[a-fA-F0-9]{64}$/)
  end

  it "retrieves loan details from the blockchain" do
    service.record_loan(borrower_address, amount)
    sleep 5 # wait for transaction mining (optional for local node)
    details = service.get_loan_details(0) # assuming loan ID starts at 0
    expect(details[:borrower].downcase).to eq(borrower_address.downcase)
    expect(details[:amount]).to eq(amount)
    expect(details[:approved]).to eq(false)
  end

  it "approves a loan on the blockchain" do
    service.record_loan(borrower_address, amount)
    service.approve_loan(0)
    details = service.get_loan_details(0)
    expect(details[:approved]).to eq(true)
  end
end
