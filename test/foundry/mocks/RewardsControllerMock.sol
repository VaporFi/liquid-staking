// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

contract RewardsControllerMock {
    function tierOf(uint256 _tokenId) external view returns (uint8) {
        if (_tokenId == 1) {
            return 0;
        } else if (_tokenId == 2) {
            return 1;
        } else if (_tokenId == 3) {
            return 2;
        } else if (_tokenId == 4) {
            return 3;
        } else if (_tokenId == 5) {
            return 4;
        } else if (_tokenId == 6) {
            return 5;
        } else {
            return 0;
        }
    }
}
