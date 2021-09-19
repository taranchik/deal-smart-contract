// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma abicoder v2;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlyOwner(address _sender) {
        require(isOwner[_sender], "MultiSigWallet: not owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "MultiSigWallet: tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "MultiSigWallet: tx already executed");
        _;
    }

    modifier notConfirmed(address _sender, uint _txIndex) {
        require(!isConfirmed[_txIndex][_sender], "MultiSigWallet: tx already confirmed");
        _;
    }
// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c"],2
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "MultiSigWallet: owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "MultiSigWallet: invalid number of required confirmations"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "MultiSigWallet: invalid owner");
            require(!isOwner[owner], "MultiSigWallet: owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    function deposit() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(
        address _sender,
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner(_sender) {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(address _sender, uint _txIndex)
        public
        onlyOwner(_sender)
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_sender, _txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][_sender] = true;

        emit ConfirmTransaction(_sender, _txIndex);
    }
    
    event checkEvent(Transaction);

    function executeTransaction(address _sender, uint _txIndex)
        public
        onlyOwner(_sender)
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "MultiSigWallet: cannot execute tx"
        );

        transaction.executed = true;


        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        
        
        
        require(success, "MultiSigWallet: tx failed");

        emit ExecuteTransaction(_sender, _txIndex);
    }

    function revokeConfirmation(address _sender, uint _txIndex)
        public
        onlyOwner(_sender)
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][_sender], "MultiSigWallet: tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][_sender] = false;

        emit RevokeConfirmation(_sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
    
    function getContractAddress()
        public
       view
        returns (
            address contractAddress
            
                    )
    {
        

        return 
            address(this);
           
        
    }
}
