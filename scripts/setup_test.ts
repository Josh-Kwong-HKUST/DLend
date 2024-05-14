import { ethers } from "hardhat";
import * as dotenv from "dotenv";
dotenv.config();

const mint = async () => {
    let dlt_abi = ["function mintToken(address dlend)"]
    let hkdc_abi = ["function mintToken(uint256 amount)"]
    const provider = new ethers.JsonRpcProvider(process.env.RPC!);
    const wallet = new ethers.Wallet(process.env.TEST_BORROWER_PK, provider);
    const wallet2 = new ethers.Wallet(process.env.TEST_LENDER_PK, provider);
    const contract = new ethers.Contract(process.env.DLT_ADDR!, dlt_abi, wallet);
    let tx = await contract.mintToken(process.env.CONTRACT_ADDR!);
    console.log(tx.hash);
    await tx.wait();
    const contract2 = new ethers.Contract(process.env.HKDC_ADDR!, hkdc_abi, wallet);
    let tx2 = await contract2.mintToken(1000000);
    console.log(tx2.hash);
    await tx2.wait();
    const contract3 = new ethers.Contract(process.env.HKDC_ADDR!, hkdc_abi, wallet2);
    let tx3 = await contract3.mintToken(1000000);
    console.log(tx3.hash);
    await tx3.wait();
};

mint()
  .then(() => console.log("DLend contract minted 2,000,000 DLT. Test accounts get 1000000 HKDC each."))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });