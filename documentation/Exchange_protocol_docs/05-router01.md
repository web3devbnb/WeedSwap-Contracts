# WeedSwap Router #01

## Code

`WeedSwapRouter01.sol`

# Read-Only Functions

## factory

```solidity
function factory() external pure returns (address);
```

Returns factory address.

## WETH

```solidity
function WETH() external pure returns (address);
```

Returns the [canonical WETH address](https://blog.0xproject.com/canonical-weth-a9aa7d0279dd) on the network.

## quote

Calls function from WeedSwapLibrary.

## getAmountOut

Calls function from WeedSwapLibrary.

## getAmountIn

Calls function from WeedSwapLibrary.

## getAmountsOut

```solidity
function getAmountsOut(uint amountIn, address[] memory path) public view returns (uint[] memory amounts);
```

Calls function from WeedSwapLibrary.

## getAmountsIn

```solidity
function getAmountsIn(uint amountOut, address[] memory path) public view returns (uint[] memory amounts);
```

Calls function from WeedSwapLibrary.

## getTotalPairFee

```solidity
function getTotalPairFee(address[] memory path) internal view returns(uint256);
```

Returns the value of the total fee for a particular pool.

# State-Changing Functions

## addLiquidity

```solidity
function addLiquidity(
  address tokenA,
  address tokenB,
  uint amountADesired,
  uint amountBDesired,
  uint amountAMin,
  uint amountBMin,
  address to,
  uint deadline
) external returns (uint amountA, uint amountB, uint liquidity);
```

Adds liquidity to an ERC-20⇄ERC-20 pool.

- To cover all possible scenarios, `msg.sender` should have already given the router an allowance of at least amountADesired/amountBDesired on tokenA/tokenB.
- Always adds assets at the ideal ratio, according to the price when the transaction is executed.
- If a pool for the passed tokens does not exists, one is created automatically, and exactly amountADesired/amountBDesired tokens are added.
- While creating a new pool uses default `liquidityFee` value.

| Name           | Type      |                                                                                                                |
| :------------- | :-------- | :------------------------------------------------------------------------------------------------------------- |
| tokenA         | `address` | A pool token.                                                                                                  |
| tokenB         | `address` | A pool token.                                                                                                  |
| amountADesired | `uint`    | The amount of tokenA to add as liquidity if the B/A price is <= amountBDesired/amountADesired (A depreciates). |
| amountBDesired | `uint`    | The amount of tokenB to add as liquidity if the A/B price is <= amountADesired/amountBDesired (B depreciates). |
| amountAMin     | `uint`    | Bounds the extent to which the B/A price can go up before the transaction reverts. Must be <= amountADesired.  |
| amountBMin     | `uint`    | Bounds the extent to which the A/B price can go up before the transaction reverts. Must be <= amountBDesired.  |
| to             | `address` | Recipient of the liquidity tokens.                                                                             |
| deadline       | `uint`    | Unix timestamp after which the transaction will revert.                                                        |
|                |           |                                                                                                                |
| amountA        | `uint`    | The amount of tokenA sent to the pool.                                                                         |
| amountB        | `uint`    | The amount of tokenB sent to the pool.                                                                         |
| liquidity      | `uint`    | The amount of liquidity tokens minted.                                                                         |

## addLiquidityWithFee

> NOTE: This function is identical with addLiquidity. The main difference is while creating a new pair this function can help to specify `liquidityFee`.

```solidity
function addLiquidity(
  address tokenA,
  address tokenB,
  uint amountADesired,
  uint amountBDesired,
  uint amountAMin,
  uint amountBMin,
  address to,
  uint deadline,
  uint256 liquidityFee
) external returns (uint amountA, uint amountB, uint liquidity);
```

Adds liquidity to an ERC-20⇄ERC-20 pool.

- To cover all possible scenarios, `msg.sender` should have already given the router an allowance of at least amountADesired/amountBDesired on tokenA/tokenB.
- Always adds assets at the ideal ratio, according to the price when the transaction is executed.
- If a pool for the passed tokens does not exists, one is created automatically, and exactly amountADesired/amountBDesired tokens are added.
- The `liquidityFee` is only taken into consideration when creating a token.

| Name           | Type      |                                                                                                                |
| :------------- | :-------- | :------------------------------------------------------------------------------------------------------------- |
| tokenA         | `address` | A pool token.                                                                                                  |
| tokenB         | `address` | A pool token.                                                                                                  |
| amountADesired | `uint`    | The amount of tokenA to add as liquidity if the B/A price is <= amountBDesired/amountADesired (A depreciates). |
| amountBDesired | `uint`    | The amount of tokenB to add as liquidity if the A/B price is <= amountADesired/amountBDesired (B depreciates). |
| amountAMin     | `uint`    | Bounds the extent to which the B/A price can go up before the transaction reverts. Must be <= amountADesired.  |
| amountBMin     | `uint`    | Bounds the extent to which the A/B price can go up before the transaction reverts. Must be <= amountBDesired.  |
| to             | `address` | Recipient of the liquidity tokens.                                                                             |
| deadline       | `uint`    | Unix timestamp after which the transaction will revert.                                                        |
| liquidityFee   | `uint`    | Custom liquidity fee for the pool while creating it.                                                           |
|                |           |                                                                                                                |
| amountA        | `uint`    | The amount of tokenA sent to the pool.                                                                         |
| amountB        | `uint`    | The amount of tokenB sent to the pool.                                                                         |
| liquidity      | `uint`    | The amount of liquidity tokens minted.                                                                         |

## addLiquidityETH

```solidity
function addLiquidityETH(
  address token,
  uint amountTokenDesired,
  uint amountTokenMin,
  uint amountETHMin,
  address to,
  uint deadline
) external payable returns (uint amountToken, uint amountETH, uint liquidity);
```

Adds liquidity to an ERC-20⇄WETH pool with ETH.

- To cover all possible scenarios, `msg.sender` should have already given the router an allowance of at least amountTokenDesired on token.
- Always adds assets at the ideal ratio, according to the price when the transaction is executed.
- `msg.value` is treated as a amountETHDesired.
- Leftover ETH, if any, is returned to `msg.sender`.
- If a pool for the passed token and WETH does not exists, one is created automatically, and exactly amountTokenDesired/`msg.value` tokens are added.
- While creating a new pool uses default `liquidityFee` value.

| Name                           | Type      |                                                                                                                           |
| :----------------------------- | :-------- | :------------------------------------------------------------------------------------------------------------------------ |
| token                          | `address` | A pool token.                                                                                                             |
| amountTokenDesired             | `uint`    | The amount of token to add as liquidity if the WETH/token price is <= `msg.value`/amountTokenDesired (token depreciates). |
| `msg.value` (amountETHDesired) | `uint`    | The amount of ETH to add as liquidity if the token/WETH price is <= amountTokenDesired/`msg.value` (WETH depreciates).    |
| amountTokenMin                 | `uint`    | Bounds the extent to which the WETH/token price can go up before the transaction reverts. Must be <= amountTokenDesired.  |
| amountETHMin                   | `uint`    | Bounds the extent to which the token/WETH price can go up before the transaction reverts. Must be <= `msg.value`.         |
| to                             | `address` | Recipient of the liquidity tokens.                                                                                        |
| deadline                       | `uint`    | Unix timestamp after which the transaction will revert.                                                                   |
|                                |           |                                                                                                                           |
| amountToken                    | `uint`    | The amount of token sent to the pool.                                                                                     |
| amountETH                      | `uint`    | The amount of ETH converted to WETH and sent to the pool.                                                                 |
| liquidity                      | `uint`    | The amount of liquidity tokens minted.                                                                                    |

## addLiquidityETHWithFee

> NOTE: This function is identical with addLiquidityETH. The main difference is while creating a new pair this function can help to specify `liquidityFee`.

```solidity
function addLiquidityETH(
  address token,
  uint amountTokenDesired,
  uint amountTokenMin,
  uint amountETHMin,
  address to,
  uint deadline
  uint256 liquidityFee
) external payable returns (uint amountToken, uint amountETH, uint liquidity);
```

Adds liquidity to an ERC-20⇄WETH pool with ETH.

- To cover all possible scenarios, `msg.sender` should have already given the router an allowance of at least amountTokenDesired on token.
- Always adds assets at the ideal ratio, according to the price when the transaction is executed.
- `msg.value` is treated as a amountETHDesired.
- Leftover ETH, if any, is returned to `msg.sender`.
- If a pool for the passed token and WETH does not exists, one is created automatically, and exactly amountTokenDesired/`msg.value` tokens are added.
- The `liquidityFee` is only taken into consideration when creating a token.

| Name                           | Type      |                                                                                                                           |
| :----------------------------- | :-------- | :------------------------------------------------------------------------------------------------------------------------ |
| token                          | `address` | A pool token.                                                                                                             |
| amountTokenDesired             | `uint`    | The amount of token to add as liquidity if the WETH/token price is <= `msg.value`/amountTokenDesired (token depreciates). |
| `msg.value` (amountETHDesired) | `uint`    | The amount of ETH to add as liquidity if the token/WETH price is <= amountTokenDesired/`msg.value` (WETH depreciates).    |
| amountTokenMin                 | `uint`    | Bounds the extent to which the WETH/token price can go up before the transaction reverts. Must be <= amountTokenDesired.  |
| amountETHMin                   | `uint`    | Bounds the extent to which the token/WETH price can go up before the transaction reverts. Must be <= `msg.value`.         |
| to                             | `address` | Recipient of the liquidity tokens.                                                                                        |
| deadline                       | `uint`    | Unix timestamp after which the transaction will revert.                                                                   |
| liquidityFee                   | `uint`    | Custom liquidity fee for the pool while creating it.                                                                      |
|                                |           |                                                                                                                           |
| amountToken                    | `uint`    | The amount of token sent to the pool.                                                                                     |
| amountETH                      | `uint`    | The amount of ETH converted to WETH and sent to the pool.                                                                 |
| liquidity                      | `uint`    | The amount of liquidity tokens minted.                                                                                    |

## removeLiquidity

```solidity
function removeLiquidity(
  address tokenA,
  address tokenB,
  uint liquidity,
  uint amountAMin,
  uint amountBMin,
  address to,
  uint deadline
) external returns (uint amountA, uint amountB);
```

Removes liquidity from an ERC-20⇄ERC-20 pool.

- `msg.sender` should have already given the router an allowance of at least liquidity on the pool.

| Name       | Type      |                                                                                       |
| :--------- | :-------- | :------------------------------------------------------------------------------------ |
| tokenA     | `address` | A pool token.                                                                         |
| tokenB     | `address` | A pool token.                                                                         |
| liquidity  | `uint`    | The amount of liquidity tokens to remove.                                             |
| amountAMin | `uint`    | The minimum amount of tokenA that must be received for the transaction not to revert. |
| amountBMin | `uint`    | The minimum amount of tokenB that must be received for the transaction not to revert. |
| to         | `address` | Recipient of the underlying assets.                                                   |
| deadline   | `uint`    | Unix timestamp after which the transaction will revert.                               |
|            |           |                                                                                       |
| amountA    | `uint`    | The amount of tokenA received.                                                        |
| amountB    | `uint`    | The amount of tokenB received.                                                        |

## removeLiquidityETH

```solidity
function removeLiquidityETH(
  address token,
  uint liquidity,
  uint amountTokenMin,
  uint amountETHMin,
  address to,
  uint deadline
) external returns (uint amountToken, uint amountETH);
```

Removes liquidity from an ERC-20⇄WETH pool and receive ETH.

- `msg.sender` should have already given the router an allowance of at least liquidity on the pool.

| Name           | Type      |                                                                                      |
| :------------- | :-------- | :----------------------------------------------------------------------------------- |
| token          | `address` | A pool token.                                                                        |
| liquidity      | `uint`    | The amount of liquidity tokens to remove.                                            |
| amountTokenMin | `uint`    | The minimum amount of token that must be received for the transaction not to revert. |
| amountETHMin   | `uint`    | The minimum amount of ETH that must be received for the transaction not to revert.   |
| to             | `address` | Recipient of the underlying assets.                                                  |
| deadline       | `uint`    | Unix timestamp after which the transaction will revert.                              |
|                |           |                                                                                      |
| amountToken    | `uint`    | The amount of token received.                                                        |
| amountETH      | `uint`    | The amount of ETH received.                                                          |

## removeLiquidityWithPermit

```solidity
function removeLiquidityWithPermit(
  address tokenA,
  address tokenB,
  uint liquidity,
  uint amountAMin,
  uint amountBMin,
  address to,
  uint deadline,
  bool approveMax, uint8 v, bytes32 r, bytes32 s
) external returns (uint amountA, uint amountB);
```

Removes liquidity from an ERC-20⇄ERC-20 pool without pre-approval, thanks to permit.

| Name       | Type      |                                                                                       |
| :--------- | :-------- | :------------------------------------------------------------------------------------ |
| tokenA     | `address` | A pool token.                                                                         |
| tokenB     | `address` | A pool token.                                                                         |
| liquidity  | `uint`    | The amount of liquidity tokens to remove.                                             |
| amountAMin | `uint`    | The minimum amount of tokenA that must be received for the transaction not to revert. |
| amountBMin | `uint`    | The minimum amount of tokenB that must be received for the transaction not to revert. |
| to         | `address` | Recipient of the underlying assets.                                                   |
| deadline   | `uint`    | Unix timestamp after which the transaction will revert.                               |
| approveMax | `bool`    | Whether or not the approval amount in the signature is for liquidity or `uint(-1)`.   |
| v          | `uint8`   | The v component of the permit signature.                                              |
| r          | `bytes32` | The r component of the permit signature.                                              |
| s          | `bytes32` | The s component of the permit signature.                                              |
|            |           |                                                                                       |
| amountA    | `uint`    | The amount of tokenA received.                                                        |
| amountB    | `uint`    | The amount of tokenB received.                                                        |

## removeLiquidityETHWithPermit

```solidity
function removeLiquidityETHWithPermit(
  address token,
  uint liquidity,
  uint amountTokenMin,
  uint amountETHMin,
  address to,
  uint deadline,
  bool approveMax, uint8 v, bytes32 r, bytes32 s
) external returns (uint amountToken, uint amountETH);
```

Removes liquidity from an ERC-20⇄WETTH pool and receive ETH without pre-approval, thanks to permit.

| Name           | Type      |                                                                                      |
| :------------- | :-------- | :----------------------------------------------------------------------------------- |
| token          | `address` | A pool token.                                                                        |
| liquidity      | `uint`    | The amount of liquidity tokens to remove.                                            |
| amountTokenMin | `uint`    | The minimum amount of token that must be received for the transaction not to revert. |
| amountETHMin   | `uint`    | The minimum amount of ETH that must be received for the transaction not to revert.   |
| to             | `address` | Recipient of the underlying assets.                                                  |
| deadline       | `uint`    | Unix timestamp after which the transaction will revert.                              |
| approveMax     | `bool`    | Whether or not the approval amount in the signature is for liquidity or `uint(-1)`.  |
| v              | `uint8`   | The v component of the permit signature.                                             |
| r              | `bytes32` | The r component of the permit signature.                                             |
| s              | `bytes32` | The s component of the permit signature.                                             |
|                |           |                                                                                      |
| amountToken    | `uint`    | The amount of token received.                                                        |
| amountETH      | `uint`    | The amount of ETH received.                                                          |

## swapExactTokensForTokens

```solidity
function swapExactTokensForTokens(
  uint amountIn,
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
) external returns (uint[] memory amounts);
```

Swaps an exact amount of input tokens for as many output tokens as possible, along the route determined by the path. The first element of path is the input token, the last is the output token, and any intermediate elements represent intermediate pairs to trade through (if, for example, a direct pair does not exist).

- `msg.sender` should have already given the router an allowance of at least amountIn on the input token.

| Name         | Type                 |                                                                                                                                      |
| :----------- | :------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| amountIn     | `uint`               | The amount of input tokens to send.                                                                                                  |
| amountOutMin | `uint`               | The minimum amount of output tokens that must be received for the transaction not to revert.                                         |
| path         | `address[] calldata` | An array of token addresses. `path.length` must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity. |
| to           | `address`            | Recipient of the output tokens.                                                                                                      |
| deadline     | `uint`               | Unix timestamp after which the transaction will revert.                                                                              |
|              |                      |                                                                                                                                      |
| amounts      | `uint[] memory`      | The input token amount and all subsequent output token amounts.                                                                      |

## swapTokensForExactTokens

```solidity
function swapTokensForExactTokens(
  uint amountOut,
  uint amountInMax,
  address[] calldata path,
  address to,
  uint deadline
) external returns (uint[] memory amounts);
```

Receive an exact amount of output tokens for as few input tokens as possible, along the route determined by the path. The first element of path is the input token, the last is the output token, and any intermediate elements represent intermediate pairs to trade through (if, for example, a direct pair does not exist).

- `msg.sender` should have already given the router an allowance of at least amountInMax on the input token.

| Name        | Type                 |                                                                                                                                      |
| :---------- | :------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| amountOut   | `uint`               | The amount of output tokens to receive.                                                                                              |
| amountInMax | `uint`               | The maximum amount of input tokens that can be required before the transaction reverts.                                              |
| path        | `address[] calldata` | An array of token addresses. `path.length` must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity. |
| to          | `address`            | Recipient of the output tokens.                                                                                                      |
| deadline    | `uint`               | Unix timestamp after which the transaction will revert.                                                                              |
|             |                      |                                                                                                                                      |
| amounts     | `uint[] memory`      | The input token amount and all subsequent output token amounts.                                                                      |

## swapExactETHForTokens

```solidity
function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
  external
  payable
  returns (uint[] memory amounts);
```

Swaps an exact amount of ETH for as many output tokens as possible, along the route determined by the path. The first element of path must be WETH, the last is the output token, and any intermediate elements represent intermediate pairs to trade through (if, for example, a direct pair does not exist).

| Name                   | Type                 |                                                                                                                                      |
| :--------------------- | :------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| `msg.value` (amountIn) | `uint`               | The amount of ETH to send.                                                                                                           |
| amountOutMin           | `uint`               | The minimum amount of output tokens that must be received for the transaction not to revert.                                         |
| path                   | `address[] calldata` | An array of token addresses. `path.length` must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity. |
| to                     | `address`            | Recipient of the output tokens.                                                                                                      |
| deadline               | `uint`               | Unix timestamp after which the transaction will revert.                                                                              |
|                        |                      |                                                                                                                                      |
| amounts                | `uint[] memory`      | The input token amount and all subsequent output token amounts.                                                                      |

## swapTokensForExactETH

```solidity
function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
  external
  returns (uint[] memory amounts);
```

Receive an exact amount of ETH for as few input tokens as possible, along the route determined by the path. The first element of path is the input token, the last must be WETH, and any intermediate elements represent intermediate pairs to trade through (if, for example, a direct pair does not exist).

- `msg.sender` should have already given the router an allowance of at least amountInMax on the input token.
- If the to address is a smart contract, it must have the ability to receive ETH.

| Name        | Type                 |                                                                                                                                      |
| :---------- | :------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| amountOut   | `uint`               | The amount of ETH to receive.                                                                                                        |
| amountInMax | `uint`               | The maximum amount of input tokens that can be required before the transaction reverts.                                              |
| path        | `address[] calldata` | An array of token addresses. `path.length` must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity. |
| to          | `address`            | Recipient of ETH.                                                                                                                    |
| deadline    | `uint`               | Unix timestamp after which the transaction will revert.                                                                              |
|             |                      |                                                                                                                                      |
| amounts     | `uint[] memory`      | The input token amount and all subsequent output token amounts.                                                                      |

## swapExactTokensForETH

```solidity
function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
  external
  returns (uint[] memory amounts);
```

Swaps an exact amount of tokens for as much ETH as possible, along the route determined by the path. The first element of path is the input token, the last must be WETH, and any intermediate elements represent intermediate pairs to trade through (if, for example, a direct pair does not exist).

- If the to address is a smart contract, it must have the ability to receive ETH.

| Name         | Type                 |                                                                                                                                      |
| :----------- | :------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| amountIn     | `uint`               | The amount of input tokens to send.                                                                                                  |
| amountOutMin | `uint`               | The minimum amount of output tokens that must be received for the transaction not to revert.                                         |
| path         | `address[] calldata` | An array of token addresses. `path.length` must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity. |
| to           | `address`            | Recipient of the ETH.                                                                                                                |
| deadline     | `uint`               | Unix timestamp after which the transaction will revert.                                                                              |
|              |                      |                                                                                                                                      |
| amounts      | `uint[] memory`      | The input token amount and all subsequent output token amounts.                                                                      |

## swapETHForExactTokens

```solidity
function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
  external
  payable
  returns (uint[] memory amounts);
```

Receive an exact amount of tokens for as little ETH as possible, along the route determined by the path. The first element of path must be WETH, the last is the output token and any intermediate elements represent intermediate pairs to trade through (if, for example, a direct pair does not exist).

- Leftover ETH, if any, is returned to `msg.sender`.

| Name                      | Type                 |                                                                                                                                      |
| :------------------------ | :------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| amountOut                 | `uint`               | The amount of tokens to receive.                                                                                                     |
| `msg.value` (amountInMax) | `uint`               | The maximum amount of ETH that can be required before the transaction reverts.                                                       |
| path                      | `address[] calldata` | An array of token addresses. `path.length` must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity. |
| to                        | `address`            | Recipient of the output tokens.                                                                                                      |
| deadline                  | `uint`               | Unix timestamp after which the transaction will revert.                                                                              |
|                           |                      |                                                                                                                                      |
| amounts                   | `uint[] memory`      | The input token amount and all subsequent output token amounts.                                                                      |
