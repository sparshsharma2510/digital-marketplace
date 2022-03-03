## How to interact with the dapp:
1. Install metamask chrome extension and make sure the setting to show test network is enabled
2. In the terminal run ```npm i``` to install all the dependencies
3. Next, run the hardhat command: ```npx hardhat node``` to get a local blockchain node
4. Once the localnode is setup, we can go ahead and deploy the contract locally using ```npx hardhat run scripts/deploy.js --network localhost```
5. At the end, to start the frontend, run ```npm run dev```
#### NOTE: Please setup your .env file before running the commands.

This project has a fully commented smart contract for the funtions used so as beginners are able to understand the functions/features provided by OpenZepplin in their ERC721 contract.
