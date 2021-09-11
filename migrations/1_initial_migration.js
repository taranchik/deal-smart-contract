const Migrations = artifacts.require("Migrations");
const Deal = artifacts.require("Deal");

module.exports = function (deployer) {
  deployer.deploy(Deal);
  deployer.deploy(Migrations);
};
