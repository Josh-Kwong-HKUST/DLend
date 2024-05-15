import { ethers } from "hardhat";
import * as dotenv from "dotenv";
dotenv.config();

const mint = async () => {
    let dlt_abi = ["function mintToken(address dlend)"]
    let hkdc_abi = ["function mintToken(uint256 amount)"]
    let contractAbi = [
      "function requestLoan(uint amount, address lender, uint8 day, uint8 month, uint16 year) external",
      "function offerLoan(address borrower) external",
      "function rejectLoan(address borrower) external",
      "function getSpecificPendingLoan(address borrower, address lender) public view returns(string memory)",
      "function getSpecificSettledLoan(address borrower, address lender) public view returns(string memory)",
      "function getAllPendingLoansOfBorrower(address borrower) public view returns(string memory)",
      "function getAllSettledLoansOfBorrower(address borrower) public view returns(string memory)",
      "function getAllPendingLoansOfLender(address lender) public view returns(string memory)",
      "function repayLoan(address lender) external",
      "function updateDueLoans(uint day, uint month, uint year) external",
      "function registerAsLender() external",
      "function registerAsBorrower() external",
      "function isRegisteredLender(address lender) public view returns(bool)",
      "function isRegisteredBorrower(address borrower) public view returns(bool)",
      "function getRegisteredBorrowers() public view returns(string memory)",
      "function getRegisteredLenders() public view returns(string memory)",
    ];
    const provider = new ethers.JsonRpcProvider(process.env.RPC!);
    const wallet = new ethers.Wallet(process.env.TEST_BORROWER_PK, provider);
    const wallet2 = new ethers.Wallet(process.env.TEST_LENDER_PK, provider);
    const contract = new ethers.Contract(process.env.DLT_ADDR!, dlt_abi, wallet);
    let tx = await contract.mintToken(process.env.CONTRACT_ADDR!);
    await tx.wait();
    const contract2 = new ethers.Contract(process.env.HKDC_ADDR!, hkdc_abi, wallet);
    let tx2 = await contract2.mintToken(1000000);
    await tx2.wait();
    const contract3 = new ethers.Contract(process.env.HKDC_ADDR!, hkdc_abi, wallet2);
    let tx3 = await contract3.mintToken(1000000);
    await tx3.wait();
    const contract4 = new ethers.Contract(process.env.CONTRACT_ADDR!, contractAbi, wallet);
    let tx4 = await contract4.registerAsBorrower();
    await tx4.wait();
    const contract5 = new ethers.Contract(process.env.CONTRACT_ADDR!, contractAbi, wallet2);
    let tx5 = await contract5.registerAsLender();
    await tx5.wait();
};

mint()
  .then(() => console.log("DLend contract minted 2,000,000 DLT. Test accounts get 1000000 HKDC each. Registered borrower and lender accounts."))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });