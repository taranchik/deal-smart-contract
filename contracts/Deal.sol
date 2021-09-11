// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Deal {
    address private arbitrator;
    mapping(uint => Complaint) private complains;
    mapping(uint => Invoice) private invoices;
    mapping(string => Product) private products;
    uint private complainsCount = 0;
    uint private invoicesCount = 0;
    
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
        bool isResolved;
   }
   
   function getInvoiceInfo(uint invoiceIndex) public view returns(address, address payable, string memory, uint) {
       require(invoiceIndex < invoicesCount, "There is no invoice for this index");
       
       return (invoices[invoiceIndex].buyer, invoices[invoiceIndex].seller, invoices[invoiceIndex].productName, invoices[invoiceIndex].price);
   } 
   
   function getProductInfo(string memory name) public view returns(uint, address, bool, address) {
       return(products[name].price, products[name].tokenAddress, products[name].isBroken, products[name].productOwner);
   }
   
   function getComplaintInfo(uint complaintIndex) public view returns(Invoice memory, string memory, string memory, string memory, bool) {
       require(complaintIndex < complainsCount, "There is no complaint for this index");
       
       return(complains[complaintIndex].invoice, 
            complains[complaintIndex].buyerComment,
                complains[complaintIndex].sellerComment, 
                complains[complaintIndex].arbitratorComment, 
                complains[complaintIndex].isResolved);
   }
   
//   function exchangeOneEtherToERC20(address tokenAddress) public payable {
//       require(msg.value == 1 ether, "Should be sent for exchanging exactly 1 ether");
      
//       ERC20 token = ERC20(tokenAddress);
      
//       token.approve(msg.sender, 1);
//       token.transfer(msg.sender, 1);
//     }
   
   // accepts Ether
   function buyProductWithEther(string memory productName) payable public {
       require(products[productName].price != 0, "Purchase of a non-existent product is not possible");
       
       require(arbitrator != msg.sender, "The arbitrator can't buy a product");
       
       require(products[productName].productOwner != msg.sender, "The product owner can't buy his own product");
       
       require(products[productName].price == msg.value, "There are enough funds to cover the cost of the product");
       
       require(products[productName].tokenAddress == address(0), "The product can not be pruchased for Ether");
       
       invoices[invoicesCount] = Invoice({
        buyer: msg.sender,
        seller: payable(products[productName].productOwner),
        productName: productName,
        price: products[productName].price,
        date: block.timestamp
    });
       
       products[productName].productOwner = msg.sender;
       invoices[invoicesCount].seller.transfer(products[productName].price); // transfer eather from buyer to seller
       invoicesCount++;
    }

   // accepts ERC20 tokens
   function buyProductWithERC20Token(string memory productName, address tokenAddress) public {
       require(address(tokenAddress) != address(0), "The address of the token can not be null");
       
       require(products[productName].price != 0, "Purchase of a non-existent product is not possible");
       
       require(products[productName].tokenAddress == tokenAddress, "The product is sold for a different token");
       
       require(arbitrator != msg.sender, "The arbitrator can't buy a product");
       
       require(products[productName].productOwner != msg.sender, "The product owner can't buy his own product");
       
       ERC20 token = ERC20(tokenAddress);
       
       require(token.balanceOf(msg.sender) >= products[productName].price, "There are enough funds to cover the cost of the product");
    
       invoices[invoicesCount] = Invoice({
        buyer: msg.sender,
        seller: payable(products[productName].productOwner),
        productName: productName,
        price: products[productName].price,
        date: block.timestamp
    });
        
        products[productName].productOwner = msg.sender;
        token.approve(invoices[invoicesCount].buyer, products[productName].price);
        token.transferFrom(invoices[invoicesCount].buyer, invoices[invoicesCount].seller, products[productName].price); // transfer eather from buyer to seller
        invoicesCount++;
    }
    
    function makeComplaint(uint invoiceIndex, string memory comment) public {
        require(invoiceIndex < invoicesCount, "There is no invoice for this index");
        
        require(invoices[invoiceIndex].buyer == msg.sender || 
                invoices[invoiceIndex].seller == msg.sender, 
                    "It is impossible to complain not yours invoice");
                    
        string memory buyerComment = '';
        string memory sellerComment = '';
        
        if(msg.sender == invoices[invoiceIndex].buyer){
            buyerComment = comment;
        }
        else{
            sellerComment = comment;
        }
                    
        complains[complainsCount] = Complaint({
            invoice: invoices[invoiceIndex],
            buyerComment: buyerComment,
            sellerComment: sellerComment,
            arbitratorComment: '',
            isResolved: false
        });

        complainsCount++;
    }
    
    function resolveComplaint(uint complaintIndex, string memory comment) public {
        require(complaintIndex < complainsCount, "There is no complaint for this index");
        
        require(complains[complaintIndex].invoice.buyer != msg.sender, "Buyer can not resolve complaints");
        
        require(complains[complaintIndex].invoice.seller != msg.sender, "Seller can not resolve complaints");
                   
        require(complains[complaintIndex].isResolved != true, "Only unresolved complaints is possible to resolve");
        
        arbitrator = msg.sender;
                    
        complains[complaintIndex].arbitratorComment = comment;
        complains[complaintIndex].isResolved = true;s
}
