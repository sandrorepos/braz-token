async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with account:", deployer.address);

  const BrazToken = await ethers.getContractFactory("BrazToken");
  const token = await BrazToken.deploy(
    1000000000,
    "Braz BRL",
    "BRLB",
    2
  );

  console.log("Token address:", await token.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
});
