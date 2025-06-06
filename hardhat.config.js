require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.30",
    settings: {
      evmVersion: "prague",
      optimizer: {
        enabled: true,
        runs: 300,
      },
    },
  },
  networks: {
    holesky: {
      url: process.env.HOLESKY_RPC_URL,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
      chainId: 17000,
    }
  },
};
