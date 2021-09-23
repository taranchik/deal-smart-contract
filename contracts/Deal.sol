// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
pragma abicoder v2;

import "./CustomERC20.sol";
import "./MultiSigWallet.sol";

contract Deal {
    MultiSigWallet private multiSigWallet;
    address private arbitrator;
    mapping(uint256 => Complaint) public complains;
    mapping(uint256 => Invoice) public invoices;
    mapping(string => Product) public products;
    mapping(string => ERC20Token) public ERC20Tokens;
    uint256 public complainsCount = 0;
    uint256 public invoicesCount = 0;

    constructor(address[] memory _owners) {
        require(
            _owners.length == 3,
            "Smart contract accepts only 3 owners for the Multisig wallet"
        );

        arbitrator = _owners[2];

        multiSigWallet = new MultiSigWallet(_owners, 2);

        ERC20Tokens["USDC"] = ERC20Token({
            token: new CustomERC20("USDC", "USD coin"),
            isMinted: false
        });
        ERC20Tokens["DAI"] = ERC20Token({
            token: new CustomERC20("DAI", "Dai"),
            isMinted: false
        });
        ERC20Tokens["LINK"] = ERC20Token({
            token: new CustomERC20("LINK", "Chainlink"),
            isMinted: false
        });
        ERC20Tokens["ETH"] = ERC20Token({
            token: new CustomERC20("ETH", "Ethereum"),
            isMinted: false
        });

        products["Bike"] = Product({
            price: 1,
            token: ERC20Tokens["USDC"].token,
            isBroken: false,
            productOwner: msg.sender
        });
        products["Car"] = Product({
            price: 5,
            token: ERC20Tokens["DAI"].token,
            isBroken: true,
            productOwner: msg.sender
        });
        products["Rollers"] = Product({
            price: 2,
            token: ERC20Tokens["LINK"].token,
            isBroken: false,
            productOwner: msg.sender
        });
        products["Skateboard"] = Product({
            price: 2 ether,
            token: ERC20Tokens["ETH"].token,
            isBroken: false,
            productOwner: msg.sender
        });
    }

    struct ERC20Token {
        CustomERC20 token;
        bool isMinted;
    }

    struct Product {
        uint256 price;
        CustomERC20 token;
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

    event ApproveTransaction(address payable recipient, uint256 amount);

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
        return (
            invoices[invoiceIndex].buyer,
            invoices[invoiceIndex].seller,
            invoices[invoiceIndex].productName,
            invoices[invoiceIndex].price,
            invoices[invoiceIndex].date
        );
    }

    function getProductInfo(string memory name)
        public
        view
        returns (
            uint256,
            string memory,
            bool,
            address
        )
    {
        return (
            products[name].price,
            products[name].token.symbol(),
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
        return (
            complains[complaintIndex].invoice,
            complains[complaintIndex].buyerComment,
            complains[complaintIndex].sellerComment,
            complains[complaintIndex].arbitratorComment,
            complains[complaintIndex].isResolved
        );
    }

    function buyProduct(string memory productName) public payable {
        require(arbitrator != msg.sender, "Arbitrator can not buy a product");

        require(
            products[productName].price != 0,
            "Purchase of a non-existent product is not possible"
        );

        require(
            products[productName].productOwner != msg.sender,
            "Product owner can not buy his own product"
        );

        invoices[invoicesCount] = Invoice({
            buyer: payable(msg.sender),
            seller: payable(products[productName].productOwner),
            productName: productName,
            price: products[productName].price,
            date: block.timestamp,
            transactionIndex: invoicesCount,
            isConfirmed: false
        });

        string memory symbol = products[productName].token.symbol();

        if (
            keccak256(abi.encodePacked(symbol)) ==
            keccak256(abi.encodePacked("ETH"))
        ) {
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
            if (
                products[productName].token.balanceOf(msg.sender) <=
                products[productName].price
            ) {
                // This require statement makes sense only in case if the contract has more than one buyer and seller
                // require(
                //     !ERC20Tokens[symbol].isMinted,
                //     "ERC20 Token for this product has been already minted"
                // );

                require(
                    products[productName].price * 1 ether == msg.value,
                    "To make a deposit for the product, you need to pay the price of tokens in the Ether, where the rate is 1 to 1"
                );

                ERC20Tokens[symbol].token.mint(
                    address(this),
                    products[productName].price
                );
                ERC20Tokens[symbol].isMinted = true;
            } else {
                // This require statement makes sense only in case if the contract has more than one buyer and seller
                // require(
                //     products[productName].token.balanceOf(msg.sender) >=
                //         products[productName].price,
                //     "There are not enough tokens on the balance"
                // );

                products[productName].token.transferFromERC20(
                    msg.sender,
                    address(this),
                    products[productName].price
                );
            }

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
        }
    }

    function approveTransaction(
        Product storage product,
        address payable recipient
    ) private {
        string memory symbol = product.token.symbol();

        if (
            keccak256(abi.encodePacked(symbol)) ==
            keccak256(abi.encodePacked("ETH"))
        ) {
            recipient.transfer(product.price); // transfer eather from smart contract to the seller
        } else {
            product.token.transfer(recipient, product.price); // transfer tokens from smart contract to the seller
        }

        emit ApproveTransaction(recipient, product.price);
    }

    function confirmProductSale(uint256 invoiceIndex) public {
        require(
            invoices[invoiceIndex].seller == msg.sender,
            "In order to confirm the product sale, it is necessary to be a seller of the product"
        );

        require(
            !invoices[invoiceIndex].isConfirmed,
            "The transaction has been executed already"
        );

        multiSigWallet.confirmTransaction(
            msg.sender,
            invoices[invoiceIndex].transactionIndex
        );

        multiSigWallet.executeTransaction(
            msg.sender,
            invoices[invoiceIndex].transactionIndex
        );

        approveTransaction(
            products[invoices[invoiceIndex].productName],
            invoices[invoiceIndex].seller
        );

        invoices[invoiceIndex].isConfirmed = true;
        products[invoices[invoiceIndex].productName].productOwner = invoices[
            invoiceIndex
        ].buyer;
    }

    function makeComplaint(uint256 invoiceIndex, string memory comment) public {
        require(arbitrator != msg.sender, "Arbitrator can not make complaint");

        require(
            invoiceIndex < invoicesCount,
            "There is no invoice for this index"
        );

        // This require statement makes sense only in case if the contract has more than one buyer and seller
        // require(
        //     invoices[invoiceIndex].buyer == msg.sender ||
        //         invoices[invoiceIndex].seller == msg.sender,
        //     "It is impossible to complain not yours invoice"
        // );

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

    function resolveComplaint(uint256 complaintIndex, string memory comment)
        public
        payable
    {
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

        Invoice storage invoice = complains[complaintIndex].invoice;

        if (products[invoice.productName].isBroken) {
            multiSigWallet.confirmTransaction(
                msg.sender,
                complains[complaintIndex].invoice.transactionIndex
            );
            multiSigWallet.executeTransaction(
                msg.sender,
                complains[complaintIndex].invoice.transactionIndex
            );
            approveTransaction(products[invoice.productName], invoice.buyer); // transfer eather from smart contract to the buyer back
        }

        complains[complaintIndex].arbitratorComment = comment;
        complains[complaintIndex].isResolved = true;
    }
}
