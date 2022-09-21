# WeedSwap Factory Interface

We'll cover changes over `IWeedSwapFactory` contract.

## Notation Keys

| Symbol | Meaning                                     |
| :----- | :------------------------------------------ |
| -      | Part of the code that was removed/ changed. |
| +      | Modified part of the code. Current version. |

# Functions

## defaultLiquidityFee

```diff
+ function defaultLiquidityFee() external pure returns (uint256);
```

Added for easier reading of the `defaultLiquidityFee` parameter.

## createPair

```diff
- function createPair(address tokenA, address tokenB) external returns (address pair);
+ function createPair(address tokenA, address tokenB, address sender, uint liquidityFee) external returns (address pair);
```

Updated to match the function `createPair`.

## addSecurityTokenOwner

```diff
+ function addSecurityTokenOwner(address) external;
```

Added to remove the security token owner from the list. Ultimately, if one of the addresses will create a brand new pair, the commission equals to 0%.

## removeSecurityTokenOwner

```diff
+ function removeSecurityTokenOwner(address) external;
```

Added to remove the security token owner from the list. Ultimately, if one of the addresses will create a brand new pair, the commission equals to 0%.

## addAdmin

```diff
+ function addAdmin(address) external;
```

Added to provide admin logic. Admins can add/ remove security token owners.

## removeAdmin

```diff
+ function removeAdmin(address) external returns(bool);
```

Added to provide admin logic. Admins can add/ remove security token owners.
