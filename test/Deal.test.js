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

  describe("Testing of possible functionality", () => {
    it("buyer should buy a product with Ether", async () => {
      // setup
      let beforeProductOwner, afterProductOwner, productPrice;
      let key = "Skateboard";

      // exercise
      beforeProductOwner = await instance
        .products(key)
        .then((result) => result.productOwner);
      productPrice = await instance
        .products(key)
        .then((result) => result.price.toNumber());
      await instance.buyProduct(key, {
        from: buyer,
        gas: 200000,
        value: productPrice,
      });
      afterProductOwner = await instance
        .products(key)
        .then((result) => result.productOwner);

      // verify
      assert(beforeProductOwner !== afterProductOwner);
    });

    it("buyer should make a complaint on a product", async () => {
      // setup
      let beforeComplainsCount, afterComplainsCount;
      let index = 0;

      // exercise
      beforeComplainsCount = await instance.complainsCount();

      await instance.makeComplaint(index, "Test comment from buyer complaint", {
        from: buyer,
      });
      afterComplainsCount = await instance.complainsCount();

      // verify
      assert(beforeComplainsCount.toNumber() < afterComplainsCount.toNumber());
    });

    it("arbitrator should resolve a complaint from buyer on a product", async () => {
      // setup
      let beforeComplainsCount, afterComplainsCount, complains;
      let index = 0;

      // exercise
      beforeComplaintResolution = await instance
        .complains(index.toString())
        .then((result) => result.isResolved);
      await instance.resolveComplaint(
        index,
        "Test comment from arbitrator for the buyer complaint",
        {
          from: arbitrator,
        }
      );
      afterComplaintResolution = await instance
        .complains(index.toString())
        .then((result) => result.isResolved);

      // verify
      assert(!beforeComplaintResolution && afterComplaintResolution);
    });

    it("seller should make a complaint on a product", async () => {
      // setup
      let beforeComplainsCount, afterComplainsCount;
      let index = 0;

      // exercise
      beforeComplainsCount = await instance.complainsCount();

      await instance.makeComplaint(
        index,
        "Test comment from seller complaint",
        {
          from: seller,
        }
      );
      afterComplainsCount = await instance.complainsCount();

      // verify
      assert(beforeComplainsCount.toNumber() < afterComplainsCount.toNumber());
    });

    it("arbitrator should resolve a complaint from seller on a product", async () => {
      // setup
      let beforeComplainsCount, afterComplainsCount, complains;
      let index = 1;

      // exercise
      beforeComplaintResolution = await instance
        .complains(index.toString())
        .then((result) => result.isResolved);
      await instance.resolveComplaint(
        index,
        "Test comment from arbitrator for the seller complaint",
        {
          from: arbitrator,
        }
      );
      afterComplaintResolution = await instance
        .complains(index.toString())
        .then((result) => result.isResolved);

      // verify
      assert(!beforeComplaintResolution && afterComplaintResolution);
    });

    it("arbitrator should receive information about the invoice", async () => {
      // setup
      let _invoiceInfo;
      let index = 0;

      // exercise
      let expectedResult = {
        0: await instance
          .invoices(index.toString())
          .then((result) => result.buyer),
        1: await instance
          .invoices(index.toString())
          .then((result) => result.seller),
        2: await instance
          .invoices(index.toString())
          .then((result) => result.productName),
        3: await instance
          .invoices(index.toString())
          .then((result) => parseInt(result.price)),
        4: await instance
          .invoices(index.toString())
          .then((result) => parseInt(result.date)),
      };

      _invoiceInfo = await instance.getInvoiceInfo(index, { from: arbitrator });
      _invoiceInfo["3"] = _invoiceInfo["3"].toNumber();
      _invoiceInfo["4"] = _invoiceInfo["4"].toNumber();

      // verify
      expect(_invoiceInfo).to.eql(expectedResult);
    });

    it("buyer should receive information about the invoice", async () => {
      // setup
      let _invoiceInfo;
      let index = 0;

      // exercise
      let expectedResult = {
        0: await instance
          .invoices(index.toString())
          .then((result) => result.buyer),
        1: await instance
          .invoices(index.toString())
          .then((result) => result.seller),
        2: await instance
          .invoices(index.toString())
          .then((result) => result.productName),
        3: await instance
          .invoices(index.toString())
          .then((result) => parseInt(result.price)),
        4: await instance
          .invoices(index.toString())
          .then((result) => parseInt(result.date)),
      };

      _invoiceInfo = await instance.getInvoiceInfo(index, { from: buyer });
      _invoiceInfo["3"] = _invoiceInfo["3"].toNumber();
      _invoiceInfo["4"] = _invoiceInfo["4"].toNumber();

      // verify
      expect(_invoiceInfo).to.eql(expectedResult);
    });

    it("seller should receive information about the invoice", async () => {
      // setup
      let _invoiceInfo;
      let index = 0;

      // exercise
      let expectedResult = {
        0: await instance
          .invoices(index.toString())
          .then((result) => result.buyer),
        1: await instance
          .invoices(index.toString())
          .then((result) => result.seller),
        2: await instance
          .invoices(index.toString())
          .then((result) => result.productName),
        3: await instance
          .invoices(index.toString())
          .then((result) => parseInt(result.price)),
        4: await instance
          .invoices(index.toString())
          .then((result) => parseInt(result.date)),
      };

      _invoiceInfo = await instance.getInvoiceInfo(index, { from: seller });
      _invoiceInfo["3"] = _invoiceInfo["3"].toNumber();
      _invoiceInfo["4"] = _invoiceInfo["4"].toNumber();

      // verify
      expect(_invoiceInfo).to.eql(expectedResult);
    });

    it("arbitrator should receive information about the product", async () => {
      // setup
      let _productInfo;
      let key = "Skateboard";

      // exercise
      let expectedResult = {
        0: await instance
          .products(key)
          .then((result) => parseInt(result.price)),
        1: await instance.products(key).then((result) => result.token),
        2: await instance.products(key).then((result) => result.isBroken),
        3: await instance.products(key).then((result) => result.productOwner),
      };

      _productInfo = await instance.getProductInfo(key, { from: arbitrator });
      _productInfo["0"] = _productInfo["0"].toNumber();

      // verify
      expect(_productInfo).to.eql(expectedResult);
    });

    it("buyer should receive information about the product", async () => {
      // setup
      let _productInfo;
      let key = "Skateboard";

      // exercise
      let expectedResult = {
        0: await instance
          .products(key)
          .then((result) => parseInt(result.price)),
        1: await instance.products(key).then((result) => result.token),
        2: await instance.products(key).then((result) => result.isBroken),
        3: await instance.products(key).then((result) => result.productOwner),
      };

      _productInfo = await instance.getProductInfo(key, { from: buyer });
      _productInfo["0"] = _productInfo["0"].toNumber();

      // verify
      expect(_productInfo).to.eql(expectedResult);
    });

    it("seller should receive information about the product", async () => {
      // setup
      let _productInfo;
      let key = "Skateboard";

      // exercise
      let expectedResult = {
        0: await instance
          .products(key)
          .then((result) => parseInt(result.price)),
        1: await instance.products(key).then((result) => result.token),
        2: await instance.products(key).then((result) => result.isBroken),
        3: await instance.products(key).then((result) => result.productOwner),
      };

      _productInfo = await instance.getProductInfo(key, { from: seller });
      _productInfo["0"] = _productInfo["0"].toNumber();

      // verify
      expect(_productInfo).to.eql(expectedResult);
    });

    it("arbitrator should receive information about the complaint", async () => {
      // setup
      let _productInfo;
      let index = 0;

      // exercise
      let expectedResult = {
        0: await instance.complains(index).then((result) => result.invoice),
        1: await instance
          .complains(index)
          .then((result) => result.buyerComment),
        2: await instance
          .complains(index)
          .then((result) => result.sellerComment),
        3: await instance
          .complains(index)
          .then((result) => result.arbitratorComment),
        4: await instance.complains(index).then((result) => result.isResolved),
      };

      _complaint = await instance.getComplaintInfo(index, {
        from: arbitrator,
      });

      // verify
      expect(_complaint).to.eql(expectedResult);
    });

    it("buyer should receive information about the complaint", async () => {
      // setup
      let _productInfo;
      let index = 0;

      // exercise
      let expectedResult = {
        0: await instance.complains(index).then((result) => result.invoice),
        1: await instance
          .complains(index)
          .then((result) => result.buyerComment),
        2: await instance
          .complains(index)
          .then((result) => result.sellerComment),
        3: await instance
          .complains(index)
          .then((result) => result.arbitratorComment),
        4: await instance.complains(index).then((result) => result.isResolved),
      };

      _complaint = await instance.getComplaintInfo(index, {
        from: buyer,
      });

      // verify
      expect(_complaint).to.eql(expectedResult);
    });

    it("seller should receive information about the complaint", async () => {
      // setup
      let _productInfo;
      let index = 0;

      // exercise
      let expectedResult = {
        0: await instance.complains(index).then((result) => result.invoice),
        1: await instance
          .complains(index)
          .then((result) => result.buyerComment),
        2: await instance
          .complains(index)
          .then((result) => result.sellerComment),
        3: await instance
          .complains(index)
          .then((result) => result.arbitratorComment),
        4: await instance.complains(index).then((result) => result.isResolved),
      };

      _complaint = await instance.getComplaintInfo(index, {
        from: seller,
      });

      // verify
      expect(_complaint).to.eql(expectedResult);
    });
  });

  describe("Testing of unpossible functionality", () => {});
  // await Deal.deployed();
  // return assert.isTrue(true);
});
