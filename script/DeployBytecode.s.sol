// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DeployConstants} from "./DeployConstants.sol";
import {Create2Deployer} from "../src/Create2Deployer.sol";

contract DeployProxyFromBytecode is Script, DeployConstants {
    bool internal _isProd;

    function _deployFromBytecode(string memory fileName, bytes memory constructorArgs, bytes32 salt)
        internal
        returns (address deployed)
    {
        string memory hexBytecode = vm.readFile(fileName);
        bytes memory bytecode = vm.parseBytes(hexBytecode);
        deployed = Create2Deployer.deploy(bytecode, constructorArgs, salt);

        // Verify deployment succeeded
        require(deployed.code.length > 0, "Deployment failed: no code at deployed address");
    }

    function run() public {
        vm.startBroadcast();

        // Check if CREATE2 deployer exists
        if (Create2Deployer.DEPLOYER.code.length == 0) {
            revert(string.concat("CREATE2 deployer not found at: ", vm.toString(Create2Deployer.DEPLOYER)));
        }

        _isProd = vm.envBool("IS_PROD");
        (
            bytes32[4] storage deploySalts,
            address[4] storage expectedProxyAddresses,
            address loaderOwner,
            address expectedDeployAddress
        ) = getDeployConfig(_isProd);

        if (expectedDeployAddress.code.length == 0) {
            address proxyLoader =
                _deployFromBytecode("bytecode/AlchemyProxyLoader.bin", abi.encode(loaderOwner), bytes32(uint256(0)));
            if (proxyLoader != expectedDeployAddress) {
                revert(
                    string.concat(
                        "Proxy loader deployed to: ",
                        vm.toString(proxyLoader),
                        " instead of ",
                        vm.toString(expectedDeployAddress)
                    )
                );
            }
        }

        for (uint256 i = 0; i < deploySalts.length; i++) {
            if (expectedProxyAddresses[i].code.length == 0) {
                address proxy = _deployFromBytecode(
                    "bytecode/ERC1967Proxy.bin", abi.encode(expectedDeployAddress, ""), deploySalts[i]
                );
                if (proxy != expectedProxyAddresses[i]) {
                    revert(
                        string.concat(
                            "Proxy deployed to: ",
                            vm.toString(proxy),
                            " instead of ",
                            vm.toString(expectedProxyAddresses[i])
                        )
                    );
                }
            }
        }

        vm.stopBroadcast();
    }
}
