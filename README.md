Three primary contracts make up the given Solidity code: `BLS`, `StBLS`, and `BlumeLiquidStaking`. In the overall design of a liquid staking system for an ERC20 token, each contract plays a certain function. A thorough explanation of each contract and how they interact with one another can be found below.

1. BLS Token Contract

contract BLS is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("BLS Token", "BLS") {
        _mint(msg.sender, initialSupply);
    }
}

The BLS contract is a standard ERC20 token contract that defines the BLS token, with the following characteristics:
Name: BLS Token
Symbol: BLS
Decimals: 18 (standard for ERC20 tokens)

- Purpose: This contract defines a standard ERC20 token named "BLS Token" with the symbol "BLS".
- Minting: Upon deployment, an initial supply of tokens is minted and assigned to the owner's address.

2. StBLS Token Contract

contract StBLS is ERC20, Ownable {
    constructor() ERC20("Staked BLS", "stBLS") {}

    function mint(address recipient, uint256 amount) external onlyOwner {
        require(amount > 0, "Mint amount must be greater than zero");
        _mint(recipient, amount);
    }
}

The StBLS contract represents another ERC20 token, specifically designed for staked positions of BLS tokens:
Name: Staked BLS
Symbol: stBLS
Decimals: 18 (also follows the standard ERC20 convention)

- Purpose: This contract represents a separate ERC20 token called "Staked BLS" (symbol: "stBLS"), which is used to represent staked positions of the BLS tokens.
- Minting: The `mint` function allows the owner to create new stBLS tokens and assign them to a specified address. This is typically called when users stake their BLS tokens.

3. Blume Liquid Staking Contract

contract BlumeLiquidStaking is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public BLSToken;
    ISTBLS public stBLSToken;

    // Uint
    uint256 internal totalStakedSupply;
    mapping(address => uint256) internal userBalances;
    mapping(address => uint256) internal userStakedBalances;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor(IERC20 _BLSToken, ISTBLS _stBLSToken) {
        require(address(_BLSToken) != address(0), "Invalid BLS token address");
        require(address(_stBLSToken) != address(0), "Invalid stBLS token address");
        BLSToken = _BLSToken;
        stBLSToken = _stBLSToken;
    }

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

    function getUserStakedBalance(address user) public view returns (uint256) {
        return userStakedBalances[user];
    }

    function getTotalStakedSupply() public view returns (uint256) {
        return totalStakedSupply;
    }
}

Key Components:
- State Variables:
  - `BLSToken`: An instance of the BLS token contract.
  - `stBLSToken`: An instance of the stBLS token contract.
  - `totalStakedSupply`: Tracks the total amount of BLS tokens staked.
  - `userBalances`: Maps user addresses to their BLS token balances.
  - `userStakedBalances`: Maps user addresses to their staked BLS token balances.

- Events: 
  - `Staked`: Emitted when a user stakes BLS tokens.
  - `Unstaked`: Emitted when a user unstakes BLS tokens.

- Constructor: Initializes the contract with the addresses of the BLS and stBLS token contracts. It ensures that these addresses are valid.

Functions:
- Stake:
  - Users call `stake(uint256 amount)` to deposit BLS tokens into the contract.
  - The contract transfers the specified amount of BLS tokens from the user to itself.
  - It updates the user's balances and the total staked supply.
  - It mints an equivalent amount of stBLS tokens to the user, representing their staked position.
  - Emits a `Staked` event.

- Unstake:
  - Users call `unstake(uint256 amount)` to withdraw their staked BLS tokens.
  - The contract checks if the user has a sufficient staked balance.
  - It updates the user's staked balance and the total staked supply.
  - It transfers the specified amount of BLS tokens back to the user.
  - Emits an `Unstaked` event.

- View Functions:
  - `getUserStakedBalance(address user)`: Returns the staked balance of a specific user.
  - `getTotalStakedSupply()`: Returns the total amount of tokens currently staked in the contract.

Flow of Interactions
1. Token Creation:
   - The BLS token is created and an initial supply is minted to the deployer's address.
   - The StBLS token contract is created but starts with no minted tokens.

2. Staking Process:
   - A user who wants to stake their BLS tokens interacts with the `BlumeLiquidStaking` contract.
   - They call the `stake` function with the amount of BLS tokens they wish to stake.
   - The contract transfers the BLS tokens from the user to itself and mints an equivalent amount of stBLS tokens to the user.
   - The user's staked balance and the total staked supply are updated accordingly.

3. Unstaking Process:
   - When a user wants to withdraw their staked tokens, they call the `unstake` function.
   - The contract verifies the user's staked balance and allows them to withdraw the specified amount of BLS tokens.
   - The user's staked balance and the total staked supply are adjusted.

4. Balance Queries:
   - Users can check their staked balances and the total staked supply through the provided view functions.
