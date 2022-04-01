pragma solidity 0.6.12;

import {IERC721} from '../dependencies/openzeppelin/contracts/IERC721.sol';

/// @title IVaultFactory interface
/// @notice Interface for the Vault factory of Abacus Spot
interface IVaultFactory {
  //mapping(address => mapping(uint256 => uint256)) public nextVaultIndex;

  function addToEarlyMemberWhitelist(address _earlyAccess) external;

  function addToCollectionWhitelist(address _collection) external;

  function setAdmin(address _admin) external;

  function setController(address _controller) external;

  function createVault(
    string memory _name,
    string memory _symbol,
    IERC721 _heldToken,
    uint256 _heldTokenId
  ) external;

  function emitTokenPurchase(
    address _callerToken,
    uint256 _callerId,
    address _buyer,
    uint256 ticket,
    uint256 amount,
    uint256 _lockTime
  ) external;

  function emitTokenSale(
    address _callerToken,
    uint256 _callerId,
    address _seller,
    uint256[] memory tickets,
    uint256 desiredCredits
  ) external;

  function emitFeeRedemption(
    address _callerToken,
    uint256 _callerId,
    uint256 toTreasury,
    uint256 toVeHolders
  ) external;

  function emitPoolClosure(
    address _callerToken,
    uint256 _callerId,
    uint256 _finalVal,
    address _closePoolContract,
    address _vault
  ) external;

  function emitAuctionEnded(
    address _callerToken,
    uint256 _callerId,
    uint256 _finalVal,
    uint256 _auctionVal,
    address _closePoolContract,
    address _vault
  ) external;

  function emitAccountClosed(
    address _callerToken,
    uint256 _callerId,
    uint256 _finalVal,
    uint256 _auctionVal,
    uint256 _payoutCredits,
    uint256 _payoutEth,
    address _closePoolContract,
    address _vault
  ) external;
}
