pragma solidity ^0.6.12;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';

interface IVault {
  function initialize(
    string memory _name,
    string memory _symbol,
    IERC721 _heldToken,
    uint256 _heldTokenId,
    uint256 _vaultVersion,
    address _controller,
    address _auctionImplementation
  ) external;

  function adjustPayoutRatio(uint256 _creditPurchasePercentage) external;

  function startEmissions() external;

  function purchaseToken(
    address _caller,
    address _buyer,
    uint256 ticket,
    uint256 amount,
    uint256 _lockTime
  ) external payable;

  function purchaseMulti(
    address _caller,
    address _buyer,
    uint256[] memory tickets,
    uint256[] memory amountPerTicket,
    uint256 _lockTime
  ) external payable;

  function sellToken(address _user, uint256[] memory tickets) external;

  function createPendingOrder(
    address _targetPositionHolder,
    address _buyer,
    uint256 ticket,
    uint256 lockTime,
    uint256 executorReward
  ) external payable;

  function purchaseCredits(uint256 _amount) external payable;

  function distributeFees() external;

  function claimFindersFee() external;

  function claimPendingResidual() external;

  function claimKeeperFees() external;

  function closePool() external;

  function calculatePositionPremiums(address _caller, uint256 _finalNftVal)
    external
    returns (uint256 addition);

  function adjustTicketInfo(
    address _user,
    uint256[] memory tickets,
    uint256 _finalNftVal
  ) external returns (uint256 principal, uint256 profit);

  function getTokensLocked(address _user) external view returns (uint256);

  function getTicketsOwned(address _user, uint256 _ticket)
    external
    view
    returns (
      uint256 tokensOwnedPerTicket,
      uint256 currentBribe,
      bool ticketQueued,
      address buyer
    );

  function getCreditsAvailableForPurchase(address _user, uint256 _time)
    external
    view
    returns (uint256);

  function costToPurchaseCredits(
    address _user,
    uint256 _time,
    uint256 _amount
  ) external view returns (uint256);

  function getUserPositionInfo(address _user)
    external
    view
    returns (uint256 lockedTokens, uint256 timeUnlock);

  function getClosePoolContract() external view returns (address contractAddress);
}
