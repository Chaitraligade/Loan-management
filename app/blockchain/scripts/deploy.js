async function main() {
  const [lender, borrower] = await ethers.getSigners();

  const LoanContract = await ethers.getContractFactory("LoanContract");
  const loanContract = await LoanContract.deploy(borrower.address, ethers.utils.parseEther("1.0"));

  console.log("LoanContract deployed to:", loanContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
