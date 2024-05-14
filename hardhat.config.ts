import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    }
  },
  networks: {
    etherdata: {
      url: "https://rpc1.taurus.axiomesh.io/",
      accounts: process.env.HangSeng_PK !== undefined ? [process.env.HangSeng_PK] : [],
    },
  },
};

export default config;