task("startVoting")
.setAction(async function () {
    [owner, firstCandidate, secondCandidate] = await ethers.getSigners()
    const Voting = await ethers.getContractFactory("Voting", owner)
    let voting = await Voting.deploy([firstCandidate.address, secondCandidate.address])
    await voting.deployed()
  });