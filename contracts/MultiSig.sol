pragma solidity >=0.8.0 <0.9.0;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount);
    event Submin(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    struct Participant {
        address who;
        uint8 votes;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    mapping(address => bool) public isParticipant;
    mapping(address => Participant) public participants;
    mapping(address => mapping(address => bool)) voted;
    uint256 public required;

    Transaction[] public transactions;

    address[] public participantsArray;

    mapping(uint256 => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }
    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx not found");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "tx was already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "tx was executed");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) public {
        require(_owners.length > 0, "owners required");
        require(
            _required > 0 && _required <= _owners.length,
            "owners required"
        );

        for (uint256 i; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid address");
            require(!isOwner[owner], "address registered");

            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, executed: false})
        );
        emit Submin(transactions.length - 1);
    }

    function approve(
        uint256 _txId
    ) external onlyOwner notApproved(_txId) txExists(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(
        uint256 _txId
    ) private view returns (uint256 count) {
        for (uint256 i; i < owners.length; i++) {
            if (approved[_txId][owners[i]]) {
                count += 1;
            }
        }
    }

    function execute(
        uint256 _txId
    ) external txExists(_txId) notExecuted(_txId) onlyOwner {
        require(_getApprovalCount(_txId) >= required, "not enough approvals");

        Transaction storage transaction = transactions[_txId];

        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit Execute(_txId);
    }

    function revoke(
        uint256 _txId
    ) external txExists(_txId) notExecuted(_txId) onlyOwner {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    function addParticipant(
        address _participant
    ) external onlyOwner returns (uint256) {
        require(!isParticipant[_participant], "already participant");
        isParticipant[_participant] = true;
        voted[msg.sender][_participant] = true;
        participants[_participant] = Participant({who: _participant, votes: 1});
        participantsArray.push(_participant);
        return participantsArray.length - 1;
    }

    function addOwner(address _participant) external onlyOwner {
        Participant storage participant = participants[_participant];
        require(participant.votes > 0, "No votes for participant");
        require(
            ((owners.length / participant.votes) % 2) > 0,
            "votes not enough"
        );
        isParticipant[_participant] = false;
        participants[_participant].who = address(0x0);
        participants[_participant].votes = 0;
        isOwner[_participant] = true;
        owners.push(_participant);
    }

    function voteForParticipant(address _participant) external onlyOwner {
        require(!voted[msg.sender][_participant], "already voted");
        require(isParticipant[_participant], "address is not a participant");
        Participant storage participant = participants[_participant];
        participant.votes += 1;
    }

    function getAllOwners() public view returns (address[] memory) {
        return owners;
    }

    function getAllproposedTransactions()
        public
        view
        returns (Transaction[] memory)
    {
        return transactions;
    }

    function removeOwner(address _owner) external onlyOwner {
        require(isOwner[_owner], "addres is not an owner");
        isOwner[_owner] = false;
        for (uint256 i; i < owners.length; i++) {
            if (owners[i] == _owner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
            }
        }
    }
}
