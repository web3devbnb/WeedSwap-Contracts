# Astrocake Router #01

We'll cover changes over `AstrocakeRouter01` contract.

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
+   defaultLiquidityFee = IAstrocakeFactory(_factory).defaultLiquidityFee();
  }
```

During deploying the `defaultLiquidityFee` is read from the factory contract.

## \_addLiquidity

```diff
  function _addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin
- ) private returns (uint amountA, uint amountB) {
+ ) internal virtual returns (uint256 amountA, uint256 amountB) {
+   return _addLiquidityWithFee(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, defaultLiquidityFee);
  }
```

Default function calls overload function with `defaultLiquidityFee`, which is taken into consideration only if pair yet to create.

## \_addLiquidityWithFee

```diff
+ function _addLiquidityWithFee(
+   address tokenA,
+   address tokenB,
+   uint256 amountADesired,
+   uint256 amountBDesired,
+   uint256 amountAMin,
+   uint256 amountBMin,
+   uint256 liquidityFee
+ ) internal virtual returns (uint256 amountA, uint256 amountB) {
+   // create the pair if it doesn't exist yet
+   if (IAstrocakeFactory(factory).getPair(tokenA, tokenB) == address(0)) {
+     IAstrocakeFactory(factory).createPair(tokenA, tokenB, msg.sender, liquidityFee);
+   }
+   (uint256 reserveA, uint256 reserveB) = AstrocakeLibrary.getReserves(factory, tokenA, tokenB);
+   if (reserveA == 0 && reserveB == 0) {
+     (amountA, amountB) = (amountADesired, amountBDesired);
+   } else {
+     uint256 amountBOptimal = AstrocakeLibrary.quote(amountADesired, reserveA, reserveB);
+     if (amountBOptimal <= amountBDesired) {
+       require(amountBOptimal >= amountBMin, "AstrocakeRouter: INSUFFICIENT_B_AMOUNT");
+       (amountA, amountB) = (amountADesired, amountBOptimal);
+     } else {
+       uint256 amountAOptimal = AstrocakeLibrary.quote(amountBDesired, reserveB, reserveA);
+       assert(amountAOptimal <= amountADesired);
+       require(amountAOptimal >= amountAMin, "AstrocakeRouter: INSUFFICIENT_A_AMOUNT");
+       (amountA, amountB) = (amountAOptimal, amountBDesired);
+     }
+   }
+ }
```

Provides the opportunity to create a pair with custom commission value, but it will only work if `msg.sender` address was previously added on the list of admins in factory contract.

## addLiquidityWithFee

```diff
+ function addLiquidityWithFee(
+     address tokenA,
+     address tokenB,
+     uint256 amountADesired,
+     uint256 amountBDesired,
+     uint256 amountAMin,
+     uint256 amountBMin,
+     address to,
+     uint256 deadline,
+     uint256 liquidityFee
+   )
+     external
+     virtual
+     override
+     ensure(deadline)
+     returns (
+       uint256 amountA,
+       uint256 amountB,
+       uint256 liquidity
+     )
+   {
+     require(liquidityFee >= 0 && liquidityFee < 92, "AstrocakeRouter: INVALID_FEE_AMOUNT");
+     (amountA, amountB) = _addLiquidityWithFee(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, liquidityFee);
+     address pair = AstrocakeLibrary.pairFor(factory, tokenA, tokenB);
+     TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
+     TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
+     liquidity = IAstrocakePair(pair).mint(to);
+   }
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
+   require(liquidityFee >= 0 && liquidityFee < 92, "AstrocakeRouter: INVALID_FEE_AMOUNT");
+   (amountToken, amountETH) = _addLiquidityWithFee(
+     token,
+     WETH,
+     amountTokenDesired,
+     msg.value,
+     amountTokenMin,
+     amountETHMin,
+     liquidityFee
+   );
+   address pair = AstrocakeLibrary.pairFor(factory, token, WETH);
+   TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
+   IWETH(WETH).deposit{value: amountETH}();
+   assert(IWETH(WETH).transfer(pair, amountETH));
+   liquidity = IAstrocakePair(pair).mint(to);
+   // refund dust eth, if any
+   if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
+ }
```

Added to provide custom commission of the pair while creating a new one.

## swapExactTokensForTokens

```diff
  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external override ensure(deadline) returns (uint[] memory amounts) {
-   amounts = AstrocakeLibrary.getAmountsOut(factory, amountIn, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = AstrocakeLibrary.getAmountsOut(factory, amountIn, path, totalFee);
    require(amounts[amounts.length - 1] >= amountOutMin, 'AstrocakeRouter: INSUFFICIENT_OUTPUT_AMOUNT');
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapTokensForExactTokens

```diff
  function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  ) external override ensure(deadline) returns (uint[] memory amounts) {
-   amounts = AstrocakeLibrary.getAmountsIn(factory, amountOut, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = AstrocakeLibrary.getAmountsIn(factory, amountOut, path, totalFee);
    require(amounts[0] <= amountInMax, 'AstrocakeRouter: EXCESSIVE_INPUT_AMOUNT');
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapExactETHForTokens

```diff
  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
  {
    require(path[0] == WETH, 'AstrocakeRouter: INVALID_PATH');
-   amounts = AstrocakeLibrary.getAmountsOut(factory, msg.value, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = AstrocakeLibrary.getAmountsOut(factory, msg.value, path, totalFee);
    require(amounts[amounts.length - 1] >= amountOutMin, 'AstrocakeRouter: INSUFFICIENT_OUTPUT_AMOUNT');
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapTokensForExactETH

```diff
  function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    override
    ensure(deadline)
    returns (uint[] memory amounts)
  {
    require(path[path.length - 1] == WETH, 'AstrocakeRouter: INVALID_PATH');
-   amounts = AstrocakeLibrary.getAmountsIn(factory, amountOut, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = AstrocakeLibrary.getAmountsIn(factory, amountOut, path, totalFee);
    require(amounts[0] <= amountInMax, 'AstrocakeRouter: EXCESSIVE_INPUT_AMOUNT');
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapExactTokensForETH

```diff
  function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    override
    ensure(deadline)
    returns (uint[] memory amounts)
  {
    require(path[path.length - 1] == WETH, 'AstrocakeRouter: INVALID_PATH');
-   amounts = AstrocakeLibrary.getAmountsOut(factory, amountIn, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = AstrocakeLibrary.getAmountsOut(factory, amountIn, path, totalFee);
    require(amounts[amounts.length - 1] >= amountOutMin, 'AstrocakeRouter: INSUFFICIENT_OUTPUT_AMOUNT');
⏩
```

Updated to calculate the `amounts` taking into account the commission of the pair.

## swapETHForExactTokens

```diff
  function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
  {
    require(path[0] == WETH, 'AstrocakeRouter: INVALID_PATH');
-   amounts = AstrocakeLibrary.getAmountsIn(factory, amountOut, path);
+   uint256 totalFee = getTotalFee(path);
+   amounts = AstrocakeLibrary.getAmountsIn(factory, amountOut, path, totalFee);
    require(amounts[0] <= msg.value, 'AstrocakeRouter: EXCESSIVE_INPUT_AMOUNT');
    IWETH(WETH).deposit{value: amounts[0]}();
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
-   return AstrocakeLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
+   return AstrocakeLibrary.getAmountOut(amountIn, reserveIn, reserveOut, totalFee);
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
-   return AstrocakeLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
+   return AstrocakeLibrary.getAmountIn(amountOut, reserveIn, reserveOut, totalFee);
  }
```

Updated to provide the ability to deduct the `amountIn` by taking into account the commission of the pair.

## getAmountsOut

```diff
- return AstrocakeLibrary.getAmountsOut(factory, amountIn, path);
+ uint256 totalFee = getTotalFee(path);
+ return AstrocakeLibrary.getAmountsOut(factory, amountIn, path, totalFee);
```

Updated to provide the ability to deduct the `amounts` by taking into account the commission of the pair.

## getAmountsIn

```diff
- return AstrocakeLibrary.getAmountsIn(factory, amountOut, path);
+ uint256 totalFee = getTotalFee(path);
+ return AstrocakeLibrary.getAmountsIn(factory, amountOut, path, totalFee);
```

Updated to provide the ability to deduct the `amounts` by taking into account the commission of the pair.

## getTotalFee

```diff
+ function getTotalFee(address[] memory path) internal view returns(uint256) {
+   return IAstrocakePair(AstrocakeLibrary.pairFor(factory, path[0], path[1])).getTotalFee();
+ }
```

Added for ease of use in the router.
