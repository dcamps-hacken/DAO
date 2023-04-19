pragma solidity 0.8.0;

contract DAOproposal {

    address manager; //should this be set now or after deployment?
    mapping (uint256 => uint256) votes; //voteOption => number of votes
    mapping (address => bool) hasVoted; //voter => hasVoted

    event Voted(uint256 indexed _voteOption, address indexed voter);

    modifier onlyManager {
        require(msg.sender == manager, "invalid caller");
        _;
    }

    constructor(address _manager) {
        require(_manager != address(0), "invalid proxy address");
        manager = _manager;
    }

    function vote(uint256 _voteOption, address _voter) external onlyManager { //_optionId is Y/N
        require(!hasVoted[_voter], "already voted");
        hasVoted[_voter] = true;
        votes[_voteOption] += 1;
        emit Voted(_voteOption, _voter);
    }
}