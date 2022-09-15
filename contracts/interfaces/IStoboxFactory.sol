// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IAstrocakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function defaultLiquidityFee() external pure returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB, address sender, uint liquidityFee) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function addSecurityTokenOwner(address) external;

    function removeSecurityTokenOwner(address) external;

    function addAdmin(address) external;

    function removeAdmin(address) external returns(bool);

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}