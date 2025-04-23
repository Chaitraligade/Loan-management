// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LoanContract {
    address public lender;
    address public borrower;
    uint public amount;
    bool public approved;
    bool public repaid;

    constructor(address _borrower, uint _amount) {
        lender = msg.sender;
        borrower = _borrower;
        amount = _amount;
        approved = false;
        repaid = false;
    }

    function approveLoan() public {
        require(msg.sender == lender, "Only lender can approve");
        approved = true;
    }

    function disburseLoan() public payable {
        require(approved, "Loan not approved");
        payable(borrower).transfer(amount);
    }

    function repayLoan() public payable {
        require(msg.sender == borrower, "Only borrower can repay");
        require(msg.value == amount, "Incorrect repayment amount");
        payable(lender).transfer(msg.value);
        repaid = true;
    }
    
   function getLoanDetails() public view returns (
    address _borrower,
    uint _amount,
    bool _approved
) {
    return (borrower, amount, approved);
}


}
