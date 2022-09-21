# Deployment process

We'll cover the deployment process of exchange-protocol in this chapter.
The exchange-protocol consists of four contracts, which are:

- WBNB to manage transactions, which include ETH;
- WeedSwapFactory to manage all pairs.
- WeedSwapRouter01, which provides main logic of the protocol.
- WeedSwapRouter, which provides main logic of the protocol and is main contract.

## Deploy **WBNB** (WETH)

> NOTE: There is absolutely no reason to deploy a brand new `WBNB` contract if you already have one.

| Parameter        |                                                  |
| ---------------- | ------------------------------------------------ |
| File name        | WBNB.sol                                         |
| Path             | ./exchange-protocol/contracts/libraries/WBNB.sol |
| Compiler version | v0.8.3+commit.8d00100c                           |

### Follow the steps

- Compiler tab:
  - Select compiler: `v0.8.3+commit.8d00100c`;
- Deploy tab:
  - Select `WBNB`;
  - Deploy;

## Deploy **WeedSwapFactory**

| Parameter        | Value                                           |
| ---------------- | ----------------------------------------------- |
| File name        | WeedSwapFactory.sol                               |
| Path             | ./exchange-protocol/contracts/WeedSwapFactory.sol |
| Compiler version | v0.5.16+commit.9c3226ce                         |

### Constructor parameters

| Parameter   | Type      |                                                     |
| ----------- | --------- | --------------------------------------------------- |
| feeToSetter | `address` | Address to manage the fee account.                  |
| admins      | `array`   | List of admins to manage all security token owners. |

### Follow next steps

- Compiler tab:
  - Select compiler: `v0.5.16+commit.9c3226ce`;
- Deploy tab:
  - Select `WeedSwapFactory`;
  - Provide `admins` addresses and `feeToSetter` address as constructor params;
  - Deploy;

## Deploy **WeedSwapRouter01**

| Parameter        | Value                                            |
| ---------------- | ------------------------------------------------ |
| File name        | WeedSwapRouter01.sol                               |
| Path             | ./exchange-protocol/contracts/WeedSwapRouter01.sol |
| Compiler version | v0.6.6+commit.6c089d02                           |

### Constructor parameters

| Parameter | Type      |                                                             |
| --------- | --------- | ----------------------------------------------------------- |
| factory   | `address` | Factory address to manage pools (pairs).                    |
| WETH      | `address` | WBNB (Wrapped BNB) address for transactions supporting ETH. |

### Follow next steps

- Expand WeedSwapFactory deployed above:
  - Read `INIT_CODE_PAIR_HASH`;
  - Copy this hash without prefix `'0x'`;
    > Example: bb600ba95884f2c2837114fd2f157d00137e0b65b0fe5226523d720e4a4ce539
- Edit WeedSwapLibrary:
  - Find WeedSwapLibrary and then go to `pairFor` function;
  - Replace new hex by `INIT_CODE_PAIR_HASH` above;
    > Example: hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' hex'bb600ba95884f2c2837114fd2f157d00137e0b65b0fe5226523d720e4a4ce539'
- Compiler tab:
  - Select compiler: `v0.6.6+commit.6c089d02`;
  - Check on `Enable optimization: 200` to avoid contract code size limit issue;
- Deploy tab:
  - Select `WeedSwapRouter01`;
  - Fill `WeedSwapFactory` address and `WBNB` address as constructor params;
  - Deploy;

## Deploy **WeedSwapRouter** (Main router)

| Parameter        | Value                                          |
| ---------------- | ---------------------------------------------- |
| File name        | WeedSwapRouter.sol                               |
| Path             | ./exchange-protocol/contracts/WeedSwapRouter.sol |
| Compiler version | v0.6.6+commit.6c089d02                         |

### Constructor parameters

| Parameter | Type      |                                                             |
| --------- | --------- | ----------------------------------------------------------- |
| factory   | `address` | Factory address to manage pools (pairs).                    |
| WETH      | `address` | WBNB (Wrapped BNB) address for transactions supporting ETH. |

### Follow next steps

> NOTE: You don't have to do steps 1-2 if you did it earlier while deploying `WeedSwapRouter01`.

- Expand WeedSwapFactory deployed above:
  - Read `INIT_CODE_PAIR_HASH`;
  - Copy this hash without prefix `'0x'`;
    > Example: bb600ba95884f2c2837114fd2f157d00137e0b65b0fe5226523d720e4a4ce539
- Edit WeedSwapLibrary:
  - Find WeedSwapLibrary and then go to `pairFor` function;
  - Replace new hex by `INIT_CODE_PAIR_HASH` above;
    > Example: hex'd0d4c4cd0848c93cb4fd1f498d7013ee6bfb25783ea21593d5834f5d250ece66' hex'bb600ba95884f2c2837114fd2f157d00137e0b65b0fe5226523d720e4a4ce539'
- Compiler tab:
  - Select compiler: `v0.6.6+commit.6c089d02`;
  - Check on `Enable optimization: 200` to avoid contract code size limit issue;
- Deploy tab:
  - Select `WeedSwapRouter`;
  - Fill `WeedSwapFactory` address and `WBNB` address as constructor params;
  - Deploy;
