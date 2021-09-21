// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma abicoder v2;

contract MultiSigWallet {
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value
    );
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        uint256 numConfirmations;
    }

    // mapping from tx index => owner => bool
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    Transaction[] public transactions;

    modifier onlyOwner(address _sender) {
        require(isOwner[_sender], "MultiSigWallet: not owner");
        _;
    }

    modifier txExists(uint256 _txIndex) {
        require(
            _txIndex < transactions.length,
            "MultiSigWallet: tx does not exist"
        );
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(
            !transactions[_txIndex].executed,
            "MultiSigWallet: tx already executed"
        );
        _;
    }

    modifier notConfirmed(address _sender, uint256 _txIndex) {
        require(
            !isConfirmed[_txIndex][_sender],
            "MultiSigWallet: tx already confirmed"
        );
        _;
    }

    constructor(address[] memory _owners, uint256 _numConfirmationsRequired) {
        require(_owners.length > 0, "MultiSigWallet: owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "MultiSigWallet: invalid number of required confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "MultiSigWallet: invalid owner");
            require(!isOwner[owner], "MultiSigWallet: owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    function submitTransaction(
        address _sender,
        address _to,
        uint256 _value
    ) public onlyOwner(_sender) {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value);
    }

    function confirmTransaction(address _sender, uint256 _txIndex)
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

    function executeTransaction(address _sender, uint256 _txIndex)
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

        emit ExecuteTransaction(_sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 _txIndex)
        public
        view
        returns (
            address to,
            uint256 value,
            bool executed,
            uint256 numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}
