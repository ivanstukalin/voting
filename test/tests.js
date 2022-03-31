const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting", function () {
  let owner
  let firstCandidate
  let secondCandidate
  let thirdCandidate
  let firstVoter
  let secondVoter
  let voting

  beforeEach(async function() {
    [firstCandidate, secondCandidate, thirdCandidate, firstVoter, secondVoter] = await ethers.getSigners()
    const Voting = await ethers.getContractFactory("Voting", owner)
    voting = await Voting.deploy([firstCandidate.address, secondCandidate.address])
    await voting.deployed()
  })

  it("should be deployed", async function() {
    expect(voting.address).to.be.properAddress
  })

  it("candidat should be added", async function() {
    await voting.addCandidate(thirdCandidate.address)
    let existCandidates = await voting.getAllCandidates()
    expect(existCandidates.length).to.equal(3)
  })

  it("vote should be registered", async function(){
    await voting.vote(firstCandidate.address, {value: 10000000000000000n})
    let voteCount = await voting.getCandidateVotes(firstCandidate.address);
    expect(voteCount).to.equal(1)
  })

  it("winner should be correct", async function() {
    await voting.connect(firstVoter).vote(secondCandidate.address, {value: 10000000000000000n})
    await voting.connect(secondVoter).vote(secondCandidate.address, {value: 10000000000000000n})
    await voting.vote(secondCandidate.address, {value: 10000000000000000n})
    let winner = await voting.getCurrentlyWinner();
    expect(winner).to.equal(secondCandidate.address)
  })

  it("winner's balance should be correct after finish", async function() {
    await voting.vote(firstCandidate.address, {value: 10000000000000000n})
    const tx = await voting.finishVoting()
    await expect(() => tx)
      .to.changeEtherBalances([firstCandidate], [9000000000000000n]);
  })

  it("Amount of voter's payment should be correct", async function() {
    const tx = await voting.connect(firstVoter).vote(secondCandidate.address, {value: 10000000000000000n})
    await expect(() => tx)
      .to.changeEtherBalances([firstVoter], [-10000000000000000n]);
  })
});