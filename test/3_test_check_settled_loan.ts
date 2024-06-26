import { ethers } from "ethers";
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


describe("Test getSpecificSettledLoan", function () {
  it("Test getSpecificSettledLoan", async () => {
    const provider = new ethers.JsonRpcProvider(process.env.RPC!);
    const wallet = new ethers.Wallet(process.env.TEST_LENDER_PK!, provider);
    const contract = new ethers.Contract(process.env.CONTRACT_ADDR!, contractAbi, wallet);
    
    await contract.waitForDeployment();
    let rep = await contract.getSpecificSettledLoan(process.env.TEST_BORROWER_ADDR!, process.env.TEST_LENDER_ADDR!)
    const response = rep.split(",");
    const amount = response[0];
    const day = response[1];
    const month = response[2];
    const year = response[3];
    const isPaid = response[4];
    console.log("Amount: ", amount);
    console.log("Due date: ", day + "/" + month + "/" + year);
    console.log("Is paid: ", isPaid);
  });
})