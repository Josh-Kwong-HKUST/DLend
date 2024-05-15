# ISOM3000H Final Project: Decentralized Lending Protocol

## Node JS Runtime
16.19.0

## Install Dependencies
```shell
yarn
```

## Environmentale variables
Copy the content of the given .env.sample to a .env file. A test borrower account and a test lender account is provided.

## Deploy Token Contracts (DLT and HKDC)
```shell
yarn deploy_dlt
yarn deploy_hkdc
```
You can see the mint address of DLT and HKDC from the terminal output. Put them in the corresponding variables in .env file.

## Deploy DLend Contract
```shell
yarn deploy # make sure you have put DLT and HKDC mint addresses in .env file correctly
```

## Before-Test Setup
```shell
yarn setup_test
```
You should see "DLend contract minted 2,000,000 DLT. Test accounts get 1000000 HKDC each. Registered borrower and lender accounts." if everything is going well.

## Run Test
```shell
yarn test
```
You can create your own test by modifying the existing test and replace the function signature used by the contract.