// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AlchemyProxyLoader} from "../src/AlchemyProxyLoader.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {Script} from "forge-std/Script.sol";

contract DeployScript is Script {
    address public create2Factory = address(0);
    address public proxyLoaderOwner = 0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C;
    address public expectedDeployAddress = 0xea8ea085589afBA8C5DA2808F150AC14fA10BA78;

    function run() public {
        address deployed = address(new AlchemyProxyLoader{salt: 0}(proxyLoaderOwner));

        if (deployed != expectedDeployAddress) {
            revert(string(abi.encodePacked("Attempted to deploy to address: ", deployed)));
        }
    }
}
