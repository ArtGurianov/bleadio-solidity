// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Blead} from "../src/Blead.sol";
import {TestUSD} from "../test/helpers/TestUSD.sol";

contract BleadDeployment is Script {
    Blead public deployedContract;

    function setUp() public {}

    function run() public {
        bytes32 envMode = bytes32(abi.encodePacked(vm.envString("ENV_MODE")));
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        uint256 monthlyPriceUsd = vm.envUint("MONTHLY_PRICE_USD");
        uint256 annualPriceUsd = vm.envUint("ANNUAL_PRICE_USD");
        address usdContractAddress;

        vm.startBroadcast(deployerPrivateKey);
        if (envMode == bytes32(abi.encodePacked("development"))) {
            usdContractAddress = address(new TestUSD());
        }
        if (envMode == bytes32(abi.encodePacked("production"))) {
            usdContractAddress = vm.envAddress("USD_CONTRACT_ADDRESS");
        }

        deployedContract = new Blead(usdContractAddress, monthlyPriceUsd, annualPriceUsd);
        vm.stopBroadcast();

        console.log("Deployed successfully. Contract address:", address(deployedContract));
    }
}
