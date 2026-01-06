// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {AlchemyProxyLoader} from "../src/AlchemyProxyLoader.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {Create2Deployer} from "../src/Create2Deployer.sol";

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

    function test_getDeployedProxyInitcodeProd() public {
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

        address proxy5 = address(
            new ERC1967Proxy{salt: 0x000000000000000000000000000000000000000031c9751e6d4c2d0bd4b5c0a8}(
                address(0x55954b89aA546269D8eDA34d7b97C948fab74a0D), ""
            )
        );
        assertEq(proxy5, 0x000000000804FF442BE7d200445362c46A008ADd);

        address proxy7 = address(
            new ERC1967Proxy{salt: 0x0000000000000000000000000000000000000000000000000000000000433709}(
                address(0x55954b89aA546269D8eDA34d7b97C948fab74a0D), ""
            )
        );
        assertEq(proxy7, 0xA52A44684E57dcb75Ca416B64E7C5466FaaEb1CA);
    }

    function test_getDeployedProxyInitcodeStg() public {
        vm.startPrank(CREATE2_FACTORY);

        bytes32 bytecodeHash = keccak256(
            abi.encodePacked(
                type(ERC1967Proxy).creationCode, abi.encode(address(0x4eb21516cdd2355CeD7a82018854BBe2E6Df018c), "")
            )
        );

        assertEq(bytecodeHash, 0x62b6a1a799713d52d22b633a6a432fc72922df1432fcc646c2601d8c2f9dd981);
        new AlchemyProxyLoader{salt: 0}(address(0x4F0cF2a1D11De183E989fF6287cc0973670f0583));

        address proxy3 = address(
            new ERC1967Proxy{salt: bytes32(uint256(0))}(address(0x4eb21516cdd2355CeD7a82018854BBe2E6Df018c), "")
        );
        assertEq(proxy3, 0x0AFc5739C3312Fc5B0900fD9CA4b4e4b2B2aD085);

        address proxy4 = address(
            new ERC1967Proxy{salt: bytes32(uint256(1))}(address(0x4eb21516cdd2355CeD7a82018854BBe2E6Df018c), "")
        );
        assertEq(proxy4, 0xc4C4202DD4515678C9415d8Ebc8be116bd0d1828);

        address proxy6 = address(
            new ERC1967Proxy{salt: bytes32(uint256(2))}(address(0x4eb21516cdd2355CeD7a82018854BBe2E6Df018c), "")
        );
        assertEq(proxy6, 0x813d0b40CF2022Ccaf7451220abe7c7Efb01D0EE);

        address proxy8 = address(
            new ERC1967Proxy{salt: bytes32(uint256(3))}(address(0x4eb21516cdd2355CeD7a82018854BBe2E6Df018c), "")
        );
        assertEq(proxy8, 0x69FFF4542cD2BaA91D6a797e5ebD9b07C88BdE70);
    }

    function test_deployProxyFromBytecodeProd() public {
        // First deploy the AlchemyProxyLoader
        string memory loaderBytecode = vm.readFile("bytecode/AlchemyProxyLoader.bin");
        bytes memory loaderCode = vm.parseBytes(loaderBytecode);
        bytes memory loaderArgs = abi.encode(address(0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C));
        address computedLoader = Create2Deployer.computeAddress(loaderCode, loaderArgs, bytes32(uint256(0)));
        address loader = Create2Deployer.deploy(loaderCode, loaderArgs, bytes32(uint256(0)));
        assertEq(computedLoader, loader);
        assertEq(loader, 0x55954b89aA546269D8eDA34d7b97C948fab74a0D);

        // Now deploy the proxy
        string memory hexBytecode = vm.readFile("bytecode/ERC1967Proxy.bin");
        bytes memory bytecode = vm.parseBytes(hexBytecode);
        bytes memory constructorArgs = abi.encode(address(0x55954b89aA546269D8eDA34d7b97C948fab74a0D), "");
        bytes32 salt = 0x00000000000000000000000000000000000000005aff81b0e059e437fe647c08;
        address computedProxy = Create2Deployer.computeAddress(bytecode, constructorArgs, salt);
        address proxy = Create2Deployer.deploy(bytecode, constructorArgs, salt);
        assertEq(computedProxy, proxy);
        assertEq(proxy, 0x00000000000667F27D4DB42334ec11a25db7EBb4);
    }
}
