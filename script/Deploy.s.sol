// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AlchemyProxyLoader} from "../src/AlchemyProxyLoader.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Script} from "forge-std/Script.sol";
import {DeployConstants} from "./DeployConstants.sol";

contract DeployScript is Script, DeployConstants {
    bool internal _isProd;

    function run() public {
        vm.startBroadcast();

        _isProd = vm.envBool("IS_PROD");
        (
            bytes32[4] storage deploySalts,
            address[4] storage expectedProxyAddresses,
            address loaderOwner,
            address expectedDeployAddress
        ) = getDeployConfig(_isProd);

        if (expectedDeployAddress.code.length == 0) {
            address proxyLoader = address(new AlchemyProxyLoader{salt: 0}(loaderOwner));

            if (proxyLoader != expectedProdDeployAddress) {
                revert(
                    string(
                        abi.encodePacked(
                            "Proxy loader deployed to: ", proxyLoader, " instead of ", expectedProdDeployAddress
                        )
                    )
                );
            }
        }

        for (uint256 i = 0; i < deploySalts.length; i++) {
            if (expectedProxyAddresses[i].code.length == 0) {
                address proxy = address(new ERC1967Proxy{salt: deploySalts[i]}(expectedDeployAddress, ""));
                if (proxy != expectedProxyAddresses[i]) {
                    revert(
                        string(
                            abi.encodePacked("Proxy deployed to: ", proxy, " instead of ", expectedProxyAddresses[i])
                        )
                    );
                }
            }
        }

        vm.stopBroadcast();
    }
}
