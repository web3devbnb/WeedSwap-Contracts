# WeedSwap Library

## Code

`WeedSwapLibrary.sol`

# Internal Functions

## sortTokens

```solidity
function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1);
```

Sorts token addresses.

## pairFor

```solidity
function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair);
```

Calculates the address for a pair without making any external calls via the v2 SDK.

## getReserves

```solidity
function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB);
```

Calls getReserves on the pair for the passed tokens, and returns the results sorted in the order that the parameters were passed in.

## quote

```solidity
function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB);
```

Given some asset amount and reserves, returns an amount of the other asset representing equivalent value.

- Useful for calculating optimal token amounts before calling mint.

## getAmountOut

```solidity
function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint256 totalFee) internal pure returns (uint amountOut);
```

Given an _input_ asset amount, returns the maximum _output_ amount of the other asset (accounting for fees) given reserves.

- Used in getAmountsOut.

## getAmountIn

```solidity
function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint256 totalFee) internal pure returns (uint amountIn);
```

Returns the minimum _input_ asset amount required to buy the given _output_ asset amount (accounting for fees) given reserves.

- Used in getAmountsIn.

## getAmountsOut

```solidity
function getAmountsOut(uint amountIn, address[] memory path, uint256 totalFee) internal view returns (uint[] memory amounts);
```

Given an _input_ asset amount and an array of token addresses, calculates all subsequent maximum _output_ token amounts by calling getReserves for each pair of token addresses in the path in turn, and using these to call getAmountOut.

- Useful for calculating optimal token amounts before calling swap.

## getAmountsIn

```solidity
function getAmountsIn(address factory, uint amountOut, address[] memory path, uint256 totalFee) internal view returns (uint[] memory amounts);
```

Given an _output_ asset amount and an array of token addresses, calculates all preceding minimum _input_ token amounts by calling getReserves for each pair of token addresses in the path in turn, and using these to call getAmountIn.

- Useful for calculating optimal token amounts before calling swap.
