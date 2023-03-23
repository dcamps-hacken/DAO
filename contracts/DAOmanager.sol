pragma solidity 0.8.7;

import "@openzeppelin\contracts\access\Ownable.sol";

contract DAOmanager is Ownable { 

    struct Signer {
        bool isValid;
        uint256[] votedProposals;

    mapping(address => Signer) public validSigners; //nonce tracking?
    mapping(bytes32 => bool) public executedTxs; //is this enough for the nonce or needs additional check?
    mapping(uint256 => address) proposals;

    Event NewProposal(uint256 indexed _proposalId, address indexed _proposalAddress);
    Event SignerAdded(address indexed _signer);
    Event SignerDeleted(address indexed _signer);

    function addProposal(uint256 _proposalId, address _proposalAddress) external onlyOwner {
        proposals[_proposalId] = _proposalAddress
        emit NewProposal(_proposalId, _proposalAddress)
    }

    function addSigner(address _signer) external onlyOwner{
        validSigners[_signature].isvalid = true;
        emit SignerAdded(_signer)
    }

    function deleteSigner(address _signer) external onlyOwner{
        validSigners[_signature].isvalid = false;
        emit SignerDeleted(_signer);
        //check nonce
    }

    function voteOnProposal(uint256 _proposalId, bytes32 _signedHash, bytes32 r, bytes32 s, uint8 v, nonce) external {
        //compare the hash with expected hash
        require(_validHash(_signedHash, r, s, v), "invalid hash");
        address signer = ecrecover(_ethSignedMessageHash, v, r, s);
        require(validSigners[_signer].isValid, "voter has no permission");
        require(!executedTxs[_signedHash], "Tx already executed");
        
        executedTxs[_signedHash] = true;

        _forwardVote(_proposalId);
    }

    function _validHash(bytes32 _signedHash, bytes32 r, bytes32 s, uint8 v, nonce) private returns (bool) {
        bytes32 signedMessage = keccak256(abi.encodePacked("vote()", r, s, v, nonce))
        bytes32 ethSignedMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", signedMessage));
        if (ethSignedMessage == _signedHash){
            return true;
        }
        return false;
    }

    function _forwardVote(uint256 _proposalId) private {
        uint256[] votedProposals = validSigners.votedProposals;
        uint256 numVotedProposals = votedProposals.length
        for (i, i < numVotedProposals, i++){
            if (votedProposals[i] == _proposalId){
                revert; //error message!
            }
        }
        validSigners.votedProposals.push(_proposalId);
        (bool success, ) = proposals[_proposalId].call(abi.encodeWithSignature("Vote()"));
        require(success, "unexpected error during call")
    }
}