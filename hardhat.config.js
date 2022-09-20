/** @type import('hardhat/config').HardhatUserConfig */
require('dotenv').config();
require('hardhat-abi-exporter');
require("@nomiclabs/hardhat-ethers");

const accounts = [process.env.PRIVATE_KEY]

module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {},
    testnetbsc: {
      url: "https://data-seed-prebsc-1-s3.binance.org:8545/",
      accounts,
      chainId: 97,
      live: true,
      saveDeployments: true,
      tags: ["staging"],
      gasMultiplier: 2,
    },
  },
  abiExporter: {
    path: "./abi",
    clear: false,
    flat: true,
    // only: [],
    // except: []
  },
  paths: {
    artifacts: "artifacts",
    cache: "cache",
    deploy: "deploy",
    deployments: "deployments",
    imports: "imports",
    sources: "contracts",
    tests: "test",
  },
 };
