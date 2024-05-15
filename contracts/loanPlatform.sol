// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Date struct for loan due date
struct Date{
    uint8 day;
    uint8 month;
    uint16 year;
}
struct Loan{
    uint amount;
    address from;
    address to;
    Date dueDate;
    bool isPaid;
}

contract LoanPlatform {
    IERC20 private hkdcToken;   // assume we already have a stable coin HKDC, 1 HKDC = 1 HKD
    IERC20 private dltToken;   // DLT for rewarding users
    mapping(address =>mapping(address => Loan)) pendingLoanRequests;   // loan request to a specific address
    mapping(address =>mapping(address => Loan)) settledLoans;   // loans that offered and accepted
    mapping(address => Loan[]) pastLoans;  // list of all past loans for a borrower
    address[] private lenders;  // list of all lenders for easier looping, internal use only
    address[] private borrowers;  // list of all borrowers for easier looping, internal use only

    event LoanRequestAccepted(address borrower, address lender, uint amount, uint8 day, uint8 month, uint16 year);   // emitted when a loan request is accepted
    event LoanRequestRejected(address borrower, address lender, uint amount, uint8 day, uint8 month, uint16 year);  // emitted when a loan request is rejected
    event NewLoanRequest(address borrower, address lender, uint amount, uint8 day, uint8 month, uint16 year); // emitted when a new loan request is created
    event LoanPaid(address borrower, address lender, uint amount, uint8 day, uint8 month, uint16 year); // emitted when a loan is paid
    event LoanDue(address borrower, address lender, uint amount, uint8 day, uint8 month, uint16 year); // emitted when a loan is due

    constructor(address hkdc, address dlt){
        hkdcToken = IERC20(hkdc);
        dltToken = IERC20(dlt);
    }

    // method for borrower to request a loan
    function requestLoan(uint amount, address lender, uint8 day, uint8 month, uint16 year) external onlyBorrower(){
        if(!isRegisteredLender(lender))   revert("The lender is not registered!");
        if(hkdcToken.balanceOf(lender) < amount) revert("You are requesting more than the lender has!");
        pendingLoanRequests[msg.sender][lender] = Loan(amount, lender, msg.sender, Date(day, month, year), false);
        emit NewLoanRequest(msg.sender, lender, amount, day, month, year);
    }

    // method for lender to offer a loan
    function offerLoan(address borrower) external onlyLender(){
        if(pendingLoanRequests[borrower][msg.sender].amount <= 0)   revert("You have no pending loan request from this borrower!");
        if(!hkdcToken.transferFrom(msg.sender, borrower, pendingLoanRequests[borrower][msg.sender].amount))   revert("Failed to offer a loan. Please check if you have enough balance");
        if(!dltToken.transfer(borrower, pendingLoanRequests[borrower][msg.sender].amount / 10))   revert("Failed to reward the borrower.");
        settledLoans[borrower][msg.sender].amount = pendingLoanRequests[borrower][msg.sender].amount;
        settledLoans[borrower][msg.sender].from = pendingLoanRequests[borrower][msg.sender].from;
        settledLoans[borrower][msg.sender].to = pendingLoanRequests[borrower][msg.sender].to;
        settledLoans[borrower][msg.sender].dueDate = pendingLoanRequests[borrower][msg.sender].dueDate;
        settledLoans[borrower][msg.sender].isPaid = false;
        pendingLoanRequests[borrower][msg.sender].amount = 0;
        emit LoanRequestAccepted(borrower,
                                 msg.sender,
                                 settledLoans[borrower][msg.sender].amount,
                                 settledLoans[borrower][msg.sender].dueDate.day,
                                 settledLoans[borrower][msg.sender].dueDate.month,
                                 settledLoans[borrower][msg.sender].dueDate.year);
    }

    // method for lender to reject a loan request
    function rejectLoan(address borrower) external onlyLender(){
        if(pendingLoanRequests[borrower][msg.sender].amount <= 0)   revert("You have no pending loan request from this borrower!");
        emit LoanRequestRejected(borrower,
                                 pendingLoanRequests[borrower][msg.sender].from,
                                 pendingLoanRequests[borrower][msg.sender].amount,
                                 pendingLoanRequests[borrower][msg.sender].dueDate.day,
                                 pendingLoanRequests[borrower][msg.sender].dueDate.month,
                                 pendingLoanRequests[borrower][msg.sender].dueDate.year);
        pendingLoanRequests[borrower][msg.sender].amount = 0;
        delete pendingLoanRequests[borrower][msg.sender];
    }

    // call to check one specific pending loan
    function getSpecificPendingLoan(address borrower, address lender) public view returns(string memory){
        string memory result = "";
        result = string.concat(result, Strings.toString(pendingLoanRequests[borrower][lender].amount));
        result = string.concat(result, ",");
        result = string.concat(result, Strings.toString(pendingLoanRequests[borrower][lender].dueDate.day));
        result = string.concat(result, ",");
        result = string.concat(result, Strings.toString(pendingLoanRequests[borrower][lender].dueDate.month));
        result = string.concat(result, ",");
        result = string.concat(result, Strings.toString(pendingLoanRequests[borrower][lender].dueDate.year));
        return result;
    }

    // call to check one specific settled loan
    function getSpecificSettledLoan(address borrower, address lender) public view returns(string memory){
        string memory result = "";
        result = string.concat(result, Strings.toString(settledLoans[borrower][lender].amount));
        result = string.concat(result, ",");
        result = string.concat(result, Strings.toString(settledLoans[borrower][lender].dueDate.day));
        result = string.concat(result, ",");
        result = string.concat(result, Strings.toString(settledLoans[borrower][lender].dueDate.month));
        result = string.concat(result, ",");
        result = string.concat(result, Strings.toString(settledLoans[borrower][lender].dueDate.year));
        result = string.concat(result, ",");
        result = string.concat(result, settledLoans[borrower][lender].isPaid ? "true" : "false");
        return result;
    }

    // call to check all pending loans of a borrower
    function getAllPendingLoansOfBorrower(address borrower) public view returns(string memory){
        string memory result = "";
        for(uint i = 0; i < lenders.length; i++){
            if(pendingLoanRequests[borrower][lenders[i]].amount > 0){
                result = string.concat(result, toString(pendingLoanRequests[borrower][lenders[i]].from));
                result = string.concat(result, ",");
                result = string.concat(result, Strings.toString(pendingLoanRequests[borrower][lenders[i]].amount));
                result = string.concat(result, ";");
            }
        }
        return result;
    }

    // call to check all settled loans of a borrower
    function getAllSettledLoansOfBorrower(address borrower) public view returns(string memory){
        string memory result = "";
        for(uint i = 0; i < lenders.length; i++){
            if(settledLoans[borrower][lenders[i]].amount > 0){
                result = string.concat(result, toString(settledLoans[borrower][lenders[i]].from));
                result = string.concat(result, ",");
                result = string.concat(result, Strings.toString(settledLoans[borrower][lenders[i]].amount));
                result = string.concat(result, ",");
                result = string.concat(result, Strings.toString(settledLoans[borrower][lenders[i]].dueDate.day));
                result = string.concat(result, ",");
                result = string.concat(result, Strings.toString(settledLoans[borrower][lenders[i]].dueDate.month));
                result = string.concat(result, ",");
                result = string.concat(result, Strings.toString(settledLoans[borrower][lenders[i]].dueDate.year));
                result = string.concat(result, ",");
                result = string.concat(result, settledLoans[borrower][lenders[i]].isPaid ? "true" : "false");
                result = string.concat(result, ";");
            }
        }
        return result;
    }

    // method for borrower to repay a loan
    function repayLoan(address lender) external onlyBorrower(){
        if(settledLoans[msg.sender][lender].amount <= 0)   revert("You have no loan with this lender!");
        if(!hkdcToken.transferFrom(msg.sender, lender, settledLoans[msg.sender][lender].amount))   revert("Failed to pay the loan. Please check if you have enough balance");
        if(!dltToken.transfer(lender, settledLoans[msg.sender][lender].amount * 9 / 10))   revert("Failed to reward the lender.");
        settledLoans[msg.sender][lender].isPaid = true;
        pastLoans[msg.sender].push(Loan(settledLoans[msg.sender][lender].amount,
                                        settledLoans[msg.sender][lender].from,
                                        settledLoans[msg.sender][lender].to,
                                        settledLoans[msg.sender][lender].dueDate,
                                        true));
        emit LoanPaid(msg.sender,
                lender,
                settledLoans[msg.sender][lender].amount,
                settledLoans[msg.sender][lender].dueDate.day,
                settledLoans[msg.sender][lender].dueDate.month,
                settledLoans[msg.sender][lender].dueDate.year);
        delete settledLoans[msg.sender][lender];
    }

    // cancel pending loan request by borrower
    function cancelLoanRequest(address lender) external onlyBorrower(){
        if(pendingLoanRequests[msg.sender][lender].amount <= 0)   revert("You have no pending loan request with this lender!");
        pendingLoanRequests[msg.sender][lender].amount = 0;
        delete pendingLoanRequests[msg.sender][lender];
    }

    // update due loans once a day, called by a cron job
    function updateDueLoans(uint8 day, uint8 month, uint16 year) external{
        for(uint i = 0; i < borrowers.length; i++){
            for (uint j = 0; j < lenders.length; j++){
                if(settledLoans[borrowers[i]][lenders[j]].amount > 0){
                    if(settledLoans[borrowers[i]][lenders[j]].dueDate.year > year)    continue;
                    if(settledLoans[borrowers[i]][lenders[j]].dueDate.month > month)    continue;
                    if(settledLoans[borrowers[i]][lenders[j]].dueDate.year < year
                    || settledLoans[borrowers[i]][lenders[j]].dueDate.month < month
                    || settledLoans[borrowers[i]][lenders[j]].dueDate.day < day){
                        pastLoans[borrowers[i]].push(settledLoans[borrowers[i]][lenders[j]]);   // isPaid = false here
                        emit LoanDue(borrowers[i],
                                     lenders[j],
                                     settledLoans[borrowers[i]][lenders[j]].amount,
                                     settledLoans[borrowers[i]][lenders[j]].dueDate.day,
                                     settledLoans[borrowers[i]][lenders[j]].dueDate.month,
                                     settledLoans[borrowers[i]][lenders[j]].dueDate.year);
                        delete settledLoans[borrowers[i]][lenders[j]];
                    }
                }
            }
        }
    }

    // method to register as a lender
    function registerAsLender() external{
        if(isRegisteredLender(msg.sender))   revert("You are already a registered lender!");
        lenders.push(msg.sender);
    }

    // method to register as a borrower
    function registerAsBorrower() external{
        if(isRegisteredBorrower(msg.sender))   revert("You are already a registered borrower!");
        borrowers.push(msg.sender);
    }

    // together with lenders list, this function is for internal use only
    function isRegisteredLender(address lender) internal view returns(bool){
        for(uint i = 0; i < lenders.length; i++){
            if(lenders[i] == lender)    return true;
        }
        return false;
    }

    // together with borrower list, this function is for internal use only
    function isRegisteredBorrower(address borrower) internal view returns(bool){
        for(uint i = 0; i < borrowers.length; i++){
            if(borrowers[i] == borrower)    return true;
        }
        return false;
    }

    // helper function to convert address to string
    function toString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
         
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
         
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
         
        return string(str);
    }

    modifier onlyLender(){
        require(isRegisteredLender(msg.sender), "You are not a registered lender!");
        _;
    }

    modifier onlyBorrower(){
        require(isRegisteredBorrower(msg.sender), "You are not a registered borrower!");
        _;
    }
}
