// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract NftStaking is Ownable {
    using SafeMath for uint256;

    IERC20 public rewardToken;
    IERC1155 public stakedNftAddress;
    uint256 public stakedNftTokenId;
    uint256 public stakedNftValue;

    constructor() {

    }

    function initialize(
        address _rewardToken,
        address _stakedNftAddress,
        uint256 _stakedNftTokenId,
        uint256 _stakedNftValue,  // worth reward token
        uint256 _rewardStartTime,
        uint256 _rewardEndTime,
        uint256 _apr
    ) external onlyOwner {

    }

    function deposit(uint amount) external {

    }

    function withdraw(uint amount) external {

    }

    function pendingReward(address account) external {

    }

    function claim() external {

    }


}
