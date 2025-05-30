// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AlchemyProxyLoader} from "../src/AlchemyProxyLoader.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract DeployScript is Script {
    address public prodProxyLoaderOwner = 0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C;
    address public expectedProdDeployAddress = 0x39A37979BB4a14e3Cdd1D7Ba8475f588f5b13E5F;
    address public stgProxyLoaderOwner = 0x4F0cF2a1D11De183E989fF6287cc0973670f0583;
    address public expectedStgDeployAddress = 0x29902f08df26E5984dBB58131EcEeA754d15CB16;
    bool internal _isProd;

    // Prod, 0.7 EP
    bytes32 public proxySalt = 0x0000000000000000000000000000000000000000d0cdac1fc979ce15f752cd13;
    address public proxyAddress = 0x0000000000Fe335F59B373055a9865eE4c2cFb3e;

    // Prod, 0.6 EP
    bytes32 public proxySalt2 = 0x000000000000000000000000000000000000000048994d99a8c95651d4d72027;
    address public proxyAddress2 = 0x0000000000785AaAA2db533cF000766a0B67DC28;

    // Staging, 0.7 EP
    address public proxyAddress3 = 0x62aB4822EBc25CC30b56D874Eb36D66AaF27372e;

    // Staging, 0.6 EP
    address public proxyAddress4 = 0x990A645f1d25b6BA0CA691B1353C0e3148Dd6d10;

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
