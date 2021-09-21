// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
pragma abicoder v2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0-solc-0.7/contracts/token/ERC20/ERC20.sol";
import "./MultiSigWallet.sol";

contract Deal {
    MultiSigWallet private multiSigWallet;
    address private arbitrator;
    mapping(uint256 => Complaint) private complains;
    mapping(uint256 => Invoice) private invoices;
    mapping(string => Product) private products;
    mapping(string => ERC20Token) private ERC20Tokens;
    uint256 private complainsCount = 0;
    uint256 private invoicesCount = 0;

    constructor(address[] memory _owners) {
        multiSigWallet = new MultiSigWallet(_owners, 2);

        ERC20Tokens["USDC"] = ERC20Token({
            token: ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48),
            tokenOwner: 0x95Ba4cF87D6723ad9C0Db21737D862bE80e93911
        });
        ERC20Tokens["DAI"] = ERC20Token({
            token: ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F),
            tokenOwner: 0xdDb108893104dE4E1C6d0E47c42237dB4E617ACc
        });
        ERC20Tokens["LINK"] = ERC20Token({
            token: ERC20(0x514910771AF9Ca656af840dff83E8264EcF986CA),
            tokenOwner: 0xf55037738604FDDFC4043D12F25124E94D7D1780
        });
        ERC20Tokens["NULL"] = ERC20Token({
            token: ERC20(address(0)),
            tokenOwner: address(0)
        });

        products["Bike"] = Product({
            price: 1,
            token: ERC20Tokens["USDC"],
            isBroken: false,
            productOwner: msg.sender
        });
        products["Car"] = Product({
            price: 5,
            token: ERC20Tokens["DAI"],
            isBroken: true,
            productOwner: msg.sender
        });
        products["Rollers"] = Product({
            price: 2,
            token: ERC20Tokens["LINK"],
            isBroken: false,
            productOwner: msg.sender
        });
        products["Skateboard"] = Product({
            price: 2 ether,
            token: ERC20Tokens["NULL"],
            isBroken: false,
            productOwner: msg.sender
        });
    }

    struct ERC20Token {
        ERC20 token;
        address tokenOwner;
    }

    struct Product {
        uint256 price;
        ERC20Token token;
        bool isBroken;
        address productOwner;
    }

    struct Invoice {
        address payable buyer;
        address payable seller;
        string productName;
        uint256 price;
        uint256 date;
        uint256 transactionIndex;
        bool isConfirmed;
    }

    struct Complaint {
        Invoice invoice;
        string buyerComment;
        string sellerComment;
        string arbitratorComment;
        bool isResolved;
    }

    function getInvoiceInfo(uint256 invoiceIndex)
        public
        view
        returns (
            address,
            address payable,
            string memory,
            uint256,
            uint256
        )
    {
        require(
            invoiceIndex < invoicesCount,
            "There is no invoice for this index"
        );

        return (
            invoices[invoiceIndex].buyer,
            invoices[invoiceIndex].seller,
            invoices[invoiceIndex].productName,
            invoices[invoiceIndex].price,
            invoices[invoiceIndex].date
        );
    }

    //   ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c"]
    function getProductInfo(string memory name)
        public
        view
        returns (
            uint256,
            ERC20Token memory,
            bool,
            address
        )
    {
        return (
            products[name].price,
            products[name].token,
            products[name].isBroken,
            products[name].productOwner
        );
    }

    function getComplaintInfo(uint256 complaintIndex)
        public
        view
        returns (
            Invoice memory,
            string memory,
            string memory,
            string memory,
            bool
        )
    {
        require(
            complaintIndex < complainsCount,
            "There is no complaint for this index"
        );

        return (
            complains[complaintIndex].invoice,
            complains[complaintIndex].buyerComment,
            complains[complaintIndex].sellerComment,
            complains[complaintIndex].arbitratorComment,
            complains[complaintIndex].isResolved
        );
    }

    function buyProduct(string memory productName) public payable {
        require(
            products[productName].price != 0,
            "Purchase of a non-existent product is not possible"
        );

        require(arbitrator != msg.sender, "The arbitrator can't buy a product");

        require(
            products[productName].productOwner != msg.sender,
            "The product owner can't buy his own product"
        );

        invoices[invoicesCount] = Invoice({
            buyer: msg.sender,
            seller: payable(products[productName].productOwner),
            productName: productName,
            price: products[productName].price,
            date: block.timestamp,
            transactionIndex: invoicesCount,
            isConfirmed: false
        });

        if (products[productName].token.tokenOwner == address(0)) {
            require(
                products[productName].price == msg.value,
                "The paid amount of Ether is different than the price of the product"
            );

            multiSigWallet.submitTransaction(
                msg.sender,
                invoices[invoicesCount].seller,
                invoices[invoicesCount].price
            ); // submit transfer eather from buyer to seller
            multiSigWallet.confirmTransaction(
                msg.sender,
                invoices[invoicesCount].transactionIndex
            );
            invoicesCount++;
        } else {
            require(
                products[productName].token.token.balanceOf(msg.sender) >=
                    products[productName].price,
                "There are enough ERC20 tokens to cover the cost of the product"
            );

            products[productName].productOwner = msg.sender;
            products[productName].token.token.approve(
                invoices[invoicesCount].buyer,
                products[productName].price
            );
            products[productName].token.token.transferFrom(
                invoices[invoicesCount].buyer,
                invoices[invoicesCount].seller,
                products[productName].price
            ); // transfer eather from buyer to seller
        }
    }

    function confirmProductSale(uint256 invoiceIndex) public {
        require(
            invoices[invoiceIndex].seller == msg.sender,
            "In order to confirm the product sale, it is necessary to be a seller of the product"
        );

        multiSigWallet.confirmTransaction(
            msg.sender,
            invoices[invoiceIndex].transactionIndex
        );
        multiSigWallet.executeTransaction(
            msg.sender,
            invoices[invoiceIndex].transactionIndex
        );

        (, , bool exectued, ) = multiSigWallet.getTransaction(
            invoices[invoiceIndex].transactionIndex
        );

        require(
            exectued,
            "The transaction is not confirmed by at least two persons yet"
        );

        invoices[invoiceIndex].isConfirmed = true;
        products[invoices[invoiceIndex].productName].productOwner = invoices[
            invoiceIndex
        ].buyer;
        invoices[invoiceIndex].seller.transfer(invoices[invoiceIndex].price); // transfer eather from smart contract to the seller
    }

    function makeComplaint(uint256 invoiceIndex, string memory comment) public {
        require(
            invoiceIndex < invoicesCount,
            "There is no invoice for this index"
        );

        require(
            invoices[invoiceIndex].buyer == msg.sender ||
                invoices[invoiceIndex].seller == msg.sender,
            "It is impossible to complain not yours invoice"
        );

        string memory buyerComment = "";
        string memory sellerComment = "";

        if (msg.sender == invoices[invoiceIndex].buyer) {
            buyerComment = comment;
        } else {
            sellerComment = comment;
        }

        complains[complainsCount] = Complaint({
            invoice: invoices[invoiceIndex],
            buyerComment: buyerComment,
            sellerComment: sellerComment,
            arbitratorComment: "",
            isResolved: false
        });

        complainsCount++;
    }

    function resolveComplaint(
        uint256 complaintIndex,
        string memory comment,
        bool acceptPayment
    ) public payable {
        require(
            complaintIndex < complainsCount,
            "There is no complaint for this index"
        );

        require(
            complains[complaintIndex].invoice.buyer != msg.sender,
            "Buyer can not resolve complaints"
        );

        require(
            complains[complaintIndex].invoice.seller != msg.sender,
            "Seller can not resolve complaints"
        );

        require(
            complains[complaintIndex].isResolved != true,
            "Only unresolved complaints is possible to resolve"
        );

        arbitrator = msg.sender;

        Invoice memory invoice = complains[complaintIndex].invoice;

        if (acceptPayment) {
            multiSigWallet.confirmTransaction(
                msg.sender,
                complains[complaintIndex].invoice.transactionIndex
            );
            multiSigWallet.executeTransaction(
                msg.sender,
                complains[complaintIndex].invoice.transactionIndex
            );
            invoice.seller.transfer(invoice.price); // transfer eather from smart contract to the seller
        } else {
            invoice.buyer.transfer(invoice.price); // transfer eather from smart contract to the buyer
        }

        complains[complaintIndex].arbitratorComment = comment;
        complains[complaintIndex].isResolved = true;
    }
}
