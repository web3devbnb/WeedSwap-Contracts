# Stobox Pair

## Code

`StoboxPair.sol`

# Events

## Mint

```solidity
event Mint(address indexed sender, uint amount0, uint amount1);
```

Emitted each time liquidity tokens are created via mint.

## Burn

```solidity
event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
```

Emitted each time liquidity tokens are destroyed via burn.

## Swap

```solidity
event Swap(
  address indexed sender,
  uint amount0In,
  uint amount1In,
  uint amount0Out,
  uint amount1Out,
  address indexed to
);
```

Emitted each time a swap occurs via swap.

## Sync

```solidity
event Sync(uint112 reserve0, uint112 reserve1);
```

Emitted each time reserves are updated via mint, burn(#burn-1), swap, or sync.

# Read-Only Functions

## MINIMUM_LIQUIDITY

```solidity
function MINIMUM_LIQUIDITY() external pure returns (uint);
```

Returns `1000` for all pairs.

## factory

```solidity
function factory() external view returns (address);
```

Returns the factory address.

## token0

```solidity
function token0() external view returns (address);
```

Returns the address of the pair token with the lower sort order.

## token1

```solidity
function token1() external view returns (address);
```

Returns the address of the pair token with the higher sort order.

## getReserves

```solidity
function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
```

Returns the reserves of token0 and token1 used to price trades and distribute liquidity. Also returns the `block.timestamp` (mod `2**32`) of the last block during which an interaction occurred for the pair.

## getTotalFee

```solidity
function getTotalFee() public view returns(uint);
```

Returns total fee of the pool.

## price0CumulativeLast

```solidity
function price0CumulativeLast() external view returns (uint);
```

## price1CumulativeLast

```solidity
function price1CumulativeLast() external view returns (uint);
```

## kLast

```solidity
function kLast() external view returns (uint);
```

Returns the product of the reserves as of the most recent liquidity event. See Protocol Charge Calculation.

# State-Changing Functions

## mint

```solidity
function mint(address to) external returns (uint liquidity);
```

Creates pool tokens.

- Emits Mint, Sync, Transfer.

## burn

```solidity
function burn(address to) external returns (uint amount0, uint amount1);
```

Destroys pool tokens.

- Emits Burn, Sync, Transfer.

## swap

```solidity
function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
```

Swaps tokens. For regular swaps, `data.length` must be `0`. Also see Flash Swaps.

- Emits Swap, Sync.

## skim

```solidity
function skim(address to) external;
```

## sync

```solidity
function sync() external;
```

- Emits Sync.
