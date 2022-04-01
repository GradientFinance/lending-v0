// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import {IERC721} from './IERC721.sol';

interface IERC721Detailed is IERC721 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);
}
