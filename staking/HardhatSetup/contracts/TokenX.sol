// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title TokenX
/// @notice ERC-20 implementation of TokenX token
contract TokenX is ERC20 {
    /**
     * @dev Sets the values for {name = Token}, {totalSupply = 1000000} and {symbol = TokenX}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(uint256 fixedSupply) ERC20("Token", "TokenX") {
        super._mint(msg.sender, fixedSupply); // Since Total supply 1000000
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     * The receive function is executed on a call to the contract with empty calldata.
     */
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    fallback() external payable {}

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     * - invocation can be done, only by the contract owner.
     */
    function burn(address account, uint256 amount) public  {
        _burn(account, amount);
    }

    /**
     * @dev To transfer all ETHs stored in the contract to the caller
     *
     * Requirements:
     * - invocation can be done, only by the contract owner.
     */
    function withdrawAll() public payable  {
        require(
            payable(msg.sender).send(address(this).balance),
            "Withdraw failed"
        );
    }
}
