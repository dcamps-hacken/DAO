pragma solidity 0.8.7;

contract DAOproposal is Ownable {

    address manager; //should this be set now or after deployment?
    uint256 public votes;

    Event Voted(address indexed voter);

    modifier onlyManager {
        require(msg.sender == manager, "invalid caller");
        _;
    }

    constructor(address _manager, uint256 _optionNum) {//initialize?
        require(_manager != address(0), "invalid proxy address");
        manager = _manager;
        optionNum = _optionNum;
    }

    function vote() external onlyManager {
        votes += 1;
        emit Voted(_voter);
    }
}