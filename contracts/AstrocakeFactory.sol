// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.5.16;

import './interfaces/IAstrocakeFactory.sol';
import './AstrocakePair.sol';

contract AstrocakeFactory is IAstrocakeFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(AstrocakePair).creationCode));

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    address[] public admins;
    mapping(address => bool) public securityTokenOwner;

    uint public defaultLiquidityFee = 22;

    modifier OnlyAdmin() {
        require(isAdmin(msg.sender), "Astrocake: FORBIDDEN");
        _;
    }

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter, address[] memory _admins) public {
        require(_admins.length >= 1, "Astrocake: NO_ADMINS_WERE_ADDED");
        feeToSetter = _feeToSetter;
        admins = _admins;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB, address sender, uint _liquidityFee) external returns (address pair) {
        require(tokenA != tokenB, 'Astrocake: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Astrocake: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Astrocake: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(AstrocakePair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        uint liquidityFee = defaultLiquidityFee;
        bool isNoFee = false;
        if (isAdmin(sender)) {
            liquidityFee = _liquidityFee;
        } else if (isSecurityTokenOwner(sender)) {
            liquidityFee = 0;
            isNoFee = true;
        }
        IAstrocakePair(pair).initialize(token0, token1, liquidityFee, isNoFee);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'Astrocake: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'Astrocake: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    // **** SECURITY TOKEN OWNERS ****
    function addSecurityTokenOwner(address _newOwner) OnlyAdmin external {
        require(!isAdmin(_newOwner), "Astrocake: ADDRESS_REGISTRED_AS_ADMIN");
        require(!isSecurityTokenOwner(_newOwner), "Astrocake: SECURITY_TOKEN_OWNER_ALREADY_EXIST");
        securityTokenOwner[_newOwner] = true;
    }

    function removeSecurityTokenOwner(address _ownerAddress) OnlyAdmin external {
        require(isSecurityTokenOwner(_ownerAddress), "Astrocake: INVALID_SECURITY_TOKEN_OWNER_ADDRESS");
        delete securityTokenOwner[_ownerAddress];
    }

    function isSecurityTokenOwner(address _ownerAddress) internal view returns (bool) {
        return securityTokenOwner[_ownerAddress];
    }

    // **** ADMINS ****
    function addAdmin(address _newAdmin) OnlyAdmin external {
        require(!isAdmin(_newAdmin), "Astrocake: ADMIN_ALREADY_EXIST");
        admins.push(_newAdmin);
    }

    function removeAdmin(address _adminAddress) OnlyAdmin external returns(bool) {
        require(isAdmin(_adminAddress), "Astrocake: INVALID_ADMIN_ADDRESS");
        require(msg.sender != _adminAddress, "Astrocake: YOU_CANNOT_REMOVE_YOURSELF");
        require(admins.length > 1, "Astrocake: YOU_CANNOT_REMOVE_THE_LAST_ADMIN");
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] == _adminAddress) {
                if (admins.length != (i - 1)) {
                    admins[i] = admins[admins.length - 1];
                }
                admins.pop();
                return true;
            }
        }
        return false;
    }

    function isAdmin(address _adminAddress) internal view returns (bool) {
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] == _adminAddress) return true;
        }
        return false;
    }
}