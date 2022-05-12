# Stobox Factory

## Code

`StoboxFactory.sol`

# Events

## PairCreated

```solidity
event PairCreated(address indexed token0, address indexed token1, address pair, uint);
```

Emitted each time a pair is created via createPair.

- `token0` is guaranteed to be strictly less than `token1` by sort order.
- The final `uint` log value will be `1` for the first pair created, `2` for the second, etc.

# Read-Only Functions

## getPair

```solidity
function getPair(address tokenA, address tokenB) external view returns (address pair);
```

Returns the address of the pair for `tokenA` and `tokenB`, if it has been created, else `address(0)` (`0x0000000000000000000000000000000000000000`).

- `tokenA` and `tokenB` are interchangeable.
- Pair addresses can also be calculated deterministically via the SDK.

## allPairs

```solidity
function allPairs(uint) external view returns (address pair);
```

Returns the address of the `n`th pair (`0`-indexed) created through the factory, or `address(0)` (`0x0000000000000000000000000000000000000000`) if not enough pairs have been created yet.

- Pass `0` for the address of the first pair created, `1` for the second, etc.

## allPairsLength

```solidity
function allPairsLength() external view returns (uint);
```

Returns the total number of pairs created through the factory so far.

## feeTo

```solidity
function feeTo() external view returns (address);
```

## feeToSetter

```solidity
function feeToSetter() external view returns (address);
```

The address allowed to change feeTo.

# State-Changing Functions

## createPair

```solidity
function createPair(address tokenA, address tokenB, address sender, uint _liquidityFee) external returns (address pair);
```

Creates a pair for `tokenA` and `tokenB` if one doesn't exist already.

- `tokenA` and `tokenB` are interchangeable.
- Emits PairCreated.
- Sender is `msg.sender` in the the router's context. Here is for setting liquidity commission accordingly to the existing roles (**admins** - sets custom fee that's equal `_liquidityFee`; **security token owners** - 0%; **others** - default commission taken from a constant `pairFee`).

## setFeeTo

```solidity
function setFeeTo(address _feeTo) external;
```

Sets new `feeTo` address of the factory.

- Can be executed only by `feeToSetter` address.

## setFeeToSetter

```solidity
function setFeeToSetter(address _feeToSetter) external;
```

Sets new `feeToSetter` address of the factory.

- Can be executed only by `feeToSetter` address.

## addAdmin

```solidity
function addAdmin(address _newAdmin) OnlyAdmin external;
```

Adds a new admin to the list of admins.

- Can be executed only by another admin address.
- Will fail if given address (`_newAdmin`) is already on the list.

## removeAdmin

```solidity
function removeAdmin(address _adminAddress) OnlyAdmin external returns(bool);
```

Removes a particular admin from the list of admins.

- Can be executed only by the admin addresses.
- You cannot remove yourself from the list of admins.
- Will fail if given address (`_adminAddress`) is already on the list or the last one.

## addSecurityTokenOwner

```solidity
function addSecurityTokenOwner(address _newOwner) OnlyAdmin external;
```

Adds a particular address to the list of security token owners.

- Can be executed only by one of the admins.
- The given address (`_newOwner`) cannot be one from the admins list.

## removeSecurityTokenOwner

```solidity
function removeSecurityTokenOwner(address _ownerAddress) OnlyAdmin external;
```

Removes `_ownerAddress` from the list of the security token owners.

- Can be executed only by one of the admins.
