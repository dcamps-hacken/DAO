pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";


contract TransparentManager is Ownable {
    
    struct Signer {
        bool isValid;
        uint256 nonce; //nonce is tight to address
    }

    uint256 public proposalId;
    mapping(uint256 => address) public proposals;
    
    event ProposalCreated(uint256 indexed _proposalId, address indexed _proposalAddress);

    function createProposal(address _implementation, bytes memory _data) external onlyOwner {
        ERC1967Proxy newProxy = new ERC1967Proxy(_implementation, _data);//@audit how to mange _data?
        proposals[proposalId] = address(newProxy);
        proposalId++;
        emit ProposalCreated(proposalId, address(newProxy));
    }

}