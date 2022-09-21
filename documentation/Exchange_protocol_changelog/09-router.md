# WeedSwap Router

We'll cover changes over `WeedSwapRouter` contract.

## Notation Keys

| Symbol | Meaning                                     |
| :----- | :------------------------------------------ |
| ⏩     | Part of the code is skipped.                |
| -      | Part of the code that was removed/ changed. |
| +      | Modified part of the code. Current version. |

# Global Variables

## defaultLiquidityFee

```diff
+ uint public defaultLiquidityFee;
```

`defaultLiquidityFee` holds the default liquidity commission.

# Functions

## constructor

```diff
constructor(address _factory, address _WETH) public {
  factory = _factory;
  WETH = _WETH;
+ defaultLiquidityFee = IWeedSwapFactory(_factory).defaultLiquidityFee();
}
```

During deploying the `defaultLiquidityFee` is read from the factory contract.

## \_addLiquidity

```diff
  function _addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin
+ ) internal returns (uint256 amountA, uint256 amountB) {
+   return _addLiquidityWithFee(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, defaultLiquidityFee);
+ }
```

Default function calls overload function with `defaultLiquidityFee`, which is taken into consideration only if pair yet to create.

## \_addLiquidityWithFee

```diff
+  function _addLiquidityWithFee(
+    address tokenA,
+    address tokenB,
+    uint256 amountADesired,
+    uint256 amountBDesired,
+    uint256 amountAMin,
+    uint256 amountBMin,
+    uint256 liquidityFee
  ) internal virtual returns (uint256 amountA, uint256 amountB) {
    // create the pair if it doesn't exist yet
+   if (IWeedSwapFactory(factory).getPair(tokenA, tokenB) == address(0)) {
-      IWeedSwapFactory(factory).createPair(tokenA, tokenB);
+      IWeedSwapFactory(factory).createPair(tokenA, tokenB, msg.sender, liquidityFee);
    }
    (uint256 reserveA, uint256 reserveB) = WeedSwapLibrary.getReserves(factory, tokenA, tokenB);
    if (reserveA == 0 && reserveB == 0) {
⏩
```

Provides the opportunity to create a pair with custom commission value, but it will only work if `msg.sender` address was previously added on the list of admins in factory contract.

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
+   uint256 liquidityFee
+ )
+   external
+   virtual
+   override
+   ensure(deadline)
+   returns (
+     uint256 amountA,
+     uint256 amountB,
+     uint256 liquidity
+   )
+ {
+   require(liquidityFee >= 0 && liquidityFee < 92, "WeedSwapRouter: INVALID_FEE_AMOUNT");
+   (amountA, amountB) = _addLiquidityWithFee(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, liquidityFee);
+   address pair = WeedSwapLibrary.pairFor(factory, tokenA, tokenB);
+   TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
+   TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
+   liquidity = IWeedSwapPair(pair).mint(to);
+ }
```

Added to provide custom commission of the pair while creating a new one.

## addLiquidityETHWithFee

```diff
+ function addLiquidityETHWithFee(
+   address token,
+   uint256 amountTokenDesired,
+   uint256 amountTokenMin,
+   uint256 amountETHMin,
+   address to,
+   uint256 deadline,
+   uint256 liquidityFee
+ )
+   external
+   payable
+   virtual
+   override
+   ensure(deadline)
+   returns (
+     uint256 amountToken,
+     uint256 amountETH,
+     uint256 liquidity
+   )
+ {
+   require(liquidityFee >= 0 && liquidityFee < 92, "WeedSwapRouter: INVALID_FEE_AMOUNT");
+   (amountToken, amountETH) = _addLiquidityWithFee(
+     token,
+     WETH,
+     amountTokenDesired,
+    msg.value,
+     amountTokenMin,
+     amountETHMin,
+     liquidityFee
+   );
+   address pair = WeedSwapLibrary.pairFor(factory, token, WETH);
+   TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
+   IWETH(WETH).deposit{value: amountETH}();
+   assert(IWETH(WETH).transfer(pair, amountETH));
+   liquidity = IWeedSwapPair(pair).mint(to);
+   // refund dust eth, if any
+   if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
+ }
```

Added to provide custom commission of the pair while creating a new one.

## swapExactTokensForTokens

```diff
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
-   amounts = WeedSwapLibrary.getAmountsOut(factory, amountIn, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = WeedSwapLibrary.getAmountsOut(factory, amountIn, path, totalFee);
    require(amounts[amounts.length - 1] >= amountOutMin, "WeedSwapRouter: INSUFFICIENT_OUTPUT_AMOUNT");
    TransferHelper.safeTransferFrom(
      path[0],
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapTokensForExactTokens

```diff
  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
-    amounts = WeedSwapLibrary.getAmountsIn(factory, amountOut, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = WeedSwapLibrary.getAmountsIn(factory, amountOut, path, totalFee);
    require(amounts[0] <= amountInMax, "WeedSwapRouter: EXCESSIVE_INPUT_AMOUNT");
    TransferHelper.safeTransferFrom(
      path[0],
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapExactETHForTokens

```diff
  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable virtual override ensure(deadline) returns (uint256[] memory amounts) {
    require(path[0] == WETH, "WeedSwapRouter: INVALID_PATH");
-   amounts = WeedSwapLibrary.getAmountsOut(factory, msg.value, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = WeedSwapLibrary.getAmountsOut(factory, msg.value, path, totalFee);
    require(amounts[amounts.length - 1] >= amountOutMin, "WeedSwapRouter: INSUFFICIENT_OUTPUT_AMOUNT");
    IWETH(WETH).deposit{value: amounts[0]}();
    assert(IWETH(WETH).transfer(WeedSwapLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapTokensForExactETH

```diff
  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
    require(path[path.length - 1] == WETH, "WeedSwapRouter: INVALID_PATH");
-   amounts = WeedSwapLibrary.getAmountsIn(factory, amountOut, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = WeedSwapLibrary.getAmountsIn(factory, amountOut, path, totalFee);
    require(amounts[0] <= amountInMax, "WeedSwapRouter: EXCESSIVE_INPUT_AMOUNT");
    TransferHelper.safeTransferFrom(
      path[0],
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapExactTokensForETH

```diff
  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external virtual override ensure(deadline) returns (uint256[] memory amounts) {
    require(path[path.length - 1] == WETH, "WeedSwapRouter: INVALID_PATH");
-   amounts = WeedSwapLibrary.getAmountsOut(factory, amountIn, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = WeedSwapLibrary.getAmountsOut(factory, amountIn, path, totalFee);
    require(amounts[amounts.length - 1] >= amountOutMin, "WeedSwapRouter: INSUFFICIENT_OUTPUT_AMOUNT");
    TransferHelper.safeTransferFrom(
      path[0],
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapETHForExactTokens

```diff
  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable virtual override ensure(deadline) returns (uint256[] memory amounts) {
    require(path[0] == WETH, "WeedSwapRouter: INVALID_PATH");
-   amounts = WeedSwapLibrary.getAmountsIn(factory, amountOut, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = WeedSwapLibrary.getAmountsIn(factory, amountOut, path, totalFee);
    require(amounts[0] <= msg.value, "WeedSwapRouter: EXCESSIVE_INPUT_AMOUNT");
    IWETH(WETH).deposit{value: amounts[0]}();
    assert(IWETH(WETH).transfer(WeedSwapLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## \_swapSupportingFeeOnTransferTokens

```diff
⏩
    (uint256 reserveInput, uint256 reserveOutput) =
        input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
-   amountOutput = WeedSwapLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
+   uint256 totalFee = getTotalFee(path);
+   amountOutput = WeedSwapLibrary.getAmountOut(amountInput, reserveInput, reserveOutput, totalFee);
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## getAmountOut

```diff
  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
-   uint256 reserveOut
+   uint256 reserveOut,
+   uint256 totalFee
  ) public pure virtual override returns (uint256 amountOut) {
-   return WeedSwapLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
+   return WeedSwapLibrary.getAmountOut(amountIn, reserveIn, reserveOut, totalFee);
  }
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
  ) public pure virtual override returns (uint256 amountIn) {
-   return WeedSwapLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
+   return WeedSwapLibrary.getAmountIn(amountOut, reserveIn, reserveOut, totalFee);
  }
```

Updated to provide the ability to deduct the `amountIn` by taking into account the commission of the pair.

## getAmountsOut

```diff
- return WeedSwapLibrary.getAmountsOut(factory, amountIn, path);
+ uint256 totalFee = getTotalFee(path);
+ return WeedSwapLibrary.getAmountsOut(factory, amountIn, path, totalFee);
```

Updated to provide the ability to deduct the `amounts` by taking into account the commission of the pair.

## getAmountsIn

```diff
- return WeedSwapLibrary.getAmountsIn(factory, amountOut, path);
+ uint256 totalFee = getTotalFee(path);
+ return WeedSwapLibrary.getAmountsIn(factory, amountOut, path, totalFee);
```

Updated to provide the ability to deduct the `amounts` by taking into account the commission of the pair.

## getTotalFee

```diff
+ function getTotalFee(address[] memory path) internal view returns(uint256) {
+   return IWeedSwapPair(WeedSwapLibrary.pairFor(factory, path[0], path[1])).getTotalFee();
+ }
```

Added for ease of use in the router.
