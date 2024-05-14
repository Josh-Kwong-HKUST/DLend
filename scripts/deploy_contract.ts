import {ethers} from "hardhat";
import * as dotenv from "dotenv";
dotenv.config();

async function main() {
  const Contract = await ethers.getContractFactory("LoanPlatform");
  const contract = await Contract.deploy(process.env.HKDC_ADDR!, process.env.DLT_ADDR!);
  await contract.waitForDeployment();
  console.log("Contract deployed to:", await contract.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});