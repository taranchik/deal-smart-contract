// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0-solc-0.7/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0-solc-0.7/contracts/token/ERC20/ERC20.sol";

contract DummyERC20 is ERC20 {

    constructor (string memory tokenName, string memory tokenSymbol) ERC20(tokenName, tokenSymbol) {}
    
    function faucet(address to, uint amount) external {
        _mint(to, amount);
    }
}

contract Deal {
    address private arbitrator;
    Complaint[] private complains;
    Invoice[] private invoices;
    mapping(string => Product) private products;
    
    constructor() {
        products["Bike"] = Product({ price: 1, tokenAddress: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, isBroken: false, productOwner: msg.sender });
        products["Car"] = Product({ price: 5, tokenAddress: 0xdAC17F958D2ee523a2206206994597C13D831ec7, isBroken: true, productOwner: msg.sender });
        products["Rollers"] = Product({ price: 2, tokenAddress: 0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE, isBroken: false, productOwner: msg.sender });
        products["Skateboard"] = Product({ price: 2, tokenAddress: address(0), isBroken: false, productOwner: msg.sender });
    }
    
    struct Product {
        uint price;
        address tokenAddress;
        bool isBroken;
        address productOwner;
    }

    struct Invoice {
        address buyer;
        address payable seller;
        string productName;
        uint price;
        uint date;
    }

    struct Complaint {
        Invoice invoice;
        string buyerComment;
        string sellerComment;
        string arbitratorComment;
        bool _isResolved;
   }
   
   function getInvoiceInfo(uint invoiceIndex) public view returns(address, address payable, string memory, uint) {
       return (invoices[invoiceIndex].buyer, invoices[invoiceIndex].seller, invoices[invoiceIndex].productName, invoices[invoiceIndex].price);
   } 
   
   function getProductInfo(string memory name) public view returns(uint, address, bool, address) {
       return(products[name].price, products[name].tokenAddress, products[name].isBroken, products[name].productOwner);
   }
   
   event tokenName(uint);
   
   function exchangeOneEtherToERC20(address tokenAddress) public payable {
       require(msg.value == 1 ether, "Should be sent for exchanging exactly 1 ether");
       
       ERC20 token = ERC20(tokenAddress);
       DummyERC20(token.name(), token.symbol()).faucet(msg.sender, 10);
       
       emit tokenName(token.balanceOf(msg.sender));
       
    //   token._mint(tokenAddress, msg.sender, 1);
   }
   
   // accepts Ether
   function buyProductWithEther(string memory productName) payable public {
       require(products[productName].price != 0, "Purchase of a non-existent product is not possible");
       
       require(arbitrator != msg.sender, "The arbitrator can't buy a product");
       
       require(products[productName].productOwner != msg.sender, "The product owner can't buy his own product");
       
       require(products[productName].price == msg.value, "There are enough funds to cover the cost of the product");
       
       uint invoiceIndex = invoices.length;
       
       invoices.push(Invoice({
        buyer: msg.sender,
        seller: payable(products[productName].productOwner),
        productName: productName,
        price: products[productName].price,
        date: block.timestamp
    }));
       
       products[productName].productOwner = msg.sender;
       invoices[invoiceIndex].seller.transfer(products[productName].price); // transfer eather from buyer to seller
    }
    
    event tokenInfo(uint);

   // accepts ERC20 tokens
   function buyProductWithERC20Token(string memory productName, address tokenAddress) public {
       IERC20 token = IERC20(tokenAddress);

       require(products[productName].price != 0, "Purchase of a non-existent product is not possible");
       
       require(arbitrator != msg.sender, "The arbitrator can't buy a product");
       
       require(products[productName].productOwner != msg.sender, "The product owner can't buy his own product");
       
       require(token.balanceOf(msg.sender) >= products[productName].price, "There are enough funds to cover the cost of the product");
    
       uint invoiceIndex = invoices.length;
        
       invoices.push(Invoice({
        buyer: msg.sender,
        seller: payable(products[productName].productOwner),
        productName: productName,
        price: products[productName].price,
        date: block.timestamp
    }));
        
        emit tokenInfo(token.balanceOf(msg.sender));
        products[productName].productOwner = msg.sender;
        token.approve(invoices[invoiceIndex].buyer, products[productName].price);
        token.transferFrom(invoices[invoiceIndex].buyer, invoices[invoiceIndex].seller, products[productName].price); // transfer eather from buyer to seller
    }
    
    // function makeComplaint(string memory productName) public {
        
    // }
    
    // function resolveComplaint(string memory productName) public {
    //     require(arbitrator == msg.sender, "Only arbitrator can resolve complaint");
    // }
}
