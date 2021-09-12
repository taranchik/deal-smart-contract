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
    instance = await Deal.deployed();
  });

  afterEach("Destruct contract", () => {
    instance = null;
  });

  describe("Testing of possible functionality", function () {
    it("buyer should buy a product with Ether", async () => {
      // setup
      let beforeProductOwner, afterProductOwner;

      // exercise
      beforeProductOwner = await instance
        .products("Skateboard")
        .then((result) => result.productOwner);
      productPrice = await instance
        .products("Skateboard")
        .then((result) => result.price.toNumber());
      await instance.buyProduct("Skateboard", {
        from: buyer,
        gas: 200000,
        value: productPrice,
      });
      afterProductOwner = await instance
        .products("Skateboard")
        .then((result) => result.productOwner);

      console.log(beforeProductOwner, afterProductOwner);

      // verify
      assert(beforeProductOwner !== afterProductOwner);
    });

    it("buyer should buy a product with Ether", async () => {
      // setup
      let beforeProductOwner, afterProductOwner;

      // exercise
      beforeProductOwner = await instance
        .products("Skateboard")
        .then((result) => result.productOwner);
      productPrice = await instance
        .products("Skateboard")
        .then((result) => result.price.toNumber());
      await instance.buyProduct("Skateboard", {
        from: buyer,
        gas: 200000,
        value: productPrice,
      });
      afterProductOwner = await instance
        .products("Skateboard")
        .then((result) => result.productOwner);

      console.log(beforeProductOwner, afterProductOwner);

      // verify
      assert(beforeProductOwner !== afterProductOwner);
    });
  });

  // await Deal.deployed();
  // return assert.isTrue(true);
});
