// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title AlchemyProxyLoader
 * @author Alchemy
 * @notice A loader to getting the same address for proxies regardless of their implementation
 * @dev To use, deploy a proxy pointing to this, then call upgradeToAndCall to the implementation
 */
contract AlchemyProxyLoader is UUPSUpgradeable {
    address public immutable deployer;

    constructor(address _deployer) {
        deployer = _deployer;
    }

    // upgrades can only be made by the deployer
    function _authorizeUpgrade(address) internal view override {
        require(msg.sender == deployer, "Only deployer can upgrade");
    }
}
