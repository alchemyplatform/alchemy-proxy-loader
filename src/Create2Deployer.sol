// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

library Create2Deployer {
    address public constant DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    error DeployerNotFound();
    error Create2Failed();
    error AlreadyDeployed();

    function deploy(bytes memory bytecode, bytes memory constructorArgs, bytes32 salt)
        internal
        returns (address deployed)
    {
        if (DEPLOYER.code.length == 0) {
            revert DeployerNotFound();
        }

        bytes memory initCode = bytes.concat(bytecode, constructorArgs);
        bytes memory factoryData = bytes.concat(salt, initCode);

        deployed = computeAddress(bytecode, constructorArgs, salt);

        if (deployed.code.length > 0) {
            revert AlreadyDeployed();
        }

        (bool ok,) = DEPLOYER.call(factoryData);
        if (!ok) {
            revert Create2Failed();
        }
    }

    function computeAddress(bytes memory bytecode, bytes memory constructorArgs, bytes32 salt)
        internal
        pure
        returns (address)
    {
        // CREATE2 address formula:
        // keccak256(0xff ++ deployer ++ salt ++ keccak256(init_code))[12:]
        bytes32 initCodeHash = keccak256(abi.encodePacked(bytecode, constructorArgs));
        bytes32 digest = keccak256(abi.encodePacked(bytes1(0xff), DEPLOYER, salt, initCodeHash));
        return address(uint160(uint256(digest)));
    }
}
