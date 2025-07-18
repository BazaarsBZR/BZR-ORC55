// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BZR Coin – 0RC-55 Standard
 * @notice Immutable, multi-chain, fixed-supply monetary asset with race-condition-safe approval
 * @dev 0RC-55: Zero-Admin, Race-Conditionless, Contractually Final Standard
 * @author 0RC-55 Standard Contributors
 */
contract BZRCoin {
    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    string public constant name = "BZR";
    string public constant symbol = "BZR";
    uint8 public constant decimals = 18;

    /*//////////////////////////////////////////////////////////////
                                IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Fixed total supply - cannot be changed after deployment
    uint256 public immutable totalSupply;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Account balances
    mapping(address => uint256) private balances;

    /// @notice Current allowances: owner => spender => amount
    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when `amount` tokens are moved from `from` to `to`
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice Emitted when `owner` approves `spender` to spend `amount` tokens
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deploy BZR with fixed supply assigned to initial holder
     * @param initialHolder Address receiving the full supply (cannot be zero)
     * @param initialSupply Total token supply for this chain (must be > 0)
     */
    constructor(address initialHolder, uint256 initialSupply) {
        require(initialHolder != address(0), "0RC-55: zero address holder");
        require(initialSupply > 0, "0RC-55: zero initial supply");

        totalSupply = initialSupply;
        balances[initialHolder] = initialSupply;
        emit Transfer(address(0), initialHolder, initialSupply);
    }

    /*//////////////////////////////////////////////////////////////
                              PUBLIC API
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get token balance of account
     * @param account Address to query
     * @return Token balance in wei
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /**
     * @notice Transfer tokens to recipient
     * @param to Recipient address
     * @param amount Token amount to transfer
     * @return Always true (reverts on failure)
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @notice Approve spender to transfer tokens on your behalf
     * @dev 0RC-55 RACE PROTECTION: Must zero existing allowance before setting new non-zero amount
     * @param spender Address to approve
     * @param amount Token amount to approve
     * @return Always true (reverts on failure)
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "0RC-55: approve to zero address");
        require(amount == 0 || allowance[msg.sender][spender] == 0, "0RC-55: must zero allowance first");

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Transfer tokens from approved account
     * @param from Token owner address
     * @param to Recipient address  
     * @param amount Token amount to transfer
     * @return Always true (reverts on failure)
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 currentAllowance = allowance[from][msg.sender];
        require(currentAllowance >= amount, "0RC-55: allowance exceeded");

        allowance[from][msg.sender] = currentAllowance - amount;
        _transfer(from, to, amount);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                              INTERNAL
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Internal transfer with complete validation
     * @param from Sender address
     * @param to Recipient address
     * @param amount Token amount
     */
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0) && to != address(0), "0RC-55: zero address");
        require(from != to, "0RC-55: self-transfer not allowed");
        require(amount > 0, "0RC-55: zero amount");

        uint256 fromBalance = balances[from];
        require(fromBalance >= amount, "0RC-55: insufficient balance");

        unchecked {
            balances[from] = fromBalance - amount;
        }
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }
}
