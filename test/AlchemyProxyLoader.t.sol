// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AlchemyProxyLoader} from "../src/AlchemyProxyLoader.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

contract AlchemyProxyLoaderTest is Test {
    AlchemyProxyLoader public proxyRegistry;
    bytes32 internal immutable _PROXY_IMPL_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function setUp() public {
        proxyRegistry = new AlchemyProxyLoader(address(this));
    }

    function test_deploys() public {
        // check that owner is test contract
        assertEq(address(proxyRegistry.deployer()), address(this));

        address proxy = address(new ERC1967Proxy(address(proxyRegistry), ""));

        // instance of implementation to test upgradeTo
        address toUpgradeTo = address(new AlchemyProxyLoader(address(this)));

        assertEq(_getImplementation(proxy), address(proxyRegistry));
        AlchemyProxyLoader(proxy).upgradeToAndCall(toUpgradeTo, "");

        // check that implementation is now the new implementation
        assertEq(_getImplementation(proxy), address(toUpgradeTo));
    }

    function test_deployBad() public {
        // check that owner is test contract
        assertEq(address(proxyRegistry.deployer()), address(this));

        address proxy = address(new ERC1967Proxy(address(proxyRegistry), ""));

        // instance of implementation to test upgradeTo
        address toUpgradeTo = address(new AlchemyProxyLoader(address(this)));

        assertEq(_getImplementation(proxy), address(proxyRegistry));
        vm.startPrank(address(1));
        vm.expectRevert("Only deployer can upgrade");
        AlchemyProxyLoader(proxy).upgradeToAndCall(toUpgradeTo, "");

        // check that implementation is still the old implementation
        assertEq(_getImplementation(proxy), address(proxyRegistry));
    }

    function _getImplementation(address proxy) internal view returns (address) {
        return address(uint160(uint256(vm.load(address(proxy), _PROXY_IMPL_SLOT))));
    }

    function test_getDeployedAddress() public pure {
        bytes32 bytecodeHash = keccak256(
            abi.encodePacked(
                type(AlchemyProxyLoader).creationCode,
                bytes32(uint256(uint160(0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C)))
            )
        );

        address predicted = Create2.computeAddress(bytes32(0), bytecodeHash, CREATE2_FACTORY);
        assertEq(predicted, 0x55954b89aA546269D8eDA34d7b97C948fab74a0D);
    }

    function test_getDeployedProxyInitcode() public {
        vm.startPrank(CREATE2_FACTORY);

        bytes32 bytecodeHash = keccak256(
            abi.encodePacked(
                type(ERC1967Proxy).creationCode, abi.encode(address(0x55954b89aA546269D8eDA34d7b97C948fab74a0D), "")
            )
        );
        assertEq(bytecodeHash, 0x11e76045975d22e464b853fc71f1d678388eb5612cff2c12789d82fcf3f5ffc0);
        new AlchemyProxyLoader{salt: 0}(address(0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C));

        address proxy = address(
            new ERC1967Proxy{salt: 0x00000000000000000000000000000000000000005aff81b0e059e437fe647c08}(
                address(0x55954b89aA546269D8eDA34d7b97C948fab74a0D), ""
            )
        );
        assertEq(proxy, 0x00000000000667F27D4DB42334ec11a25db7EBb4);

        address proxy2 = address(
            new ERC1967Proxy{salt: 0x00000000000000000000000000000000000000001d26e644345a7729701286e0}(
                address(0x55954b89aA546269D8eDA34d7b97C948fab74a0D), ""
            )
        );
        assertEq(proxy2, 0x0000000000ce04e2359130e7d0204A5249958921);
    }
}
