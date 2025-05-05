const { expect } = require("chai");

describe("LoanContract", function () {
  it("should deploy", async function () {
    const LoanContract = await ethers.getContractFactory("LoanContract");
    const contract = await LoanContract.deploy();
    await contract.waitForDeployment();
    expect(contract.target).to.not.be.null;
  });
});
