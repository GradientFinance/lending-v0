import { task } from 'hardhat/config';
import { waitForTx } from '../../helpers/misc-utils';
import {
  getAToken,
  getInterestRateStrategy,
  getLendingPoolAddressesProvider,
  getStableDebtToken,
  getVariableDebtToken,
} from '../../helpers/contracts-getters';
import { getTreasuryAddress } from '../../helpers/configuration';
import AaveConfig from '../../markets/aave';
import { ZERO_ADDRESS } from '../../helpers/constants';
import { ethers } from 'ethers';
import { tEthereumAddress } from '../../helpers/types';
import { deployNFTRegistry } from '../../helpers/contracts-deployments';

const { utils } = ethers;

export const getATokenExtraParams = async (aTokenName: string, tokenAddress: tEthereumAddress) => {
  console.log(aTokenName);
  switch (aTokenName) {
    default:
      return '0x10';
  }
};

task('dev:deploy-nft-system', 'Deploy the NFT system for dev enviroment')
  .addFlag('verify', 'Verify contracts at Etherscan')
  .setAction(async ({ verify, pool }, localBRE) => {
    await localBRE.run('set-DRE');

    const addressesProvider = await getLendingPoolAddressesProvider();

    const NFTRegistry = await deployNFTRegistry(verify);
    await waitForTx(await addressesProvider.setNFTRegistry(NFTRegistry.address));

    await waitForTx(
      await addressesProvider.setAddress(
        utils.formatBytes32String('NFT_ATOKEN_IMPL'),
        (
          await getAToken()
        ).address
      )
    );

    await waitForTx(
      await addressesProvider.setAddress(
        utils.formatBytes32String('NFT_STABLE_DEBT_TOKEN_IMPL'),
        (
          await getStableDebtToken()
        ).address
      )
    );

    await waitForTx(
      await addressesProvider.setAddress(
        utils.formatBytes32String('NFT_VARIABLE_DEBT_TOKEN_IMPL'),
        (
          await getVariableDebtToken()
        ).address
      )
    );

    await waitForTx(
      await addressesProvider.setAddress(
        utils.formatBytes32String('NFT_INTEREST_RATE_STRATEGY'),
        (
          await getInterestRateStrategy()
        ).address
      )
    );

    await waitForTx(
      await addressesProvider.setAddress(
        utils.formatBytes32String('NFT_TREASURY'),
        await getTreasuryAddress(AaveConfig)
      )
    );

    const incentivesControllerAddress = '0x0000000000000000000000000000000000000000';
    await waitForTx(
      await addressesProvider.setAddress(
        utils.formatBytes32String('NFT_INCENTIVES_CONTROLLER'),
        incentivesControllerAddress
      )
    );
  });
