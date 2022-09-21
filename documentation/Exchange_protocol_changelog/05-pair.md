# WeedSwap Pair

We'll cover changes over `WeedSwapPair` contract.

## Notation Keys

| Symbol | Meaning                                     |
| :----- | :------------------------------------------ |
| ⏩     | Part of the code is skipped.                |
| -      | Part of the code that was removed/ changed. |
| +      | Modified part of the code. Current version. |

# Global Variables

## liquidityFee

```diff
+ uint public liquidityFee; // default 22
```

Added to store the `liquidityFee` value.

## treasureBurnFee

```diff
+ uint public treasureBurnFee = 8;
```

Added to store the `treasureBurnFee` value.

## isNoFee

```diff
+ bool public isNoFee;
```

Added to store the `isNoFee` value. Shows whether the pair has 0% commission.

# Functions

## getTotalFee

```diff
+ function getTotalFee() public view returns(uint) {
+   return liquidityFee + treasureBurnFee;
+ }
```

Added for convenient value retrieval by router for further commission calculation.

## initialize

```diff
- function initialize(address _token0, address _token1) external {
+ function initialize(address _token0, address _token1, uint _liquidityFee, bool _isNoFee) external {
    require(msg.sender == factory, 'WeedSwap: FORBIDDEN'); // sufficient check
    token0 = _token0;
    token1 = _token1;
+   liquidityFee = _liquidityFee;
+   isNoFee = _isNoFee;
+   if (isNoFee) {
+     treasureBurnFee = 0;
+   }
  }
```

While creating a new pair `_liquidityFee` is the liquidity commission and `_isNoFee` is the parameter that shows whether the pair has 0% commission.

## \_mintFee

```diff
  function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
    address feeTo = IWeedSwapFactory(factory).feeTo();
-   feeOn = feeTo != address(0);
+   feeOn = feeTo != address(0) && !isNoFee;
    uint _kLast = kLast; // gas savings
    if (feeOn) {
      if (_kLast != 0) {
        uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
        uint rootKLast = Math.sqrt(_kLast);
        if (rootK > rootKLast) {
-         uint numerator = totalSupply.mul(rootK.sub(rootKLast)).mul(8);
-         uint denominator = rootK.mul(17).add(rootKLast.mul(8));
+         uint numerator = totalSupply.mul(rootK.sub(rootKLast));
+         uint denominator = rootK.mul(treasureBurnFee).add(rootKLast);
          uint liquidity = numerator / denominator;
          if (liquidity > 0) _mint(feeTo, liquidity);
        }
      }
    } else if (_kLast != 0) {
      kLast = 0;
    }
  }
```

Updated to calculate commission (treasury + burn) and send it to feeTo.

## swap

```diff
⏩
  uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
  require(amount0In > 0 || amount1In > 0, 'WeedSwap: INSUFFICIENT_INPUT_AMOUNT');
  { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
- uint balance0Adjusted = (balance0.mul(10000).sub(amount0In.mul(25)));
- uint balance1Adjusted = (balance1.mul(10000).sub(amount1In.mul(25)));
+ uint balance0Adjusted;
+ uint balance1Adjusted;
+  if (isNoFee) {
+   balance0Adjusted = (balance0.mul(10000));
+   balance1Adjusted = (balance1.mul(10000));
+ } else {
+   uint totalFee = getTotalFee();
+   balance0Adjusted = (balance0.mul(10000).sub(amount0In.mul(totalFee)));
+   balance1Adjusted = (balance1.mul(10000).sub(amount1In.mul(totalFee)));
+ }
  require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(10000**2), 'WeedSwap: K');
  }
⏩
```

Updated to understand the errors considering the `totalFee`.
