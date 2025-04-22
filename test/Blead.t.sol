// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Blead} from "../src/Blead.sol";
import {TestUSD} from "../test/helpers/TestUSD.sol";

contract BleadTest is Test {
    address internal immutable DEPLOYER_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address internal immutable CUSTOMER_ADDRESS = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    bytes32 testUserId = bytes32(abi.encodePacked("random_string"));
    TestUSD public deployedContractUSD;
    Blead public deployedContractBlead;

    function setUp() public {
        vm.startBroadcast(DEPLOYER_ADDRESS);
        deployedContractUSD = new TestUSD();
        deployedContractBlead = new Blead(address(deployedContractUSD), 10, 100);
        vm.stopBroadcast();
    }

    function test_SubscribeNew() public {
        uint256 timestamp = block.timestamp;

        vm.startBroadcast(CUSTOMER_ADDRESS);
        deployedContractUSD.publicMintUSD(123);
        deployedContractUSD.approve(
            address(deployedContractBlead),
            deployedContractBlead.MONTHLY_PRICE_USD() * 10 ** deployedContractUSD.decimals()
        );
        deployedContractBlead.updateSubscription(testUserId, Blead.SubscriptionPlan.MONTHLY);
        vm.stopBroadcast();

        uint256[2] memory subscriptionData = deployedContractBlead.getSubscriptionData(testUserId);
        assertEq(subscriptionData[0], timestamp);
        assertEq(subscriptionData[1], timestamp + 30 * 24 * 3600);
    }
}
