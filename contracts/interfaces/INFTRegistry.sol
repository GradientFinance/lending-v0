// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {ILendingPoolAddressesProvider} from './ILendingPoolAddressesProvider.sol';

/**
 * @title NFTRegistry contract
 * @author Gradient
 * @dev Implements the underlying logic for the NFTs registed in the system
 **/
interface INFTRegistry {
  struct NFT {
    address gradientAddress;
    address contractAddress;
    uint256 tokenId;
    bool inGradient;
  }

  function register(address NFTAddress, uint256 tokenId) external returns (address);

  function isAddressNFT(address addr) external view returns (bool);

  function isNFTRegistered(address tokenAddress, uint256 tokenId) external view returns (bool);

  function getNFT(address addr) external view returns (NFT memory);

  function getGradientAddress(address tokenAddress, uint256 tokenId)
    external
    view
    returns (address);

  function getContractAddress(address addr) external view returns (address);

  function getTokenId(address addr) external view returns (uint256);

  function isInGradient(address addr) external view returns (bool);

  function getAddressPrice(address addr) external returns (uint256);

  function getNFTPrice(NFT memory nft) external returns (uint256);
}
