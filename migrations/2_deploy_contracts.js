var IBEPToken = artifacts.require("IBEPToken");

module.exports = function(deployer) {
  deployer.deploy(IBEPToken);
};