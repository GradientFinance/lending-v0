// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import {SafeMath} from '../../../dependencies/openzeppelin/contracts/SafeMath.sol';
import {ReserveConfiguration} from '../configuration/ReserveConfiguration.sol';
import {ILendingPoolAddressesProvider} from '../../../interfaces/ILendingPoolAddressesProvider.sol';
import {INFTRegistry} from '../../../interfaces/INFTRegistry.sol';
import {IERC20Detailed} from '../../../dependencies/openzeppelin/contracts/IERC20Detailed.sol';
import {Errors} from '../helpers/Errors.sol';
import {PercentageMath} from '../math/PercentageMath.sol';
import {DataTypes} from '../types/DataTypes.sol';
import {NFTvault} from './NFTvault.sol';
import {IVaultFactory} from '../../../interfaces/IVaultFactory.sol';
import {IVault} from '../../../interfaces/IVault.sol';

/**
 * @title NFTRegistry contract
 * @author Gradient
 * @dev Implements the underlying logic for the NFTs registed in the system
 **/
contract NFTRegistry is INFTRegistry {
  using SafeMath for uint256;
  using PercentageMath for uint256;
  using ReserveConfiguration for DataTypes.ReserveConfigurationMap;

  ILendingPoolAddressesProvider internal addressesProvider;
  IVaultFactory internal vaultFactory;
  mapping(address => NFT) private _gaddressToNFTs;
  mapping(address => mapping(uint256 => address)) private _gradientAddresses;

  function initialize(ILendingPoolAddressesProvider provider) public {
    addressesProvider = provider;
    vaultFactory = IVaultFactory(addressesProvider.getSpotVaultFactory());
  }

  function register(address NFTAddress, uint256 tokenId) external override returns (address) {
    // this is a tricky function !
    NFTvault vault = new NFTvault();
    address addr = address(vault);
    _gaddressToNFTs[addr] = NFT(addr, NFTAddress, tokenId, false);
    _gradientAddresses[NFTAddress][tokenId] = addr;
    return addr;
  }

  function getGradientAddress(address tokenAddress, uint256 tokenId)
    public
    view
    override
    returns (address)
  {
    return _gradientAddresses[tokenAddress][tokenId];
  }

  function isNFTRegistered(address tokenAddress, uint256 tokenId)
    external
    view
    override
    returns (bool)
  {
    return getGradientAddress(tokenAddress, tokenId) != address(0);
  }

  function isAddressNFT(address addr) public view override returns (bool) {
    return getTokenId(addr) != 0;
  }

  function getNFT(address addr) public view override returns (NFT memory) {
    return _gaddressToNFTs[addr];
  }

  function getContractAddress(address addr) public view override returns (address) {
    return getNFT(addr).contractAddress;
  }

  function getTokenId(address addr) public view override returns (uint256) {
    return getNFT(addr).tokenId;
  }

  function isInGradient(address addr) public view override returns (bool) {
    return getNFT(addr).inGradient;
  }

  function getAddressPrice(address addr) public override returns (uint256) {
    return getNFTPrice(getNFT(addr));
  }

  function getNFTPrice(NFT memory nft) public override returns (uint256) {
    require(isAddressNFT(nft.gradientAddress), 'The NFT is not registered.');
    address vault = getVault(nft.contractAddress, nft.tokenId);
    return vault.balance;
  }

  function openSpotPool(address token, uint256 id) internal returns (address vault) {
    return address(0);
    //return vaultFactory.nftVault[vaultFactory.nextVaultIndex[token][id] - 1][address][id];
  }

  function getVault(address token, uint256 id) internal returns (address vault) {
    return address(0);
    //return vaultFactory.nftVault[vaultFactory.nextVaultIndex[token][id] - 1][address][id];
  }

  function expiringPosition(
    address nftAddress,
    uint256 nftId,
    address user,
    uint256[] calldata tickets
  ) internal view returns (uint256 size, uint256 timeUnlock) {
    size = 0;
    address vaultAddress = IVaultFactory(nftAddress).getVaultAddress(nftAddress, nftId); // here we would need to change the IVaultFactory
    IVault vault = IVault(vaultAddress);

    (, timeUnlock) = vault.getUserPositionInfo(user);

    for (uint256 i = 0; i < tickets.length; i++) {
      bool ticketQueued;
      uint256 tokensOwnedPerTicket;
      (tokensOwnedPerTicket, , ticketQueued, ) = vault.getTicketsOwned(user, tickets[i]);

      if (!ticketQueued) {
        size += tokensOwnedPerTicket;
      }
    }
  }

  function getTotalExpiring(
    uint32 liquidationTimeDifference,
    address nftAddress,
    uint256 nftId,
    address[] calldata users,
    uint256[][] calldata tickets
  ) external view returns (uint256 total) {
    total = 0;
    for (uint256 i = 0; i < users.length; i++) {
      (uint256 size, uint256 timeUnlock) =
        expiringPosition(nftAddress, nftId, users[i], tickets[i]);
      bool liquidatable = timeUnlock - block.timestamp <= liquidationTimeDifference;

      if (liquidatable) {
        total += size;
      }
    }
  }
}
