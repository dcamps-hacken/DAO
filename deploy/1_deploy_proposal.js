module.exports = async () => {
  const { deploy } = deployments;
  let deployer;
  [deployer] = await ethers.getSigners();
  const manager = await ethers.getContract("DAOmanager");
  await deploy("DAOproposal", {
    from: deployer.address,
    args: [manager.address],
    log: true,
  });
};
module.exports.tags = ["DAOproposal"];
