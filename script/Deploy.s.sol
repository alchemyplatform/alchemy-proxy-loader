// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AlchemyProxyLoader} from "../src/AlchemyProxyLoader.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {Script} from "forge-std/Script.sol";

contract DeployScript is Script {
    address public create2Factory = address(0);
    address public proxyLoaderOwner = 0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C;
    address public expectedDeployAddress = 0x658ce9D45885BCE9682e5c07c9E7982610c7aB37;

    bytes32 public proxySalt = 0; // TODO
    address public proxyAddress = address(0); // TODO

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
            revert(string(abi.encodePacked("Proxy deployed to: ", proxy, " instead of ", proxyAddress)));
        }
    }
}
