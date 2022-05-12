# Stobox Library

We'll cover changes over `StoboxLibrary` contract.

## Notation Keys

| Symbol | Meaning                                     |
| :----- | :------------------------------------------ |
| -      | Part of the code that was removed/ changed. |
| +      | Modified part of the code. Current version. |

# Functions

## getAmountOut

```diff
  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
-   uint256 reserveOut
+   uint256 reserveOut,
+   uint256 totalFee
  ) internal pure returns (uint256 amountOut) {
    require(amountIn > 0, "StoboxLibrary: INSUFFICIENT_INPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "StoboxLibrary: INSUFFICIENT_LIQUIDITY");
-   uint256 amountInWithFee = amountIn.mul(9975);
+   uint256 amountInWithFee = amountIn.mul(10000 - totalFee);
    uint256 numerator = amountInWithFee.mul(reserveOut);
    uint256 denominator = reserveIn.mul(10000).add(amountInWithFee);
    amountOut = numerator / denominator;
  }
```

Updated to provide commission logic. The `amountInWithFee` is calculated according to the total commission of the pair.

## getAmountIn

```diff
  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
-   uint256 reserveOut
+   uint256 reserveOut,
+   uint256 totalFee
  ) internal pure returns (uint256 amountIn) {
    require(amountOut > 0, "StoboxLibrary: INSUFFICIENT_OUTPUT_AMOUNT");
    require(reserveIn > 0 && reserveOut > 0, "StoboxLibrary: INSUFFICIENT_LIQUIDITY");
    uint256 numerator = reserveIn.mul(amountOut).mul(10000);
-   uint256 denominator = reserveOut.sub(amountOut).mul(9975);
+   uint256 denominator = reserveOut.sub(amountOut).mul(10000 - totalFee);
    amountIn = (numerator / denominator).add(1);
  }
```

Updated to provide commission logic. The `denominator` is calculated according to the total commission of the pair.

## getAmountsOut

```diff
  function getAmountsOut(
    address factory,
    uint256 amountIn,
-   address[] memory path
+   address[] memory path,
+   uint256 totalFee
  ) internal view returns (uint256[] memory amounts) {
    require(path.length >= 2, "StoboxLibrary: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[0] = amountIn;
    for (uint256 i; i < path.length - 1; i++) {
      (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i], path[i + 1]);
-     amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
+     amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, totalFee);
    }
  }
```

Updated to provide commission logic. `amounts` is calculated according to the total commission of the pair.

## getAmountsIn

```diff
  function getAmountsIn(
    address factory,
    uint256 amountOut,
-   address[] memory path
+   address[] memory path,
+   uint256 totalFee
  ) internal view returns (uint256[] memory amounts) {
    require(path.length >= 2, "StoboxLibrary: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[amounts.length - 1] = amountOut;
    for (uint256 i = path.length - 1; i > 0; i--) {
      (uint256 reserveIn, uint256 reserveOut) = getReserves(factory, path[i - 1], path[i]);
-     amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
+     amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, totalFee);
    }
  }
```

Updated to provide commission logic. `amounts` is calculated according to the total commission of the pair.
