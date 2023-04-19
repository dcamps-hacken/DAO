module.exports = async () => {
  const { deploy } = deployments;
  let deployer;
  [deployer] = await ethers.getSigners();
  const manager = await ethers.getContract("DAOmanager");
  const proposal = await ethers.getContract("DAOproposal");

  //flow:
  // 1- add the proposal
  // 2- add the signer
  // 3- create the TX

  //1
  const initAddress = await manager.proposals[proposal.address];
  await manager.addProposal(0, proposal.address);
  const newAddress = await manager.proposals[proposal.address];
};
