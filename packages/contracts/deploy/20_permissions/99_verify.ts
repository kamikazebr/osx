import {DeployFunction} from 'hardhat-deploy/types';
import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {checkPermission, getContractAddress} from '../helpers';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  console.log('\nVerifying permissions');

  const {ethers} = hre;

  // Get `managingDAO` address.
  const managingDAOAddress = await getContractAddress('DAO', hre);

  // Get `DAO` contract.
  const managingDaoContract = await ethers.getContractAt(
    'DAO',
    managingDAOAddress
  );

  // Get `DAORegistry` address.
  const daoRegistryAddress = await getContractAddress('DAORegistry', hre);

  // Get `PluginRepoRegistry` address.
  const pluginRepoRegistryAddress = await getContractAddress(
    'PluginRepoRegistry',
    hre
  );

  // Get DAO's `ENSSubdomainRegistrar` address.
  const daoEnsSubdomainRegistrarAddress = await getContractAddress(
    'DAO_ENSSubdomainRegistrar',
    hre
  );

  // Get Plugin's `ENSSubdomainRegistrar` address.
  const pluginEnsSubdomainRegistrarAddress = await getContractAddress(
    'Plugin_ENSSubdomainRegistrar',
    hre
  );

  // Get `DAOFactory` address.
  const daoFactoryAddress = await getContractAddress('DAOFactory', hre);

  // Get `PluginRepoFactory` address.
  const pluginRepoFactoryAddress = await getContractAddress(
    'PluginRepoFactory',
    hre
  );

  // ENS PERMISSIONS
  await checkPermission({
    isGrant: true,
    permissionManager: managingDaoContract,
    where: daoEnsSubdomainRegistrarAddress,
    who: daoRegistryAddress,
    permission: 'REGISTER_ENS_SUBDOMAIN_PERMISSION',
  });

  await checkPermission({
    isGrant: true,
    permissionManager: managingDaoContract,
    where: pluginEnsSubdomainRegistrarAddress,
    who: pluginRepoRegistryAddress,
    permission: 'REGISTER_ENS_SUBDOMAIN_PERMISSION',
  });

  // DAO REGISTRY PERMISSIONS
  await checkPermission({
    isGrant: true,
    permissionManager: managingDaoContract,
    where: daoRegistryAddress,
    who: daoFactoryAddress,
    permission: 'REGISTER_DAO_PERMISSION',
  });

  // PLUGIN REPO REGISTRY PERMISSIONS
  await checkPermission({
    isGrant: true,
    permissionManager: managingDaoContract,
    where: pluginRepoRegistryAddress,
    who: pluginRepoFactoryAddress,
    permission: 'REGISTER_PLUGIN_REPO_PERMISSION',
  });

  console.log('Permissions verified');
};
export default func;
func.tags = [
  'ENS_Permissions',
  'DAO_Registry_Permissions',
  'Plugin_Registry_Permissions',
];
