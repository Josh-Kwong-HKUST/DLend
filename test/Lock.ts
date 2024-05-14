import { ethers } from "hardhat";
import * as dotenv from "dotenv";
dotenv.config();

var contractAbi = [
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

const mint = async () => {
  let abi = ["function mintToken(uint amount)"]
  const provider = new ethers.JsonRpcProvider(process.env.RPC!);
  const wallet = new ethers.Wallet('e320290b7412b982870bdf14b06e5d218b0adadbf0b8c7f28bef76dcbee7ae86', provider);
  const contract = new ethers.Contract(process.env.HKDC_ADDR!, abi, wallet);
  let tx = await contract.mintToken(150000);
  console.log(tx.hash);
  await tx.wait();
  console.log("Transaction done");
};



describe("Borrow money", function () {
  it("borrow 10000 from HSBC", async () => {
    // const provider = new ethers.JsonRpcProvider(process.env.RPC!);
    // const wallet = new ethers.Wallet(process.env.individual1_PK!, provider);
    // const contract = new ethers.Contract(process.env.CONTRACT_ADDR!, contractAbi, wallet);
    // await contract.waitForDeployment();

    // let loan = await contract.requestLoan(10000, process.env.HSBC_ADDR, 1, 1, 2026);
    // // let loan = await contract.getAllPendingLoansOfLender(process.env.HSBC_ADDR);
    // console.log(loan);
    // let tx = await contract.isRegisteredBorrower(process.env.lender1_ADDR);
    // console.log(typeof(tx))
    await mint();
  });
})

// describe("HSBC", function () {
//   it("Check Loan", async () => {
//     const provider = new ethers.JsonRpcProvider(process.env.RPC!);
//     const wallet = new ethers.Wallet(process.env.HSBC_PK!, provider);
//     const contract = new ethers.Contract(process.env.CONTRACT_ADDR!, contractAbi, wallet);
//     await contract.waitForDeployment();
//     await contract.registerAsLender();
//     // let tx = await contract.getAllPendingLoansOfBorrower(process.env.lender1_ADDR);
//     // let tx = await contract.offerLoan(process.env.HSBC_ADDR);
//     // console.log(tx);
//   });
// })