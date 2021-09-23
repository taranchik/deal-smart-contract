const Web3 = require("web3");
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

console.log("running Deal.test.js");

const Deal = artifacts.require("Deal");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

contract("Deal", (accounts) => {
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
    it("buyer should buy a right product with Ether", async () => {
      // setup
      let beforeInvoicesCount, afterInvoicesCount, productPrice;
      let key = "Skateboard";

      // exercise
      beforeInvoicesCount = await instance.invoicesCount();
      productPrice = await instance
        .products(key)
        .then((result) => result.price.toString());
      await instance.buyProduct(key, {
        from: buyer,
        gas: 300000,
        value: productPrice,
      });
      afterInvoicesCount = await instance.invoicesCount();

      // verify
      assert(beforeInvoicesCount.toNumber() < afterInvoicesCount.toNumber());
    });

    it("seller should confirm product sale with Ether", async () => {
      // setup
      let beforeInvoiceConfirmation, afterInvoiceConfirmation, productPrice;
      let index = 0;

      // exercise
      beforeInvoiceConfirmation = await instance
        .invoices(index)
        .then((result) => result.isConfirmed);
      await instance.confirmProductSale(index, {
        from: seller,
      });
      afterInvoiceConfirmation = await instance
        .invoices(index)
        .then((result) => result.isConfirmed);

      // verify
      assert(!beforeInvoiceConfirmation && afterInvoiceConfirmation);
    });

    it("buyer should buy a broken product with ERC20 Token", async () => {
      // setup
      let beforeInvoicesCount, afterInvoicesCount, productPrice;
      let key = "Car";

      // exercise
      beforeInvoicesCount = await instance.invoicesCount();
      productPrice = await instance
        .products(key)
        .then((result) => result.price.toString());
      await instance.buyProduct(key, {
        from: buyer,
        gas: 400000,
        value: web3.utils.toWei(productPrice),
      });
      afterInvoicesCount = await instance.invoicesCount();

      // verify
      assert(beforeInvoicesCount.toNumber() < afterInvoicesCount.toNumber());
    });

    it("buyer should make a complaint on a product bought with ERC20 Token", async () => {
      // setup
      let beforeComplainsCount, afterComplainsCount;
      let index = 1;

      // exercise
      beforeComplainsCount = await instance.complainsCount();

      await instance.makeComplaint(index, "The product is broken", {
        from: buyer,
      });
      afterComplainsCount = await instance.complainsCount();

      // verify
      assert(beforeComplainsCount.toNumber() < afterComplainsCount.toNumber());
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
          .then((result) => result.price.toString()),
        4: await instance
          .invoices(index.toString())
          .then((result) => parseInt(result.date)),
      };

      _invoiceInfo = await instance.getInvoiceInfo(index, { from: arbitrator });
      _invoiceInfo["3"] = _invoiceInfo["3"].toString();
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
          .then((result) => result.price.toString()),
        1: await instance.products(key).then((result) => result.token),
        2: await instance.products(key).then((result) => result.isBroken),
        3: await instance.products(key).then((result) => result.productOwner),
      };

      _productInfo = await instance.getProductInfo(key, { from: arbitrator });
      _productInfo["0"] = _productInfo["0"].toString();
      _productInfo["1"] = await instance
        .ERC20Tokens(_productInfo["1"])
        .then((result) => result.token);

      // verify
      expect(_productInfo).to.eql(expectedResult);
    });

    it("arbitrator should resolve a complaint from buyer on a broken product in favor of the buyer", async () => {
      // setup
      let beforeComplainsCount, afterComplainsCount, complains;
      let index = 0;

      // exercise
      beforeComplaintResolution = await instance
        .complains(index.toString())
        .then((result) => result.isResolved);
      await instance.resolveComplaint(
        index,
        "Product is broken, refund issued",
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
          .then((result) => result.price.toString()),
        4: await instance
          .invoices(index.toString())
          .then((result) => parseInt(result.date)),
      };

      _invoiceInfo = await instance.getInvoiceInfo(index, { from: buyer });
      _invoiceInfo["3"] = _invoiceInfo["3"].toString();
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
          .then((result) => result.price.toString()),
        4: await instance
          .invoices(index.toString())
          .then((result) => parseInt(result.date)),
      };

      _invoiceInfo = await instance.getInvoiceInfo(index, { from: seller });
      _invoiceInfo["3"] = _invoiceInfo["3"].toString();
      _invoiceInfo["4"] = _invoiceInfo["4"].toNumber();

      // verify
      expect(_invoiceInfo).to.eql(expectedResult);
    });

    it("buyer should receive information about the product", async () => {
      // setup
      let _productInfo;
      let key = "Skateboard";

      // exercise
      let expectedResult = {
        0: await instance
          .products(key)
          .then((result) => result.price.toString()),
        1: await instance.products(key).then((result) => result.token),
        2: await instance.products(key).then((result) => result.isBroken),
        3: await instance.products(key).then((result) => result.productOwner),
      };

      _productInfo = await instance.getProductInfo(key, { from: buyer });
      _productInfo["0"] = _productInfo["0"].toString();
      _productInfo["1"] = await instance
        .ERC20Tokens(_productInfo["1"])
        .then((result) => result.token);

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
          .then((result) => result.price.toString()),
        1: await instance.products(key).then((result) => result.token),
        2: await instance.products(key).then((result) => result.isBroken),
        3: await instance.products(key).then((result) => result.productOwner),
      };

      _productInfo = await instance.getProductInfo(key, { from: seller });
      _productInfo["0"] = _productInfo["0"].toString();
      _productInfo["1"] = await instance
        .ERC20Tokens(_productInfo["1"])
        .then((result) => result.token);

      // verify
      expect(_productInfo).to.eql(expectedResult);
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

    it("buyer should buy a right product with ERC20 Token", async () => {
      // setup
      let beforeInvoicesCount, afterInvoicesCount, productPrice;
      let key = "Rollers";

      // exercise
      beforeInvoicesCount = await instance.invoicesCount();
      productPrice = await instance
        .products(key)
        .then((result) => result.price.toString());
      await instance.buyProduct(key, {
        from: buyer,
        gas: 400000,
        value: web3.utils.toWei(productPrice),
      });
      afterInvoicesCount = await instance.invoicesCount();

      // verify
      assert(beforeInvoicesCount.toNumber() < afterInvoicesCount.toNumber());
    });

    it("seller should confirm a product sale with ERC20 Token", async () => {
      // setup
      let beforeInvoiceConfirmation, afterInvoiceConfirmation, productPrice;
      let index = 2;

      // exercise
      beforeInvoiceConfirmation = await instance
        .invoices(index)
        .then((result) => result.isConfirmed);
      await instance.confirmProductSale(index, {
        from: seller,
      });
      afterInvoiceConfirmation = await instance
        .invoices(index)
        .then((result) => result.isConfirmed);

      // verify
      assert(!beforeInvoiceConfirmation && afterInvoiceConfirmation);
    });
  });

  describe("Testing of unpossible functionality", () => {
    describe("Buy product testing", () => {
      it("buyer tries to buy a non-existent product", async () => {
        // setup
        let beforeInvoicesCount, afterInvoicesCount;
        let key = "Snowboard";

        // exercise
        beforeInvoicesCount = await instance.invoicesCount();
        productPrice = await instance
          .products(key)
          .then((result) => result.price.toString());
        try {
          await instance.buyProduct(key, {
            from: buyer,
            gas: 400000,
            value: productPrice,
          });
        } catch (error) {
          // verify
          assert(
            error.reason,
            "Purchase of a non-existent product is not possible"
          );
        }
        afterInvoicesCount = await instance.invoicesCount();

        // verify
        assert(
          beforeInvoicesCount.toNumber() === afterInvoicesCount.toNumber()
        );
      });

      it("arbitrator tries to buy a product", async () => {
        // setup
        let beforeInvoicesCount, afterInvoicesCount;
        let key = "Bike";

        // exercise
        beforeInvoicesCount = await instance.invoicesCount();
        productPrice = await instance
          .products(key)
          .then((result) => result.price.toString());
        try {
          await instance.buyProduct(key, {
            from: arbitrator,
            gas: 400000,
            value: productPrice,
          });
        } catch (error) {
          // verify
          assert(error.reason, "Arbitrator can not buy a product");
        }
        afterInvoicesCount = await instance.invoicesCount();

        // verify
        assert(
          beforeInvoicesCount.toNumber() === afterInvoicesCount.toNumber()
        );
      });

      it("seller tries to buy his own product", async () => {
        // setup
        let beforeInvoicesCount, afterInvoicesCount;
        let key = "Rollers";

        // exercise
        beforeInvoicesCount = await instance.invoicesCount();
        productPrice = await instance
          .products(key)
          .then((result) => result.price.toString());
        try {
          await instance.buyProduct(key, {
            from: seller,
            gas: 400000,
            value: productPrice,
          });
        } catch (error) {
          // verify
          assert(error.reason, "Product owner can not buy his own product");
        }
        afterInvoicesCount = await instance.invoicesCount();

        // verify
        assert(
          beforeInvoicesCount.toNumber() === afterInvoicesCount.toNumber()
        );
      });

      it("buyer tries to buy a product with different amount of Ether than the product price", async () => {
        // setup
        let beforeInvoicesCount, afterInvoicesCount;
        let key = "Skateboard";

        // exercise
        beforeInvoicesCount = await instance.invoicesCount();
        productPrice = await instance
          .products(key)
          .then((result) => result.price.toString());
        try {
          await instance.buyProduct(key, {
            from: buyer,
            gas: 400000,
            value: productPrice,
          });
        } catch (error) {
          // verify
          assert(
            error.reason,
            "The paid amount of Ether is different than the price of the product"
          );
        }
        afterInvoicesCount = await instance.invoicesCount();

        // verify
        assert(
          beforeInvoicesCount.toNumber() === afterInvoicesCount.toNumber()
        );
      });

      it("buyer tries to buy a product with ERC20 Token with non-sufficient funds", async () => {
        // setup
        let beforeInvoicesCount, afterInvoicesCount;
        let key = "Bike";

        // exercise
        beforeInvoicesCount = await instance.invoicesCount();

        try {
          await instance.buyProduct(key, {
            from: buyer,
            gas: 400000,
            value: 0,
          });
        } catch (error) {
          // verify
          assert(
            error.reason,
            "To make a deposit for the product, you need to pay the price of tokens in the Ether, where the rate is 1 to 1"
          );
        }
        afterInvoicesCount = await instance.invoicesCount();

        // verify
        assert(
          beforeInvoicesCount.toNumber() === afterInvoicesCount.toNumber()
        );
      });
    });

    describe("Confirm product sale testing", () => {
      it("buyer tries to confirm product sale", async () => {
        // setup
        let beforeInvoiceConfirmation, afterInvoiceConfirmation, productPrice;
        let index = 3;
        let key = "Bike";

        // exercise
        beforeInvoiceConfirmation = await instance
          .invoices(index)
          .then((result) => result.isConfirmed);
        productPrice = await instance
          .products(key)
          .then((result) => result.price.toString());
        try {
          await instance.buyProduct(key, {
            from: buyer,
            gas: 400000,
            value: web3.utils.toWei(productPrice),
          });
          await instance.confirmProductSale(index, {
            from: buyer,
          });
        } catch (error) {
          // verify
          assert(
            error.reason,
            "In order to confirm the product sale, it is necessary to be a seller of the product"
          );
        }

        afterInvoiceConfirmation = await instance
          .invoices(index)
          .then((result) => result.isConfirmed);

        // verify
        assert(!beforeInvoiceConfirmation && !afterInvoiceConfirmation);
      });

      it("seller tries to confirm already confirmed product sale", async () => {
        // setup
        let beforeInvoiceConfirmation, afterInvoiceConfirmation, productPrice;
        let index = 2;

        // exercise
        beforeInvoiceConfirmation = await instance
          .invoices(index)
          .then((result) => result.isConfirmed);
        try {
          await instance.confirmProductSale(index, {
            from: seller,
          });
        } catch (error) {
          // verify
          assert(error.reason, "The transaction has been executed already");
        }

        afterInvoiceConfirmation = await instance
          .invoices(index)
          .then((result) => result.isConfirmed);

        // verify
        assert(beforeInvoiceConfirmation && afterInvoiceConfirmation);
      });
    });

    describe("Make complaint testing", () => {
      it("arbitrator tries to make a complaint on a product", async () => {
        // setup
        let beforeComplainsCount, afterComplainsCount;
        let index = 0;

        // exercise
        beforeComplainsCount = await instance.complainsCount();

        try {
          await instance.makeComplaint(index, "The product is broken", {
            from: arbitrator,
          });
        } catch (error) {
          // verify
          assert(error.reason, "Arbitrator can not make complaint");
        }

        afterComplainsCount = await instance.complainsCount();

        // verify
        assert(
          beforeComplainsCount.toNumber() === afterComplainsCount.toNumber()
        );
      });

      it("buyer tries to make a complaint with a non-existent index of invoice", async () => {
        // setup
        let beforeComplainsCount, afterComplainsCount;
        let index = 5;

        // exercise
        beforeComplainsCount = await instance.complainsCount();

        try {
          await instance.makeComplaint(index, "The product is broken", {
            from: buyer,
          });
        } catch (error) {
          // verify
          assert(error.reason, "There is no invoice for this index");
        }

        afterComplainsCount = await instance.complainsCount();

        // verify
        assert(
          beforeComplainsCount.toNumber() === afterComplainsCount.toNumber()
        );
      });
    });

    describe("Resolve complaint testing", () => {
      it("arbitrator tries to resolve a complaint with a non-existent index", async () => {
        // setup
        let beforeComplainsCount, afterComplainsCount;
        let index = 5;

        // exercise
        beforeComplainsCount = await instance.complainsCount();

        try {
          await instance.resolveComplaint(
            index,
            "Product is broken, refund issued",
            {
              from: arbitrator,
            }
          );
        } catch (error) {
          // verify
          assert(error.reason, "There is no complaint for this index");
        }

        afterComplainsCount = await instance.complainsCount();

        // verify
        assert(
          beforeComplainsCount.toNumber() === afterComplainsCount.toNumber()
        );
      });

      it("buyer tries to resolve a complaint", async () => {
        // setup
        let beforeComplainsCount, afterComplainsCount;
        let index = 0;

        // exercise
        beforeComplainsCount = await instance.complainsCount();

        try {
          await instance.resolveComplaint(
            index,
            "Product is broken, refund issued",
            {
              from: buyer,
            }
          );
        } catch (error) {
          // verify
          assert(error.reason, "Buyer can not resolve complaints");
        }

        afterComplainsCount = await instance.complainsCount();

        // verify
        assert(
          beforeComplainsCount.toNumber() === afterComplainsCount.toNumber()
        );
      });

      it("seller tries to resolve a complaint", async () => {
        // setup
        let beforeComplainsCount, afterComplainsCount;
        let index = 0;

        // exercise
        beforeComplainsCount = await instance.complainsCount();

        try {
          await instance.resolveComplaint(
            index,
            "Seller can not resolve complaints",
            {
              from: seller,
            }
          );
        } catch (error) {
          // verify
          assert(error.reason, "There is no complaint for this index");
        }

        afterComplainsCount = await instance.complainsCount();

        // verify
        assert(
          beforeComplainsCount.toNumber() === afterComplainsCount.toNumber()
        );
      });

      it("arbitrator tries to resolve already resolved complaint", async () => {
        // setup
        let beforeComplainsCount, afterComplainsCount;
        let index = 0;

        // exercise
        beforeComplainsCount = await instance.complainsCount();

        try {
          await instance.resolveComplaint(
            index,
            "Product is broken, refund issued",
            {
              from: arbitrator,
            }
          );
        } catch (error) {
          // verify
          assert(
            error.reason,
            "Only unresolved complaints is possible to resolve"
          );
        }

        afterComplainsCount = await instance.complainsCount();

        // verify
        assert(
          beforeComplainsCount.toNumber() === afterComplainsCount.toNumber()
        );
      });
    });
  });
});
