pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
/**
* OPEN ZEPPELIN - CLONES
*
* @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
* deploying minimal proxy contracts, also known as "clones".
*
* > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
* > a minimal bytecode implementation that delegates all calls to a known, fixed address.
*
* The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
* (salted deterministic deployment).
*
*/

contract DAOmanagerEIP712 is Ownable {
    
    struct Signer {
        bool isValid;
        uint256 nonce; //nonce is tight to address
    }

    address public immutable implementation;
    uint256 public proposalId;
    mapping(uint256 => address) public proposals;
    
    event ProposalCreated(uint256 indexed _proposalId, address indexed _proposalAddress);

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function createProposal() external onlyOwner {
        address newImplementation = Clones.clone(implementation); //returns new implementation address
        (bool success, ) = newImplementation.call(
            abi.encodeWithSignature("initialize(address)", owner()) //alternatively use interface
        );
        proposalId++;
        emit ProposalCreated(proposalId, newImplementation);
    }

}