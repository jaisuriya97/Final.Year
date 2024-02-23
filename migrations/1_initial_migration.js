var Migrations = artifacts.require("./contracts/TenderAllocator.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
