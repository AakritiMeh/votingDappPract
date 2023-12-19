const { expect } = require("chai");
const { ethers } = require("hardhat");

const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

describe("election", () => {
  let election, deployer, start, end;
  let voterName = "am";
  let voterPhno = "8299397706";
  let adminName = "admin",
    adminEmail = "abc@gmail.com",
    adminTitle = "adminTitle",
    electionTitle = "election in UP",
    organizationTitle = "organisation",
    candidateId = 0;
  beforeEach(async () => {
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    voterAddr = accounts[1];

    const Election = await ethers.getContractFactory("Election");
    election = await Election.deploy();
  });

  describe("constructor", function () {
    it("checks start of election", async () => {
      let start = await election.getStart();
      expect(start).to.equal(false);
    });

    it("checks end of election", async () => {
      let end = await election.getEnd();
      expect(end).to.equal(true);
    });

    it("check voter count at the start", async () => {
      let voters = await election.getTotalVoters();
      expect(voters).to.equal(0);
    });

    it("check candidate count at the start", async () => {
      let candidates = await election.getTotalCandidates();
      expect(candidates).to.equal(0);
    });
  });

  describe("candidate functions", () => {
    it("should add candidate and update mapping", async () => {
      await election.addCandidate("header", "slogan");

      const isVerified = await election.checkCandidateVerificationStatus(0);
      expect(isVerified).to.be.true;

      const candidateCount = await election.getTotalCandidates();
      expect(candidateCount).to.equal(1);

      const votes = await election.checkVotesForCandidate(0);
      expect(votes).to.equal(0);
    });
  });

  describe("voter functions", () => {
    it("should add voter and verify it and update mapping", async () => {
      await election.registerVoter(voterName, voterPhno);
      let y = await election.returnVoterAddress(0);
      await election.verifyVoter(true, y);
      let x = await election.returnVerificationStatusOfVoter(0);
      expect(x).to.be.true;
      let countVoter = await election.getTotalVoters();
      expect(countVoter).to.equal(1);
    });
  });

  describe("election details", () => {
    it("should set election details", async () => {
      await election.setElectionDetails(
        adminName,
        adminEmail,
        adminTitle,
        electionTitle,
        organizationTitle
      );

      let a = await election.getElectionDetails();
      expect(a[0]).to.equal("admin");
      expect(a[1]).to.equal("abc@gmail.com");
      expect(a[2]).to.equal("adminTitle");
      expect(a[3]).to.equal("election in UP");
      expect(a[4]).to.equal("organisation");
    });
  });

  describe("voting functionality", () => {
    it("checks voteing mechanism", async () => {
      await election.registerVoter(voterName, voterPhno);
      let y = await election.returnVoterAddress(0);
      await election.verifyVoter(true, y);
      await election.setElectionDetails(
        adminName,
        adminEmail,
        adminTitle,
        electionTitle,
        organizationTitle
      );
      let x = await election.returnVoterDetails(0);
      let a = await expect(x[3] && x[4]).to.be.true;
      let b = await expect(x[5]).to.be.false;
      let c = await election.getStart();
      let d = await election.getEnd();
      expect(c).to.be.true;
      expect(d).to.be.false;

      await election.vote(candidateId);
      expect(await election.checkVotesForCandidate(candidateId)).to.equal(1);
      expect(await election.returnHasVoted(0)).to.be.true;
    });
  });
});
