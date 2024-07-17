// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IRewardsController {
    function tierOf(uint256 tokenId) external view returns (uint8);
}
