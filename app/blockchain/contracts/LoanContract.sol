// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LoanContract {
    struct Loan {
        address lender;
        address borrower;
        uint256 amount;
        bool approved;
        bool repaid;
    }

    Loan[] public loans;

    event LoanCreated(uint loanId, address borrower, uint amount);
    event LoanApproved(uint loanId);
    event LoanDisbursed(uint loanId);
    event LoanRepaid(uint loanId);

    function createLoan(address _borrower, uint256 _amount) public {
        loans.push(Loan(msg.sender, _borrower, _amount, false, false));
        emit LoanCreated(loans.length - 1, _borrower, _amount);
    }

    function approveLoan(uint loanId) public {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.lender, "Only lender can approve");
        loan.approved = true;
        emit LoanApproved(loanId);
    }

    function disburseLoan(uint loanId) public payable {
        Loan storage loan = loans[loanId];
        require(loan.approved, "Loan not approved");
        require(msg.sender == loan.lender, "Only lender can disburse");
        require(msg.value == loan.amount, "Must send exact amount");

        payable(loan.borrower).transfer(loan.amount);
        emit LoanDisbursed(loanId);
    }

    function repayLoan(uint loanId) public payable {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.borrower, "Only borrower can repay");
        require(!loan.repaid, "Already repaid");
        require(msg.value == loan.amount, "Incorrect repayment amount");

        payable(loan.lender).transfer(msg.value);
        loan.repaid = true;
        emit LoanRepaid(loanId);
    }

    function getLoanCount() public view returns (uint) {
        return loans.length;
    }

    function getLoan(uint loanId) public view returns (
        address, address, uint, bool, bool
    ) {
        Loan storage loan = loans[loanId];
        return (loan.lender, loan.borrower, loan.amount, loan.approved, loan.repaid);
    }
}
