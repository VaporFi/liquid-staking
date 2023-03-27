// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import {LDiamond} from "clouds/diamond/LDiamond.sol";
import {IDiamondLoupe} from "clouds/interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "clouds/interfaces/IDiamondCut.sol";
import {IERC173} from "clouds/interfaces/IERC173.sol";
import {IERC165} from "clouds/interfaces/IERC165.sol";
import {AppStorage} from "../libraries/AppStorage.sol";

// It is expected that this contract is customized if you want to deploy your diamond
// with data from a deployment script. Use the init function to initialize state variables
// of your diamond. Add parameters to the init funciton if you need to.

// Adding parameters to the `init` or other functions you add here can make a single deployed
// DiamondInit contract reusable accross upgrades, and can be used for multiple diamonds.

contract DiamondInit {
    AppStorage s;

    struct Args {
        uint256 depositFee;
        uint256 claimFee;
        uint256 restakeFee;
        uint256 unlockFee;
        address depositToken;
        address boostFeeToken;
        address rewardToken;
        address stratosphere;
        address xVAPE;
        address passport;
        address replenishmentPool;
        address labsMultisig;
        address burnWallet;
    }

    // You can add parameters to this function in order to pass in
    // data to set your own state variables
    function init(Args memory _args) external {
        // adding ERC165 data
        LDiamond.DiamondStorage storage ds = LDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // add your own state variables
        // EIP-2535 specifies that the `diamondCut` function takes two optional
        // arguments: address _init and bytes calldata _calldata
        // These arguments are used to execute an arbitrary function using delegatecall
        // in order to set state variables in the diamond during deployment or an upgrade
        // More info here: https://eips.ethereum.org/EIPS/eip-2535#diamond-interface

        // General
        s.stratosphereAddress = _args.stratosphere;

        // DepositFacet
        s.depositFee = _args.depositFee;
        s.depositToken = _args.depositToken;
        s.depositDiscountForStratosphereMembers[1] = 500; // 5%
        s.depositDiscountForStratosphereMembers[2] = 550; // 5.5%
        s.depositDiscountForStratosphereMembers[3] = 650; // 6.5%
        s.depositDiscountForStratosphereMembers[4] = 800; // 8%
        s.depositDiscountForStratosphereMembers[5] = 1000; // 10%
        s.depositDiscountForStratosphereMembers[6] = 1500; // 15%
        s.depositFeeReceivers.push(_args.replenishmentPool);
        s.depositFeeReceivers.push(_args.labsMultisig);
        s.depositFeeReceivers.push(_args.burnWallet);
        s.depositFeeReceiversShares.push(8500); // 85%
        s.depositFeeReceiversShares.push(1000); // 10%
        s.depositFeeReceiversShares.push(500); // 5%

        // UnlockFacet
        s.unlockFee = _args.unlockFee;
        s.unlockDiscountForStratosphereMembers[1] = 500; // 5%
        s.unlockDiscountForStratosphereMembers[2] = 550; // 5.5%
        s.unlockDiscountForStratosphereMembers[3] = 650; // 6.5%
        s.unlockDiscountForStratosphereMembers[4] = 800; // 8%
        s.unlockDiscountForStratosphereMembers[5] = 1000; // 10%
        s.unlockDiscountForStratosphereMembers[6] = 1500; // 15%
        s.unlockFeeReceivers.push(_args.replenishmentPool);
        s.unlockFeeReceivers.push(_args.labsMultisig);
        s.unlockFeeReceivers.push(_args.burnWallet);
        s.unlockFeeReceiversShares.push(8000); // 80%
        s.unlockFeeReceiversShares.push(1000); // 10%
        s.unlockFeeReceiversShares.push(1000); // 10%

        // BoostFacet
        s.boostFeeToken = _args.boostFeeToken;
        s.boostLevelToFee[0] = 0;
        /// @dev using 1e6 because USDC has 6 decimals
        s.boostLevelToFee[1] = 2 * 1e6;
        s.boostLevelToFee[2] = 3 * 1e6;
        s.boostLevelToFee[3] = 4 * 1e6;
        s.boostPercentFromTierToLevel[1][1] = 1000; // 10%
        s.boostPercentFromTierToLevel[2][1] = 1100; // 11%
        s.boostPercentFromTierToLevel[3][1] = 1200; // 12%
        s.boostPercentFromTierToLevel[4][1] = 1300; // 13%
        s.boostPercentFromTierToLevel[5][1] = 1400; // 14%
        s.boostPercentFromTierToLevel[6][1] = 1500; // 15%
        s.boostPercentFromTierToLevel[1][2] = 2000; // 20%
        s.boostPercentFromTierToLevel[2][2] = 2100; // 21%
        s.boostPercentFromTierToLevel[3][2] = 2200; // 22%
        s.boostPercentFromTierToLevel[4][2] = 2300; // 23%
        s.boostPercentFromTierToLevel[5][2] = 2400; // 24%
        s.boostPercentFromTierToLevel[6][2] = 2500; // 25%
        s.boostPercentFromTierToLevel[1][3] = 3000; // 30%
        s.boostPercentFromTierToLevel[2][3] = 3100; // 31%
        s.boostPercentFromTierToLevel[3][3] = 3200; // 32%
        s.boostPercentFromTierToLevel[4][3] = 3300; // 33%
        s.boostPercentFromTierToLevel[5][3] = 3400; // 34%
        s.boostPercentFromTierToLevel[6][3] = 3500; // 35%
        s.boostFeeReceivers.push(_args.labsMultisig);
        s.boostFeeReceivers.push(_args.xVAPE);
        s.boostFeeReceivers.push(_args.passport);
        s.boostFeeReceiversShares.push(5000); // 50%
        s.boostFeeReceiversShares.push(4000); // 40%
        s.boostFeeReceiversShares.push(1000); // 10%

        // ClaimFacet
        s.claimFee = _args.claimFee;
        s.claimFeeReceivers.push(_args.labsMultisig);
        s.claimFeeReceivers.push(_args.xVAPE);
        s.claimFeeReceivers.push(_args.passport);
        s.claimFeeReceiversShares.push(5000); // 50%
        s.claimFeeReceiversShares.push(4000); // 40%
        s.claimFeeReceiversShares.push(1000); // 10%

        // RestakeFacet
        s.restakeFee = _args.restakeFee;
        s.rewardToken = _args.rewardToken;
        s.restakeDiscountForStratosphereMembers[1] = 500; // 5%
        s.restakeDiscountForStratosphereMembers[2] = 550; // 5.5%
        s.restakeDiscountForStratosphereMembers[3] = 650; // 6.5%
        s.restakeDiscountForStratosphereMembers[4] = 800; // 8%
        s.restakeDiscountForStratosphereMembers[5] = 1000; // 10%
        s.restakeDiscountForStratosphereMembers[6] = 1500; // 15%
        s.restakeFeeReceivers.push(_args.replenishmentPool);
        s.restakeFeeReceivers.push(_args.labsMultisig);
        s.restakeFeeReceivers.push(_args.burnWallet);
        s.restakeFeeReceiversShares.push(8500); // 85%
        s.restakeFeeReceiversShares.push(1000); // 10%
        s.restakeFeeReceiversShares.push(500); // 5%
    }
}
