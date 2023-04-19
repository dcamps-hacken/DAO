module.exports = async ({ getNamedAccounts, deployments }) => {
  const manager = await deployments.fixture[["DaoManager"]];

  await manager.voteOnProposal(uint256 _proposalId, bytes32 _signedHash, bytes32 r, bytes32 s, uint8 v, _nonce, {
    from: deployer,
    args: [manager.address],
    log: true,
  });
};
