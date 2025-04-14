// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Blead} from "../src/Blead.sol";

contract BleadDeploy is Script {
    Blead public deployedContract;

    function setUp() public {}

    function run() public {
        address usdContractAddress = vm.envAddress("USD_CONTRACT_ADDRESS");
        uint256 monthlyPriceUsd = vm.envUint("MONTHLY_PRICE_USD");
        uint256 annualPriceUsd = vm.envUint("ANNUAL_PRICE_USD");

        vm.startBroadcast();
        deployedContract = new Blead(usdContractAddress, monthlyPriceUsd, annualPriceUsd);
        vm.stopBroadcast();

        console.log("Deployed successfully. Contract address:", address(deployedContract));
    }
}
