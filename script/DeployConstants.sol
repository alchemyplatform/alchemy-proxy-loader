// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract DeployConstants {
    /*
     * Prod Constants
     */

    address public constant prodProxyLoaderOwner = 0xDdF32240B4ca3184De7EC8f0D5Aba27dEc8B7A5C;
    address public constant expectedProdDeployAddress = 0x55954b89aA546269D8eDA34d7b97C948fab74a0D;

    bytes32 public constant prodProxySalt0 = 0x00000000000000000000000000000000000000005aff81b0e059e437fe647c08;
    bytes32 public constant prodProxySalt1 = 0x00000000000000000000000000000000000000001d26e644345a7729701286e0;
    bytes32 public constant prodProxySalt2 = 0x000000000000000000000000000000000000000031c9751e6d4c2d0bd4b5c0a8;
    bytes32 public constant prodProxySalt3 = 0x0000000000000000000000000000000000000000eb2bb8b9d0820002d6ed4c7c;

    // used for prod paymaster v0.7
    address public constant prodProxyAddress0 = 0x00000000000667F27D4DB42334ec11a25db7EBb4;
    // used for prod paymaster v0.6
    address public constant prodProxyAddress1 = 0x0000000000ce04e2359130e7d0204A5249958921;
    // used for prod paymaster v0.8
    address public constant prodProxyAddress2 = 0x000000000804FF442BE7d200445362c46A008ADd;
    // used for prod paymaster v0.9
    address public constant prodProxyAddress3 = 0x000000000937001DeAAa5529004a07F638Edb57f;

    /*
     * Staging Constants
     */

    address public constant stgProxyLoaderOwner = 0x4F0cF2a1D11De183E989fF6287cc0973670f0583;
    address public constant expectedStgDeployAddress = 0x4eb21516cdd2355CeD7a82018854BBe2E6Df018c;

    // used for staging paymaster v0.7
    address public constant stagingProxyAddress0 = 0x0AFc5739C3312Fc5B0900fD9CA4b4e4b2B2aD085;
    // used for staging paymaster v0.6
    address public constant stagingProxyAddress1 = 0xc4C4202DD4515678C9415d8Ebc8be116bd0d1828;
    // used for staging paymaster v0.8
    address public constant stagingProxyAddress2 = 0x813d0b40CF2022Ccaf7451220abe7c7Efb01D0EE;
    // used for staging paymaster v0.9
    address public constant stagingProxyAddress3 = 0x69FFF4542cD2BaA91D6a797e5ebD9b07C88BdE70;

    /*
     * Arrays
     */

    bytes32[4] public prodProxySalts = [prodProxySalt0, prodProxySalt1, prodProxySalt2, prodProxySalt3];
    address[4] public prodProxyAddresses = [prodProxyAddress0, prodProxyAddress1, prodProxyAddress2, prodProxyAddress3];

    bytes32[4] public stgProxySalts =
        [bytes32(uint256(0)), bytes32(uint256(1)), bytes32(uint256(2)), bytes32(uint256(3))];
    address[4] public stgProxyAddresses =
        [stagingProxyAddress0, stagingProxyAddress1, stagingProxyAddress2, stagingProxyAddress3];

    function getDeployConfig(bool isProd)
        internal
        view
        returns (
            bytes32[4] storage deploySalts,
            address[4] storage expectedProxyAddresses,
            address loaderOwner,
            address expectedDeployAddress
        )
    {
        deploySalts = isProd ? prodProxySalts : stgProxySalts;
        expectedProxyAddresses = isProd ? prodProxyAddresses : stgProxyAddresses;
        loaderOwner = isProd ? prodProxyLoaderOwner : stgProxyLoaderOwner;
        expectedDeployAddress = isProd ? expectedProdDeployAddress : expectedStgDeployAddress;
    }
}
