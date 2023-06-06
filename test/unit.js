const { assert, expect } = require("chai");
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
    it("Reverts when repeating ID", async function () {
      await manager.addProposal("0", proposal.address);
      await expect(manager.addProposal("0", proposal.address)).to.be.reverted;
    });
    it("Reverts when not called by owner", async function () {
      await expect(manager.connect(voter).addProposal("1", proposal.address)).to
        .be.reverted;
    });
    it("Emits corresponding event", async function () {
      //@audit why doesn't this increase code coverage?
      await expect(manager.addProposal("0", proposal.address)).to.emit(
        manager,
        "NewProposal"
      );
    });
  });

  describe("addSigner", function () {
    it("Adds a valid signer", async function () {
      await manager.addSigner(voter.address);
      const added = await manager.isValidSigner(voter.address);
      assert.equal(added, true); //@audit don't use equal for this
    });
    it("Reverts when not called by owner", async function () {
      await expect(manager.connect(voter).addSigner(voter.address)).to.be
        .reverted;
    });
    it("Emits corresponding event", async function () {
      await expect(manager.addSigner(voter.address)).to.emit(
        manager,
        "SignerAdded"
      );
    });
  });

  describe("deleteSigner", function () {
    it("Deletes signer", async function () {
      await manager.deleteSigner(voter.address);
      const added = await manager.isValidSigner(voter.address);
      assert.equal(added, false); //@audit don't use equal for this
    });
    it("Reverts when not called by owner", async function () {
      await expect(manager.connect(voter).deleteSigner(voter.address)).to.be
        .reverted;
    });
    it("Emits corresponding event", async function () {
      //@audit why doesn't this increase code coverage?
      await expect(manager.deleteSigner(voter.address)).to.emit(
        manager,
        "SignerDeleted"
      );
    });
  });
  describe("getProposal", function () {}); //@audit tests for view functions???
  describe("isValidSigner", function () {}); //@audit tests for view functions???

  describe("voteOnProposal", function () {
    it("Passes through and increases nonce", async function () {
      await manager.connect(deployer).addSigner(voter.address);
      const prevNonce = await manager.validSigners[voter].isValid;
      console.log(prevNonce);
      const _voteOption = 1;
      const _proposalId = 1;
      const _nonce = prevNonce + 1;

      const hash = web3.utils.keccak256Wrapper(
        encodePacked(_voteOption, _proposalId, _nonce)
      );
      const _signedHash = voter.signMessage(hash); //eth signed message with ethers

      await manager
        .connect(voter)
        .voteOnProposal(
          voter,
          _voteOption,
          _proposalId,
          _signedHash,
          r,
          s,
          v,
          _nonce
        );
      const newNonce = await manager.validSigners[voter].nonce;
      assert.equal(newNonce, prevNonce + 1);
    });
    it("Reverts on invalid hash", async function () {
      await expect(
        manager.connect(voter).voteOnProposal(voter.address)
      ).to.be.revertedWith("invalid hash");
    });
    it("Reverts if sender is not signer", async function () {
      await expect(
        manager.connect(voter).voteOnProposal(voter.address)
      ).to.be.revertedWith("incorrect signer");
    });
    it("Reverts if voter has no permission", async function () {
      await expect(
        manager.connect(voter).voteOnProposal(voter.address)
      ).to.be.revertedWith("voter has no permission");
    });
    it("Reverts if forward call is not successful", async function () {
      //@audit how to test this
      await expect(
        manager.connect(voter).voteOnProposal(voter.address)
      ).to.be.revertedWith("unexpected error during call");
    });
  });
});
