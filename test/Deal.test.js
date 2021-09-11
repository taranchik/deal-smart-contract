console.log("running Deal.test.js");

const Deal = artifacts.require("Deal");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Deal", function (accounts) {
  let instance;
  seller = accounts[0];
  buyer = accounts[1];
  arbitrator = accounts[2];

  beforeEach("Deploy contract", async () => {
    instance = await Bank.deployed();
  });

  afterEach("Destruct contract", () => {
    instance = null;
  });

  // await Deal.deployed();
  // return assert.isTrue(true);
});
