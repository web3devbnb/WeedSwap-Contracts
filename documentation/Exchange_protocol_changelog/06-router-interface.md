# Stobox Router Interface

We'll cover changes over `IStoboxRouter01` contract.

## Notation Keys

| Symbol | Meaning                                     |
| :----- | :------------------------------------------ |
| -      | Part of the code that was removed/ changed. |
| +      | Modified part of the code. Current version. |

# Functions

## addLiquidityWithFee

```diff
+ function addLiquidityWithFee(
+   address tokenA,
+   address tokenB,
+   uint256 amountADesired,
+   uint256 amountBDesired,
+   uint256 amountAMin,
+   uint256 amountBMin,
+   address to,
+   uint256 deadline,
+   uint customFee
+ )
+   external
+   returns (
+     uint256 amountA,
+     uint256 amountB,
+     uint256 liquidity
+   );
```

Updated to comply with the new feature.

## addLiquidityETHWithFee

```diff
+ function addLiquidityETHWithFee(
+   address token,
+   uint256 amountTokenDesired,
+   uint256 amountTokenMin,
+   uint256 amountETHMin,
+   address to,
+   uint256 deadline,
+   uint customFee
+ )
+   external
+   payable
+   returns (
+     uint256 amountToken,
+     uint256 amountETH,
+     uint256 liquidity
+   );
```

Updated to comply with the new feature.

## getAmountOut

```diff
  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
-   uint256 reserveOut
+   uint256 reserveOut,
+   uint256 totalFee
  ) external pure returns (uint256 amountOut);
```

Updated to provide the ability to deduct the `amountOut` by taking into account the commission of the pair.

## getAmountIn

```diff
  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
-   uint256 reserveOut
+   uint256 reserveOut,
+   uint256 totalFee
  ) external pure returns (uint256 amountIn);
```

Updated to provide the ability to deduct the `amountIn` by taking into account the commission of the pair.
