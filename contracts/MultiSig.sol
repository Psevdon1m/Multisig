pragma solidity ^0.6.0;

contract Multisig {
    address public manager;

    uint256 public minimumContribution;

    //This represents a stucture for a new Kickstarter campaing
    struct Request {
        uint256 value;
        address payable recepient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    mapping(address => bool) public approvers;
    uint256 public approversCount;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    //enter minimum contribution amount when deployed
    constructor(uint256 minimum) public {
        manager = msg.sender;
        minimumContribution = minimum;
    }

    //function that allows a person to became a voter
    function contribute() public payable {
        require(
            msg.value > minimumContribution,
            "you need to deposit more ether"
        );
        approvers[msg.sender] = true;
        approversCount++;
    }

    //This functions helps manager to create a request for sending funds to another wallet
    function createRequest(uint256 value, address payable recepient)
        public
        restricted
    {
        require(
            value <= address(this).balance,
            "balance of the contract is less than proposed value"
        );
        Request memory newRequest = Request({
            value: value,
            recepient: recepient,
            approvalCount: 0,
            complete: false
        });

        requests.push(newRequest);
    }

    //Voting mechanism for deciding whether the participants/contributors allow the transaction

    function approveRequest(uint256 index) public {
        Request storage request = requests[index];

        require(
            approvers[msg.sender],
            "You are not among approvers, donate to contract"
        );
        require(!request.approvals[msg.sender], "You have already voted!");

        request.approvals[msg.sender] = true;
        request.approvalCount++;
        if (request.approvalCount > (approversCount / 2)) {
            finalizeRequest(index);
        }
    }

    //This function helps the  manager close the request based on either approved or rejected outcome

    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];

        require(!request.complete, "This request has already been complete!");
        require(
            request.approvalCount > (approversCount / 2),
            "Not enough votes to end the voting! "
        );
        require(
            request.value <= address(this).balance,
            "not enough funds to send"
        );
        request.recepient.transfer(request.value);
        request.complete = true;
        //delete request
        // delete requests[index];
    }
}
