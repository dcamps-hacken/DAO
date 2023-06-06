pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DAOmanager is Ownable { 
    
    struct Signer {
        bool isValid;
        uint256 nonce; 
    }

    mapping(address => Signer) public validSigners;
    mapping(uint256 => address) public proposals;
    
    event NewProposal(uint256 indexed _proposalId, address indexed _proposalAddress);
    event SignerAdded(address indexed _signer);
    event SignerDeleted(address indexed _signer);

    function addProposal(uint256 _proposalId, address _proposalAddress) external onlyOwner {
        require(proposals[_proposalId] == address(0), "ID already used");
        proposals[_proposalId] = _proposalAddress;
        emit NewProposal(_proposalId, _proposalAddress);
    }

    function addSigner(address _signer) external onlyOwner{
        validSigners[_signer].isValid = true;
        emit SignerAdded(_signer);
    }

    function deleteSigner(address _signer) external onlyOwner{
        validSigners[_signer].isValid = false;
        emit SignerDeleted(_signer);
    }

    function getProposal(uint256 _proposalId) external view returns (address){
        return proposals[_proposalId];
    }

    function isValidSigner(address _signer) external view returns (bool) {
        return validSigners[_signer].isValid;
    }

    function voteOnProposal(address _sender, uint256 _voteOption, uint256 _proposalId, bytes32 _signedHash, bytes32 r, bytes32 s, uint8 v, uint256 _nonce) external {
        require(_isValidHash(_voteOption, _signedHash, _nonce, _signedHash), "invalid hash");
        
        address signer = ecrecover(_signedHash, v, r, s);//if signed hash is diff and do not correspond to the sig, a different address is given
        require(signer == _sender, "incorrect signer");
        
        require(validSigners[signer].isValid, "voter has no permission");
        validSigners[signer].nonce += 1;
        _forwardVote(_voteOption, _proposalId, signer);
    }

    function _isValidHash(uint256 _voteOption, bytes32 _proposalId, uint256 _nonce, bytes32 _signedHash) private pure returns (bool) {
        bytes32 signedMessage = keccak256(abi.encodePacked(_voteOption, _proposalId, _nonce)); //encoded message to use in ethers.getSIgn
        bytes32 ethSignedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", signedMessage));
        if (ethSignedMessage == _signedHash){
            return true;
        }
        return false;
    }

    function _forwardVote(uint256 _voteOption, uint256 _proposalId, address _signer) private {
        (bool success, ) = proposals[_proposalId].call(abi.encodeWithSignature("Vote(uint256,address)", _voteOption, _signer));//how to input params here
        require(success, "unexpected error during call");
    }
}