pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

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

contract DAOmanagerEIP712 is OwnableUpgradeable { //OwnableUpggradeable includes Initializable
    
    struct Signer {
        bool isValid;
        uint256 nonce; //nonce is tight to address
    }
    mapping(address => Signer) public validSigners;
    mapping (uint256 => uint256) votes; //voteOption => number of votes
    mapping (address => bool) hasVoted; //voter => hasVoted
    
    event SignerAdded(address indexed _signer);
    event SignerDeleted(address indexed _signer);
    event Voted(uint256 indexed _voteOption, address indexed voter);

    constructor() {
        _disableInitializers();
    }

    function initialize(address _owner) external initializer{
        transferOwnership(_owner);
    }

    function vote(address _sender, uint256 _voteOption, bytes32 _signedHash, bytes32 r, bytes32 s, uint8 v, uint256 _nonce) external { //_optionId is Y/N
        require(_isValidHash(_voteOption, _signedHash, _nonce, _signedHash), "invalid hash");
        
        address signer = ecrecover(_signedHash, v, r, s);//if signed hash is diff and do not correspond to the sig, a different address is given
        require(signer == _sender, "incorrect signer");
        
        require(validSigners[_sender].isValid, "voter has no permission");
        validSigners[_sender].nonce += 1;
        require(!hasVoted[_sender], "already voted");
        hasVoted[_sender] = true;
        votes[_voteOption] += 1;
        emit Voted(_voteOption, _sender);
    }

    function addSigner(address _signer) external onlyOwner{
        validSigners[_signer].isValid = true;
        emit SignerAdded(_signer);
    }

    function deleteSigner(address _signer) external onlyOwner{
        validSigners[_signer].isValid = false;
        emit SignerDeleted(_signer);
    }

    function _isValidHash(uint256 _voteOption, bytes32 _proposalId, uint256 _nonce, bytes32 _signedHash) private pure returns (bool) {
        bytes32 signedMessage = keccak256(abi.encodePacked(_voteOption, _proposalId, _nonce)); //encoded message to use in ethers.getSIgn
        bytes32 ethSignedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", signedMessage));
        if (ethSignedMessage == _signedHash){
            return true;
        }
        return false;
    }
}