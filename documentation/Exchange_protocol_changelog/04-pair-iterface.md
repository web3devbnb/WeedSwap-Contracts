# Astrocake Pair Interface

We'll cover changes over `IAstrocakePair` contract.

## Notation Keys

| Symbol | Meaning                                     |
| :----- | :------------------------------------------ |
| -      | Part of the code that was removed/ changed. |
| +      | Modified part of the code. Current version. |

# Functions

## getTotalFee

```diff
+ function getTotalFee() external view returns(uint);
```

Added for easier access to the `totalFee` parameter of the pair.

## initialize

```diff
- function initialize(address, address) external;
+ function initialize(address, address, uint, bool) external;
```

While creating a new pair `uint` is the liquidity commission and `bool` is the parameter that shows whether the pair has 0% commission.
