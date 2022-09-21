// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract NftStaking is Ownable, IERC1155Receiver {
    using SafeMath for uint256;

    bool public initialized;

    IERC20 public rewardToken;
    IERC1155 public stakedNft;
    uint256 public stakedNftTokenId;
    uint256 public stakedNftValue;
    uint256 public rewardStartTime;
    uint256 public rewardEndTime;
    uint16 public apr;   // 1% -> 100
    uint16 public apr_denominator = 10000;

    struct UserInfo {
        address addr;
        uint256 amount;
        uint256 numOfstakedNft;
        uint256 rewardLocked;
        uint256 lastDeposited;
        // uint256 lastClaimed;
    }

    mapping (address => UserInfo) public userInfo;

    address[] userList;

    constructor() {

    }

    function initialize(
        address _rewardToken,
        address _stakedNftAddress,
        uint256 _stakedNftTokenId,
        uint256 _stakedNftValue,  // worth reward token
        uint256 _rewardStartTime,
        uint256 _rewardEndTime,
        uint16 _apr
    ) external onlyOwner {
        require(!initialized, "already initialized");
        require(_rewardToken != address(0), "invalid token address");
        require(_stakedNftAddress != address(0), "invalid nft address");
        require(_stakedNftValue > 0, "invalid nft value");
        require(_rewardStartTime > block.timestamp, "invalid start time");
        require(_apr > 0, "apr must not zero");
        
        rewardToken = IERC20(_rewardToken);
        stakedNft = IERC1155(_stakedNftAddress);
        stakedNftTokenId = _stakedNftTokenId;
        stakedNftValue = _stakedNftValue;
        rewardStartTime = _rewardStartTime;
        rewardEndTime = _rewardEndTime;
        apr = _apr;

        initialized = true;

        emit Initialized(_rewardToken, _stakedNftAddress, _stakedNftTokenId, _stakedNftValue, _rewardStartTime, _rewardEndTime, _apr);
    
    }
    event Initialized(
        address _rewardToken,
        address _stakedNftAddress,
        uint256 _stakedNftTokenId,
        uint256 _stakedNftValue, 
        uint256 _rewardStartTime,
        uint256 _rewardEndTime,
        uint16 _apr
    );

    function updateNftInfo(address _address, uint256 _tokenId) external onlyOwner {
        stakedNft = IERC1155(_address);
        stakedNftTokenId = _tokenId;
    }

    function deposit(uint amount) external {
        require(amount > 0, "invalid amount");
        require(
            stakedNft.balanceOf(msg.sender, stakedNftTokenId) >= amount,
            "insufficient balance"
        );
        require(
            stakedNft.isApprovedForAll(msg.sender, address(this)),
            "you have to approve fist"
        );

        UserInfo storage user = userInfo[msg.sender];
        // UserInfo memory user = userInfo[msg.sender];

        if (user.addr == address(0)) {
            user.addr = msg.sender;
            userList.push(msg.sender);
        }

        stakedNft.safeTransferFrom(
            msg.sender, 
            address(this), 
            stakedNftTokenId, 
            amount, 
            ""
        );

        lockReward(msg.sender);

        // user.amount = user.amount + amount * stakedNftValue;
        user.amount = user.amount.add(amount.mul(stakedNftValue));
        user.numOfstakedNft = user.numOfstakedNft.add(amount);
        user.lastDeposited = block.timestamp;

        emit Deposited(msg.sender, amount);

    }
    event Deposited(address indexed account, uint256 amount);

    function withdraw(uint amount) external {
        require(amount > 0, "invalid amount");
        require(
            stakedNft.balanceOf(address(this), stakedNftTokenId) >= amount,
            "insufficient balance"
        );

        UserInfo storage user = userInfo[msg.sender];

        stakedNft.safeTransferFrom(
            address(this), 
            msg.sender, 
            stakedNftTokenId, 
            amount, 
            ""
        );
        lockReward(msg.sender);

        // uint256 reward = pendingReward(msg.sender);
        // user.rewardLocked = user.rewardLocked.add(reward);
        user.numOfstakedNft = user.numOfstakedNft.sub(amount);
        user.amount = user.amount.sub(amount.mul(stakedNftValue));
        user.lastDeposited = block.timestamp;

    }

    function pendingReward(address account) public view returns (uint256 reward) {
        UserInfo memory user = userInfo[account];
        uint256 duration = block.timestamp.sub(user.lastDeposited);
        reward = user.amount.mul(apr).mul(duration).div(60*60*24*365).div(apr_denominator);
        reward = reward.add(user.rewardLocked);
    }

    function lockReward(address account) internal {
        UserInfo storage user = userInfo[account];
        uint256 reward = pendingReward(account);
        user.rewardLocked = user.rewardLocked.add(reward);
        user.lastDeposited = block.timestamp;
    }

    // function aaa(uint a, uint b) public pure returns (uint) {
    //     return a + b;
    // }

    function claim() external {
        uint256 reward = pendingReward(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        rewardToken.transfer(msg.sender, reward);

        user.rewardLocked = 0;
        user.lastDeposited = block.timestamp; 
    }



    function onERC1155Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*id*/
        uint256, /*value*/
        bytes calldata /*data*/
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address, /*from*/
        uint256[] calldata, /*ids*/
        uint256[] calldata, /*values*/
        bytes calldata /*data*/
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 /*interfaceId*/
    ) public view virtual override returns (bool) {
        return false;
    }


}
