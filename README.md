# MultiSigWallet Smart Contract

This is a Solidity smart contract for a multi-signature wallet. It allows multiple owners to jointly manage and control the funds held within the wallet. The contract includes features such as submitting transactions, approving transactions, executing transactions, revoking approvals, adding/removing participants, and adding/removing owners.

## Prerequisites

- Solidity compiler version >=0.8.0 <0.9.0

## Contract Details

### Structs

#### Transaction
- `to`: The address of the recipient.
- `value`: The amount of ether to send in the transaction.
- `data`: Additional data to include in the transaction.
- `executed`: Boolean flag indicating whether the transaction has been executed.

#### Participant
- `who`: The address of the participant.
- `votes`: The number of votes the participant has.

### Events

- `Deposit`: Triggered when ether is deposited into the contract.
- `Submin`: Triggered when a transaction is submitted.
- `Approve`: Triggered when a transaction is approved by an owner.
- `Revoke`: Triggered when an owner revokes their approval for a transaction.
- `Execute`: Triggered when a transaction is executed.

### State Variables

- `owners`: An array of addresses representing the owners of the wallet.
- `isOwner`: Mapping to track if an address is an owner.
- `isParticipant`: Mapping to track if an address is a participant.
- `participants`: Mapping to store participant details.
- `voted`: Mapping to track if an owner has voted for a participant.
- `required`: The minimum number of approvals required to execute a transaction.
- `transactions`: An array of `Transaction` structs representing the submitted transactions.
- `participantsArray`: An array of addresses representing the participants.
- `approved`: Mapping to track if an owner has approved a transaction.

### Modifiers

- `onlyOwner`: Ensures that the function is called only by an owner.
- `txExists`: Ensures that the transaction ID is valid.
- `notApproved`: Ensures that the owner has not already approved the transaction.
- `notExecuted`: Ensures that the transaction has not been executed.

### Constructor

- `constructor`: Initializes the contract with the initial owners and required approvals.

### Payable Function

- `receive`: Allows the contract to receive ether. Emits a `Deposit` event.

### External Functions

- `submit`: Submits a new transaction to the contract.
- `approve`: Approves a transaction by an owner.
- `_getApprovalCount`: Internal function to count the number of approvals for a transaction.
- `execute`: Executes a transaction if the required approvals are met.
- `revoke`: Revokes the approval for a transaction by an owner.
- `addParticipant`: Adds a new participant to the contract.
- `addOwner`: Adds a new owner to the contract.
- `voteForParticipant`: Votes for a participant by an owner.
- `getAllOwners`: Retrieves all owners of the contract.
- `getAllproposedTransactions`: Retrieves all proposed transactions.
- `removeOwner`: Removes an owner from the contract.

## Usage

1. Deploy the smart contract to the Ethereum network using a Solidity compiler compatible with the specified version range.
2. Initialize the contract by providing an array of initial owners and the required number of approvals.
3. Owners can deposit ether into the contract by sending it directly to the contract address.
4. Owners can submit transactions by calling the `submit` function with the recipient address, value, and data.
5. Other owners can approve the submitted transactions by calling the `approve` function with the transaction ID.
6. Once the required number of approvals is reached for

 a transaction, any owner can call the `execute` function to execute the transaction.
7. If an owner wants to revoke their approval for a transaction, they can call the `revoke` function.
8. Owners can add new participants using the `addParticipant` function.
9. Owners can add new owners using the `addOwner` function.
10. Owners can vote for a participant using the `voteForParticipant` function.
11. The `getAllOwners` function can be used to retrieve all the owners of the contract.
12. The `getAllproposedTransactions` function can be used to retrieve all the proposed transactions.
13. If an owner needs to be removed from the contract, the `removeOwner` function can be called.

Note: It is important to test and verify the contract's functionality and security before deploying it to a production environment.

**Disclaimer: This readme file is for informational purposes only and does not constitute legal or financial advice. Use the provided smart contract at your own risk.**
