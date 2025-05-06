// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AlchemyProxyRegistry} from "../src/AlchemyProxyRegistry.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract AlchemyProxyRegistryTest is Test {
    AlchemyProxyRegistry public proxyRegistry;
    bytes32 internal immutable _PROXY_IMPL_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function setUp() public {
        proxyRegistry = new AlchemyProxyRegistry(address(this));
    }

    function test_deploys() public {
        // check that owner is test contract
        assertEq(address(proxyRegistry.deployer()), address(this));

        address proxy = address(new ERC1967Proxy(address(proxyRegistry), ""));

        // instance of implementation to test upgradeTo
        address toUpgradeTo = address(new AlchemyProxyRegistry(address(this)));

        assertEq(_getImplementation(proxy), address(proxyRegistry));
        AlchemyProxyRegistry(proxy).upgradeToAndCall(toUpgradeTo, "");

        // check that implementation is now the new implementation
        assertEq(_getImplementation(proxy), address(toUpgradeTo));
    }

    function test_deployBad() public {
        // check that owner is test contract
        assertEq(address(proxyRegistry.deployer()), address(this));

        address proxy = address(new ERC1967Proxy(address(proxyRegistry), ""));

        // instance of implementation to test upgradeTo
        address toUpgradeTo = address(new AlchemyProxyRegistry(address(this)));

        assertEq(_getImplementation(proxy), address(proxyRegistry));
        vm.startPrank(address(1));
        vm.expectRevert("Only deployer can upgrade");
        AlchemyProxyRegistry(proxy).upgradeToAndCall(toUpgradeTo, "");

        // check that implementation is still the old implementation
        assertEq(_getImplementation(proxy), address(proxyRegistry));
    }

    function _getImplementation(address proxy) internal view returns (address) {
        return address(uint160(uint256(vm.load(address(proxy), _PROXY_IMPL_SLOT))));
    }
}
