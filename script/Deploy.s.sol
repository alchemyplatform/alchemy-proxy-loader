// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AlchemyProxyLoader} from "../src/AlchemyProxyLoader.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract DeployScript is Script {
    address public prodProxyLoaderOwner = 0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C;
    address public expectedProdDeployAddress = 0x55954b89aA546269D8eDA34d7b97C948fab74a0D;
    address public stgProxyLoaderOwner = 0x4F0cF2a1D11De183E989fF6287cc0973670f0583;
    address public expectedStgDeployAddress = 0x4eb21516cdd2355CeD7a82018854BBe2E6Df018c;
    bool internal _isProd;

    // Prod, 0.7 EP
    bytes32 public proxySalt = 0x00000000000000000000000000000000000000005aff81b0e059e437fe647c08;
    address public proxyAddress = 0x00000000000667F27D4DB42334ec11a25db7EBb4;

    // Prod, 0.6 EP
    bytes32 public proxySalt2 = 0x00000000000000000000000000000000000000001d26e644345a7729701286e0;
    address public proxyAddress2 = 0x0000000000ce04e2359130e7d0204A5249958921;

    // Staging, 0.7 EP
    address public proxyAddress3 = 0x0AFc5739C3312Fc5B0900fD9CA4b4e4b2B2aD085;

    // Staging, 0.6 EP
    address public proxyAddress4 = 0xc4C4202DD4515678C9415d8Ebc8be116bd0d1828;

    function run() public {
        vm.startBroadcast();

        _isProd = vm.envBool("IS_PROD");

        if (_isProd) {
            if (expectedProdDeployAddress.code.length == 0) {
                address proxyLoader =
                    address(new AlchemyProxyLoader{salt: 0}(0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C));

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

            if (proxyAddress.code.length == 0) {
                address proxy = address(new ERC1967Proxy{salt: proxySalt}(expectedProdDeployAddress, ""));

                if (proxy != proxyAddress) {
                    revert(string(abi.encodePacked("Proxy1 deployed to: ", proxy, " instead of ", proxyAddress)));
                }
            }

            if (proxyAddress2.code.length == 0) {
                address proxy2 = address(new ERC1967Proxy{salt: proxySalt2}(expectedProdDeployAddress, ""));

                if (proxy2 != proxyAddress2) {
                    revert(string(abi.encodePacked("Proxy2 deployed to: ", proxy2, " instead of ", proxyAddress2)));
                }
            }
        } else {
            if (expectedStgDeployAddress.code.length == 0) {
                address proxyLoader2 = address(new AlchemyProxyLoader{salt: 0}(stgProxyLoaderOwner));

                if (proxyLoader2 != expectedStgDeployAddress) {
                    revert(
                        string(
                            abi.encodePacked(
                                "Proxy loader 2 deployed to: ", proxyLoader2, " instead of ", stgProxyLoaderOwner
                            )
                        )
                    );
                }
            }

            if (proxyAddress3.code.length == 0) {
                address proxy3 = address(new ERC1967Proxy{salt: 0}(expectedStgDeployAddress, ""));

                if (proxy3 != proxyAddress3) {
                    revert(string(abi.encodePacked("Proxy3 deployed to: ", proxy3, " instead of ", proxyAddress3)));
                }
            }

            if (proxyAddress4.code.length == 0) {
                address proxy4 = address(new ERC1967Proxy{salt: bytes32(uint256(1))}(expectedStgDeployAddress, ""));

                if (proxy4 != proxyAddress4) {
                    revert(string(abi.encodePacked("Proxy4 deployed to: ", proxy4, " instead of ", proxyAddress4)));
                }
            }
        }
        vm.stopBroadcast();
    }
}
