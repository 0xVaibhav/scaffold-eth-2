import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys a contract named "YourContract" using the deployer account and
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys the "HealthInsurance" contract using the deployer account.
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployHealthInsurance: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("HealthInsurance", {
    from: deployer,
    // Contract constructor arguments (none in this case)
    args: [],
    log: true,
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const healthInsurance = await hre.ethers.getContract<Contract>("HealthInsurance", deployer);
  console.log("HealthInsurance contract deployed to:", healthInsurance.address);

  // Example interaction with the deployed contract
  // Uncomment if you have specific interactions you want to perform after deployment
  // const initialSchemes = await healthInsurance.schemeCount();
  // console.log("Initial scheme count:", initialSchemes.toString());
};

export default deployHealthInsurance;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags HealthInsurance
deployHealthInsurance.tags = ["HealthInsurance"];
