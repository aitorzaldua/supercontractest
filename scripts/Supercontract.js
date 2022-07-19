const hre = require("hardhat");
async function main() {
  const SuperContract = await hre.ethers.getContractFactory("SuperContract");
  const superContract = await SuperContract.deploy();
  await superContract.deployed();

  console.log("SuperContract deployed to:", superContract.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });