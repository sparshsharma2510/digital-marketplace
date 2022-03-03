require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
const {ALCHEMY_API_KEY, MUMBAI_PRIVATE_KEY} = process.env;

module.exports = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`${MUMBAI_PRIVATE_KEY}`],
    },
  },
};
