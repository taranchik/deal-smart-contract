const Migrations = artifacts.require("Migrations");
const Deal = artifacts.require("Deal");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(Migrations);
  deployer.deploy(
    Deal,
    [accounts[0], accounts[1], accounts[2]],
    {
      from: accounts[0],
    }
  );
};
