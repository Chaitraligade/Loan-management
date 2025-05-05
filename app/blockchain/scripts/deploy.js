const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with account:", deployer.address);

    const LoanContract = await ethers.getContractFactory("LoanContract");
    const loanContract = await LoanContract.deploy();

    // Use `.target` instead of `.address`
    console.log("LoanContract deployed to:", loanContract.target);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
