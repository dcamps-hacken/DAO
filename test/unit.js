const { assert } = require("chai");
let deployer, voter;
describe("unit testing", function () {
  beforeEach(async function () {
    await deployments.fixture(["All"]);
    [deployer, voter] = await ethers.getSigners();
    manager = await ethers.getContract("DAOmanager");
    proposal = await ethers.getContract("DAOproposal");
  });

  describe("addProposal", function () {
    it("Adds a new proposal address", async function () {
      await manager.addProposal("0", proposal.address);
      const addedAddress = await manager.getProposal("0");
      assert.equal(addedAddress, proposal.address);
    });
  });

  describe("addSigner", function () {
    it("Adds a valid signer", async function () {
      await manager.addSigner(voter.address);
      const added = await manager.isValidSigner(voter.address);
      assert.equal(added, true); //@audit don't use equal for this
    });
  });

  describe("voteOnProposal", function () {
    it("Checks that the hash is valid", async function () {});
    it("Checks that the sender is the same address calling the function", async function () {});
    it("Checks that the sender is valid", async function () {});
    it("Forwards the vote", async function () {});
  });
});
