// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface ISTBLS {

    function mint(address to, uint256 amount) external;

}

// Blume Liquid Staking Contract
contract BlumeLiquidStaking is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public BLSToken;
    ISTBLS public stBLSToken;

    // Uint
    uint256 internal totalStakedSupply;

    // Mapping
    mapping(address => uint256) internal userBalances;
    mapping(address => uint256) internal userStakedBalances;

    // Event
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    // Constructor
    constructor(IERC20 _BLSToken, ISTBLS _stBLSToken) {
        require(address(_BLSToken) != address(0), "Invalid BLS token address");
        require(address(_stBLSToken) != address(0), "Invalid stBLS token address");
        BLSToken = _BLSToken;
        stBLSToken = _stBLSToken;
    }

    // User
    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Stake amount must be greater than zero");
        BLSToken.safeTransferFrom(msg.sender, address(this), amount);
        userBalances[msg.sender] = userBalances[msg.sender].add(amount);
        userStakedBalances[msg.sender] = userStakedBalances[msg.sender].add(amount);
        totalStakedSupply = totalStakedSupply.add(amount);
        stBLSToken.mint(msg.sender, amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(userStakedBalances[msg.sender] >= amount, "Insufficient staked balance");
        userStakedBalances[msg.sender] = userStakedBalances[msg.sender].sub(amount);
        totalStakedSupply = totalStakedSupply.sub(amount);
        BLSToken.safeTransfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    // View
    function getUserStakedBalance(address user) public view returns (uint256) {
        return userStakedBalances[user];
    }

    function getTotalStakedSupply() public view returns (uint256) {
        return totalStakedSupply;
    }

}