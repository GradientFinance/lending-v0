import { eContractid, tEthereumAddress } from './types';
import { MockAggregator } from '../types/MockAggregator';
import { getEthersSigners, MockTokenMap } from './contracts-helpers';
import {
  getIErc721Detailed,
  getLendingPool,
  getLendingPoolAddressesProvider,
  getLendingPoolConfigurator,
  getMintableERC20,
  getMintableERC721,
  getNFTRegistry,
  getPriceOracle,
} from './contracts-getters';
import { ethers, Signer } from 'ethers';
import { string } from 'hardhat/internal/core/params/argumentTypes';
import { DRE, getDb } from './misc-utils';
import { deployMintableERC721 } from './contracts-deployments';

export const getFirstSigner = async () => (await getEthersSigners())[0];

export const getAllTokenAddresses = (mockTokens: MockTokenMap) =>
  Object.entries(mockTokens).reduce(
    (accum: { [tokenSymbol: string]: tEthereumAddress }, [tokenSymbol, tokenContract]) => ({
      ...accum,
      [tokenSymbol]: tokenContract.address,
    }),
    {}
  );
export const getAllAggregatorsAddresses = (mockAggregators: {
  [tokenSymbol: string]: MockAggregator;
}) =>
  Object.entries(mockAggregators).reduce(
    (accum: { [tokenSymbol: string]: tEthereumAddress }, [tokenSymbol, aggregator]) => ({
      ...accum,
      [tokenSymbol]: aggregator.address,
    }),
    {}
  );

export const seedEthLiquidity = async (amountInETH: string) => {
  const signer = await getFirstSigner();
  const amount = ethers.utils.parseUnits(amountInETH);

  //const WETH = await contractGetters.getMintableERC20(0xD6C850aeBFDC46D7F4c207e445cC0d6B0919BDBe)

  const lendingPool = await getLendingPool();
  const WETH = await getMintableERC20(
    (
      await getDb().get(`${eContractid.WETH}.${DRE.network.name}`).value()
    ).address
  );

  await WETH.connect(signer).mint(amount);
  await WETH.connect(signer).approve(lendingPool.address, amount);

  await lendingPool.connect(signer).deposit(WETH.address, amount, await signer.getAddress(), '0');
};

export const mintNFT = async (tokenContract: string, tokenId: string, signer: Signer) => {
  const token = await getMintableERC721(tokenContract);
  await token.connect(signer).mint(tokenId);
};

export const deployMintNFT = async (
  name: string,
  symbol: string,
  tokenId: string,
  signer: Signer
) => {
  const token = await deployMintableERC721(name, symbol);
  await mintNFT(token.address, tokenId, signer);
  return token.address;
};

export const registerNFT = async (tokenAddress: tEthereumAddress, tokenId: string) => {
  const lendingPoolConfig = await getLendingPoolConfigurator();
  await lendingPoolConfig.connect(await getFirstSigner()).initNFTReserve(tokenAddress, tokenId);
  await (await getPriceOracle()).setAssetPrice(tokenAddress, 100);

  await lendingPoolConfig.on(
    'RegisteredNFT',
    async (NFTAddress, tokenId, registerAddress, event) => {
      (await getPriceOracle()).setAssetPrice(registerAddress, 100);
      console.log(registerAddress);
    }
  );
};

export const deployMintRegisterNFT = async (
  name: string,
  symbol: string,
  tokenId: string,
  signer: Signer
) => {
  const token = await deployMintableERC721(name, symbol);
  await mintNFT(token.address, tokenId, signer);
  await registerNFT(token.address, tokenId);
};

export const depositNFT = async (tokenGradientAddress: tEthereumAddress, signer: Signer) => {
  const registry = await getNFTRegistry();
  // Approving token transfer
  const lendingPool = await getLendingPool();
  const token = await getIErc721Detailed(await registry.getAddress(tokenGradientAddress));
  await token
    .connect(signer)
    .approve(lendingPool.address, await registry.getTokenId(tokenGradientAddress));

  // Transferring token to the lending pool
  await lendingPool
    .connect(signer)
    .deposit(tokenGradientAddress, 1, await signer.getAddress(), '0');
};

export const deployMintRegisterDepositNFT = async (
  name: string,
  symbol: string,
  tokenId: string,
  signer: Signer
) => {
  const token = await deployMintableERC721(name, symbol);
  await mintNFT(token.address, tokenId, signer);
  await registerNFT(token.address, tokenId);

  const registry = await getNFTRegistry();
  await depositNFT(await registry.getGradientAddress(token.address, tokenId), signer);
};
