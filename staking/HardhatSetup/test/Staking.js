const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("StakingContract", function () {
  let StakingContract;
  let stakingContract;
  let owner;
  let user;
  const XTOKEN_SUPPLY = "1000000000000";
  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    StakingContract = await ethers.getContractFactory("StakingContract");
    const TokenX = await ethers.getContractFactory("TokenX");

    tokenXConInstance = await TokenX.deploy(XTOKEN_SUPPLY);
    stakingContract = await StakingContract.deploy(tokenXConInstance.target);

    await tokenXConInstance.transfer(stakingContract.target,100000000000);

    await tokenXConInstance.transfer(owner,100000000000);
    await tokenXConInstance.transfer(user,100000000000);

    await tokenXConInstance
    .connect(owner)
    .approve(stakingContract.target, 10000000000000);

    await tokenXConInstance
    .connect(user)
    .approve(stakingContract.target, 10000000000000);

  });

  describe("Staking", function () {
    it("Should allow users to stake DEFI tokens", async function () {
      const amountToStake = 1000;
      await stakingContract.connect(user).stake(amountToStake);
      const finalBalance = await tokenXConInstance.balanceOf(stakingContract.target);
      expect(finalBalance).to.equal(100000001000);
    });
  });

  describe("Viewing Rewards", function () {
    it("Should allow users to view their rewards", async function () {
      const amountToStake = 1000;
      await stakingContract.connect(user).stake(amountToStake);
      await ethers.provider.send("evm_mine"); // Mine a block to accumulate rewards

      const userRewards = await stakingContract.viewRewards(user.address);

      expect(userRewards).to.equal(1);
    });
  });

  describe("Withdrawing", function () {
    it("Should allow users to withdraw staked DEFI tokens and rewards", async function () {
      const amountToStake = 1000;
      await stakingContract.connect(user).stake(amountToStake);
      await ethers.provider.send("evm_mine"); // Mine a block to accumulate rewards
      const initialBalance = await tokenXConInstance.balanceOf(user.address);
      await stakingContract.connect(user).withdraw();
      const finalBalance = await tokenXConInstance.balanceOf(user.address);

      expect(finalBalance).to.be.above(initialBalance);
    });
  });
});
