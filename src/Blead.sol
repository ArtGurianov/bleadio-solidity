// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Blead is Ownable {
    error TokenTransferFailed();

    enum SubscriptionPlan {
        MONTHLY,
        ANNUAL
    }

    struct SubscriptionData {
        uint256 subscriptionStartTimestamp;
        uint256 subscriptionEndTimestamp;
    }

    uint256 public MONTHLY_PRICE_USD;
    uint256 public ANNUAL_PRICE_USD;
    address public USD_CONTRACT_ADDRESS;

    constructor(address usdContractAddress, uint256 monthlyPriceUSD, uint256 annualPriceUSD) Ownable(msg.sender) {
        USD_CONTRACT_ADDRESS = usdContractAddress;
        MONTHLY_PRICE_USD = monthlyPriceUSD;
        ANNUAL_PRICE_USD = annualPriceUSD;
    }

    // bytes32 userId => SubscriptionData
    mapping(bytes32 => SubscriptionData) private subscriptions;

    function getSubscriptionData(bytes32 userIdHash) public view returns (SubscriptionData memory) {
        return subscriptions[userIdHash];
    }

    function updateSubscription(bytes32 userIdHash, SubscriptionPlan plan) public {
        uint256 chargeAmountUSD = plan == SubscriptionPlan.MONTHLY ? MONTHLY_PRICE_USD : ANNUAL_PRICE_USD;
        uint8 decimals = ERC20(USD_CONTRACT_ADDRESS).decimals();
        bool success =
            ERC20(USD_CONTRACT_ADDRESS).transferFrom(msg.sender, address(owner()), chargeAmountUSD * 10 ** decimals);

        if (!success) revert TokenTransferFailed();
        uint256 addDays = plan == SubscriptionPlan.MONTHLY ? 30 : 360;

        SubscriptionData memory subscriptionData = subscriptions[userIdHash];
        // ADD TO ONGOING SUBSCRIPTION
        if (subscriptionData.subscriptionEndTimestamp > block.timestamp) {
            subscriptions[userIdHash].subscriptionEndTimestamp =
                subscriptions[userIdHash].subscriptionEndTimestamp + addDays * 3600 * 24;
        }
        // NEW SUBSCRIPTION
        if (
            subscriptionData.subscriptionStartTimestamp == 0 && subscriptionData.subscriptionEndTimestamp == 0
                || subscriptionData.subscriptionEndTimestamp <= block.timestamp
        ) {
            subscriptions[userIdHash] = SubscriptionData({
                subscriptionStartTimestamp: block.timestamp,
                subscriptionEndTimestamp: block.timestamp + addDays * 3600 * 24
            });
        }
    }

    function changeUsdContractAddress(address newAddress) external onlyOwner {
        USD_CONTRACT_ADDRESS = newAddress;
    }

    function changeMonthlyPriceUsd(uint256 newPriceUsd) external onlyOwner {
        MONTHLY_PRICE_USD = newPriceUsd;
    }

    function changeAnnualPriceUsd(uint256 newPriceUsd) external onlyOwner {
        ANNUAL_PRICE_USD = newPriceUsd;
    }
}
