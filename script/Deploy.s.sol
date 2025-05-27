// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AlchemyProxyLoader} from "../src/AlchemyProxyLoader.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {Script} from "forge-std/Script.sol";

contract DeployScript is Script {
    address public proxyLoaderOwner = 0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C;
    address public expectedDeployAddress = 0x658ce9D45885BCE9682e5c07c9E7982610c7aB37;

    // Prod, 0.7 EP
    bytes32 public proxySalt = 0x0000000000000000000000000000000000000000d0cdac1fc979ce15f752cd13;
    address public proxyAddress = 0x0000000000Fe335F59B373055a9865eE4c2cFb3e;

    // Prod, 0.6 EP
    bytes32 public proxySalt2 = 0x000000000000000000000000000000000000000048994d99a8c95651d4d72027;
    address public proxyAddress2 = 0x0000000000785AaAA2db533cF000766a0B67DC28;

    // Staging, 0.7 EP
    bytes32 public proxySalt3 = 0x000000000000000000000000000000000000000060b11fff2c4a8442bbe7f3c5;
    address public proxyAddress3 = 0x5000000000f6cC5f16463A0e91640000E8D8ce00;

    // Staging, 0.6 EP
    bytes32 public proxySalt4 = 0x0000000000000000000000000000000000000000f788e7f793213c66d37faed2;
    address public proxyAddress4 = 0x657C00000000F35D28D33b47168E000000485935;

    function run() public {
        address proxyLoader = address(new AlchemyProxyLoader{salt: 0}(proxyLoaderOwner));

        if (proxyLoader != expectedDeployAddress) {
            revert(
                string(
                    abi.encodePacked("Proxy loader deployed to: ", proxyLoader, " instead of ", expectedDeployAddress)
                )
            );
        }

        address proxy = address(new ERC1967Proxy{salt: proxySalt}(proxyLoader, ""));

        if (proxy != proxyAddress) {
            revert(string(abi.encodePacked("Proxy1 deployed to: ", proxy, " instead of ", proxyAddress)));
        }

        address proxy2 = address(new ERC1967Proxy{salt: proxySalt}(proxyLoader, ""));

        if (proxy2 != proxyAddress2) {
            revert(string(abi.encodePacked("Proxy2 deployed to: ", proxy2, " instead of ", proxyAddress2)));
        }

        address proxy3 = address(new ERC1967Proxy{salt: proxySalt3}(proxyLoader, ""));

        if (proxy3 != proxyAddress3) {
            revert(string(abi.encodePacked("Proxy3 deployed to: ", proxy3, " instead of ", proxyAddress3)));
        }

        address proxy4 = address(new ERC1967Proxy{salt: proxySalt4}(proxyLoader, ""));

        if (proxy4 != proxyAddress4) {
            revert(string(abi.encodePacked("Proxy4 deployed to: ", proxy4, " instead of ", proxyAddress4)));
        }
    }
}
