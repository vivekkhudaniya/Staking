pragma solidity ^0.8.0;

contract StakingContract {
    // Struct to store stake information
    struct Stake {
        uint256 amount;
        uint256 lastStakedBlock;
        uint256 totalRewards;
    }
    
    // Mapping to store stakes of each user
    mapping(address => Stake[]) public stakes;

    // DEFI token address
    address public DEFI_TOKEN_ADDRESS;
    
    // Number of DEFI tokens needed to earn 1 DEFI token per day
    uint256 public constant STAKE_AMOUNT_PER_REWARD = 1000;

    // Event emitted when a user stakes DEFI tokens
    event Staked(address indexed user, uint256 amount);

    // Event emitted when a user withdraws DEFI tokens and rewards
    event Withdrawn(address indexed user, uint256 amount, uint256 rewards);

    constructor(address _DEFI_TOKEN_ADDRESS) {
        DEFI_TOKEN_ADDRESS = _DEFI_TOKEN_ADDRESS;
    }

    // Function to stake DEFI tokens
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(ERC20(DEFI_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Update user's stake information
        stakes[msg.sender].push(Stake({
            amount: amount,
            lastStakedBlock: block.number,
            totalRewards: 0
        }));

        emit Staked(msg.sender, amount);
    }

    // Function to withdraw staked DEFI tokens and rewards
    function withdraw() external {
        Stake[] storage userStakes = stakes[msg.sender];
        require(userStakes.length > 0, "No stake to withdraw");

        uint256 totalAmount;
        uint256 totalRewards;

        // Calculate and sum up total staked amount and rewards
        for (uint256 i = 0; i < userStakes.length; i++) {
            totalAmount += userStakes[i].amount;
            totalRewards += calculateRewards(userStakes[i]);
        }

        // Transfer staked DEFI tokens and rewards to the user
        require(ERC20(DEFI_TOKEN_ADDRESS).transfer(msg.sender, totalAmount + totalRewards), "Transfer failed");

        // Clear user's stakes
        delete stakes[msg.sender];

        emit Withdrawn(msg.sender, totalAmount, totalRewards);
    }

    // Function to calculate rewards for a stake
    function calculateRewards(Stake memory stake) internal view returns (uint256) {
        uint256 blocksPassed = block.number - stake.lastStakedBlock;
        return (blocksPassed * stake.amount) / STAKE_AMOUNT_PER_REWARD;
    }

    // Function to view total rewards accrued for a user's stakes
    function viewRewards(address user) external view returns (uint256) {
        Stake[] storage userStakes = stakes[user];
        uint256 totalRewards;

        // Calculate total rewards for all user's stakes
        for (uint256 i = 0; i < userStakes.length; i++) {
            totalRewards += calculateRewards(userStakes[i]);
        }

        return totalRewards;
    }
}

// ERC20 interface for interacting with DEFI token
interface ERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
