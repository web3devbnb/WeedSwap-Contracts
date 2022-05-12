# Stobox Factory

We'll cover changes over `StoboxFactory` contract.

## Notation Keys

| Symbol | Meaning                                     |
| :----- | :------------------------------------------ |
| ⏩     | Part of the code is skipped.                |
| -      | Part of the code that was removed/ changed. |
| +      | Modified part of the code. Current version. |

# Global Variables

## admins

```diff
+ address[] public admins;
```

The array contains the list of admins.

## securityTokenOwner

```diff
+ mapping(address => bool) public securityTokenOwner;
```

This mapping is created to provide security token owners' logic, where `address` is the address of security token owner and `bool` is the state (`false` - not on the list; `true` - on the list)

## defaultLiquidityFee

```diff
+ uint public defaultLiquidityFee = 22;
```

Added for handy getting default commission of the service. Router accesses and retrieves this value during initialization.

# Modifiers

## OnlyAdmin

```diff
+ modifier OnlyAdmin() {
+   require(isAdmin(msg.sender), "Stobox: FORBIDDEN");
+   _;
+ }
```

Added for admins and security token owners' logic. This modifier restricts those addresses, who aren't on the list of admins to call all functions (addAdmin, removeAdmin, addSecurityTokenOwner, removeSecurityTokenOwner) related to this logic.

# Functions

## constructor

```diff
- constructor(address _feeToSetter) public {
+ constructor(address _feeToSetter, address[] memory _admins) public {
+   require(_admins.length >= 1, "Stobox: NO_ADMINS_WERE_ADDED");
+   feeToSetter = _feeToSetter;
+   admins = _admins;
+ }
```

**admins = \_admins** sets default admins during initializing of the smart contract.

## createPair

```diff
- function createPair(address tokenA, address tokenB) external returns (address pair) {
+ function createPair(address tokenA, address tokenB, address sender, uint _liquidityFee) external returns (address pair) {
  require(tokenA != tokenB, 'Stobox: IDENTICAL_ADDRESSES');
  (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
  require(token0 != address(0), 'Stobox: ZERO_ADDRESS');
⏩
  assembly {
    pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
  }
- IStoboxPair(pair).initialize(token0, token1);
+ uint liquidityFee = defaultLiquidityFee;
+ bool isNoFee = false;
+ if (isAdmin(sender)) {
+   liquidityFee = _liquidityFee;
+ } else if (isSecurityTokenOwner(sender)) {
+   liquidityFee = 0;
+   isNoFee = true;
+ }
  IStoboxPair(pair).initialize(token0, token1, liquidityFee, isNoFee);
  getPair[token0][token1] = pair;
  getPair[token1][token0] = pair; // populate mapping in the reverse direction
  allPairs.push(pair);
  emit PairCreated(token0, token1, pair, allPairs.length);
}
```

Updated to provide commission logic. `sender` is `msg.sender` of the router contract. `_liquidityFee` is considered if `sender` is on the list of admins.

## addAdmin

```diff
+ function addAdmin(address _newAdmin) OnlyAdmin external {
+   require(!isAdmin(_newAdmin), "Stobox: ADMIN_ALREADY_EXIST");
+   admins.push(_newAdmin);
+ }
```

Function was added to provide admin logic. It adds a new admin to the list.

## removeAdmin

```diff
+ function removeAdmin(address _adminAddress) OnlyAdmin external returns(bool) {
+   require(isAdmin(_adminAddress), "Stobox: INVALID_ADMIN_ADDRESS");
+   require(msg.sender != _adminAddress, "Stobox: YOU_CANNOT_REMOVE_YOURSELF");
+   require(admins.length > 1, "Stobox: YOU_CANNOT_REMOVE_THE_LAST_ADMIN");
+   for (uint i = 0; i < admins.length; i++) {
+     if (admins[i] == _adminAddress) {
+       if (admins.length != (i - 1)) {
+         admins[i] = admins[admins.length - 1];
+       }
+       admins.pop();
+       return true;
+     }
+   }
+   return false;
+ }
```

Function was added to provide admin logic. It removes the admin from the list.

## isAdmin

```diff
+ function isAdmin(address _adminAddress) internal view returns (bool) {
+   for (uint i = 0; i < admins.length; i++) {
+     if (admins[i] == _adminAddress) return true;
+   }
+   return false;
+ }
```

Function was added to provide admin logic. It checks whether the address is on the list of admins.

## addSecurityTokenOwner

```diff
+ function addSecurityTokenOwner(address _newOwner) OnlyAdmin external {
+   require(!isAdmin(_newOwner), "Stobox: ADDRESS_REGISTRED_AS_ADMIN");
+   require(!isSecurityTokenOwner(_newOwner), "Stobox: SECURITY_TOKEN_OWNER_ALREADY_EXIST");
+   securityTokenOwner[_newOwner] = true;
+ }
```

Function was added to provide security token owners' logic. It adds a new security token owner to the list.

## removeSecurityTokenOwner

```diff
+ function removeSecurityTokenOwner(address _ownerAddress) OnlyAdmin external {
+   require(isSecurityTokenOwner(_ownerAddress), "Stobox: INVALID_SECURITY_TOKEN_OWNER_ADDRESS");
+   delete securityTokenOwner[_ownerAddress];
+ }
```

Function was added to provide security token owners' logic. It removes the security token owner to the list.

## isSecurityTokenOwner

```diff
+ function isSecurityTokenOwner(address _ownerAddress) internal view returns (bool) {
+   return securityTokenOwner[_ownerAddress];
+ }
```

Function was added to provide admin logic. It checks whether the address is on the list of security token owners.
