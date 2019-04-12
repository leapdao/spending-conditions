# Spending Conditions

### Spending conditions library
This repository contains bleeding-edge code showcasing examples of *spending conditions* - special variety of smart contracts intended to be deployed to second layer (i.e. Plasma) as opposed to main Ethereum blockchain. Simply put, spending conditions are rules governing token transfers performed by distributed applications running on LeapDAO variant of Plasma.

If you are a dApp developer, feel free to reuse **example conditions** which are provided as solidity files ending with `Condition.sol` located within `contracts` folder. See our [wiki]() for documentation of provided examples. You can look at our [docs](https://github.com/leapdao/leapdao-docs) and [whitepaper](https://docs.google.com/document/d/1vStTjqvqZGyiI5AVtpwCIMlHFnzC_4bbixsCfs27-M8/edit) for more information as to how spending conditions differ from traditional smart contracts.


### Compile and Deploy
In order to  compile the conditions so that they are ready for deployment run `truffle compile` inside root directory of the repository.

Inside of `tools` folder resides helpful  `node.js` script allowing one to easily deploy an example `HashLockCondition.sol` to  a blockchain of choice. We have produced a short [tutorial](https://docs.leapdao.org/spending-conditions/) and [video](https://www.youtube.com/watch?time_continue=2&v=cB5T0buF8GI) showing step-by-step process of  using said tool to deploy a spending conditon to public testnet of LeapDAO blockchain.

If you decide to write your own spending condition that might be of use to other LeapDAO dApp developers or find yourself needing some guidance when writing one you are welcome to open a new issue or pull request inside this repository.


### Research and Contribute

As detailed in the [ethresear.ch](https://ethresear.ch/t/why-smart-contracts-are-not-feasible-on-plasma/2598) tread being able to handle internal state vastly complicates what is known as exit game i.e. being able to move funds/tokens out of Plasma back to Ethereum network in case of malicious activity occurring on Plasma. This is the main reason why current iteration of spending conditions does not allow one to modify internal state of the contract.

As detailed in collaboration [ document](https://docs.google.com/document/d/1uI-NK57cByG8ALH6ZM0ogXocBrw9se1yatXskqy62mU) we are currently exploring the assumption that encapsulating state inside non-fungible-tokens can allow one to create state-full spending conditions capable of efficient exit game.

#### Contributions
If you have an idea or code for spending condition that is not covered by our [examples](wiki) and that you would like to share feel free to open a new issue or pull request.

Likewise, if you would like to discuss our approach to handling internal-state inside a spending condition feel free to join our [slack](). 
