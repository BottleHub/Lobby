// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Transfer {
    IERC20 public brew;

    constructor(address _brew) {
        brew = IERC20(_brew);
    }

    function getBREWBalance(address account) public view returns (uint256) {
        return brew.balanceOf(account);
    }

    function transferBREW(
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(brew.transfer(recipient, amount), "Transfer failed");
        return true;
    }
}
