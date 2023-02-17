import {DeployFunction} from 'hardhat-deploy/types';
import {HardhatRuntimeEnvironment} from 'hardhat/types';

import {checkPermission, getContractAddress} from '../helpers';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  console.log('\nVerifying managing DAO deployment.');

  const {getNamedAccounts, ethers} = hre;
  const {deployer} = await getNamedAccounts();

  // Get `managingDAO` address.
  const managingDAOAddress = await getContractAddress('DAO', hre);
  // Get `DAO` contract.
  const managingDaoContract = await ethers.getContractAt(
    'DAO',
    managingDAOAddress
  );

  // Check that deployer has root permission.
  await checkPermission({
    isGrant: true,
    permissionManager: managingDaoContract,
    where: managingDAOAddress,
    who: deployer,
    permission: 'ROOT_PERMISSION',
  });

  // check that the DAO have all permissions set correctly
  const permissions = [
    'ROOT_PERMISSION',
    'UPGRADE_DAO_PERMISSION',
    'SET_SIGNATURE_VALIDATOR_PERMISSION',
    'SET_TRUSTED_FORWARDER_PERMISSION',
    'SET_METADATA_PERMISSION',
    'REGISTER_STANDARD_CALLBACK_PERMISSION',
  ];

  for (let index = 0; index < permissions.length; index++) {
    const permission = permissions[index];

    await checkPermission({
      isGrant: true,
      permissionManager: managingDaoContract,
      where: managingDAOAddress,
      who: managingDAOAddress,
      permission: permission,
    });
  }

  console.log('Managing DAO deployment verified');
};
export default func;
func.tags = ['ManagingDao'];
