module.exports = async () => {
  const { deploy } = deployments;
  let deployer;
  [deployer] = await ethers.getSigners();
  await deploy("DAOmanager", {
    from: deployer.address,
    log: true,
    args: [],
  });
};
module.exports.tags = ["DAOmanager", "All"];
