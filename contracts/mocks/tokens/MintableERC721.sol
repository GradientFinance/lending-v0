// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import {ERC721} from '../../dependencies/openzeppelin/contracts/ERC721.sol';

/**
 * @title ERC721Mintable
 * @dev ERC721 minting logic
 */
contract MintableERC721 is ERC721 {
  constructor(string memory name, string memory symbol) public ERC721(name, symbol) {}

  /**
   * @dev Function to mint tokens
   * @param tokenId The ID of the token to mint
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(uint256 tokenId) public returns (bool) {
    _mint(_msgSender(), tokenId);
    return true;
  }
}
