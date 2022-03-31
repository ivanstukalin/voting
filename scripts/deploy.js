const fs = require('fs');

async function main() {
  const Voting = await hre.ethers.getContractFactory("Voting");
  //There are u can add some candidates for start voting or add some candidates after deploy
  const voting = await Voting.deploy([]);

  await voting.deployed();

  console.log("Voting deployed to:", voting.address);

  const config = {
    address: voting.address
  }

  fs.writeFileSync("./app/__config.json", JSON.stringify(config, null, 2));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });