const { expect } = require("chai");

describe("Token contract", function () {
  it("Deployment should assign the 3  tokens to the admin", async function () {
    const [owner] = await ethers.getSigners();
    console.log(owner.address);
    const Token = await ethers.getContractFactory("CommunityToken_ERC20");

    const hardhatToken = await Token.deploy(owner.address);

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    console.log(ownerBalance);
    expect(ownerBalance===3);    
  });
});