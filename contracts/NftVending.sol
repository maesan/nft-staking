// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NftVending is Ownable, IERC1155Receiver {

    address public nftContract;
    uint256 public nftTokenId;
    address public token;
    uint256 public sellPrice;

    bool public initialized;

    event Initialized(
        address _nftContract,
        uint256 _nftTokenId,
        address _token,
        uint256 _sellPrice
    );

    function initialize(
        address _nftContract,
        uint256 _nftTokenId,
        address _token,
        uint256 _sellPrice
    ) external onlyOwner {
        require(!initialized, "already initialized");
        require(_nftContract != address(0), "invalid NFT address");
        require(_token != address(0), "invalid token address");
        require(_sellPrice > 0, "invalid sell price");

        nftContract = _nftContract;
        nftTokenId = _nftTokenId;
        token = _token;
        sellPrice = _sellPrice;

        initialized = true;

        emit Initialized(_nftContract, _nftTokenId, _token, _sellPrice);

    }

    function getNFTInfo() public view returns (
        address _nftContract, uint256 _nftTokenId, uint256 _sellPrice) {
        
        _nftContract = nftContract;
        _nftTokenId = nftTokenId;
        _sellPrice = sellPrice;
    }

    // function add(uint a, uint b) public pure returns (uint) {
    //     return a + b;
    // }

    function buyNFT(uint8 _amount) external {
        require(_amount > 0, "invalid amount");
        require(
            _amount <= IERC1155(nftContract).balanceOf(address(this), nftTokenId),
            "no stocks"
        );

        uint256 price = _amount * sellPrice;
        require(price <= IERC20(token).balanceOf(msg.sender),
            "insufficient balance"
        );
        // transfer token from user to contract
        // user have to approve before calling this function
        require(
            price <= IERC20(token).allowance(msg.sender, address(this)),
            "not approved yet"
        );
        IERC20(token).transferFrom(
            msg.sender,
            address(this),
            price
        );

        // transfer NFT from this contract to user
        IERC1155(nftContract).safeTransferFrom(
            address(this), 
            msg.sender, 
            nftTokenId, 
            _amount, 
            ""
        );

        emit BuyNFT(msg.sender, _amount);

    }
    event BuyNFT(address indexed account, uint8 amount);

    function sellNFT(uint8 _amount) external {
        require(_amount > 0, "invalid amount");
        require(
            _amount <= IERC1155(nftContract).balanceOf(msg.sender, nftTokenId),
            "insufficient balance"
        );

        uint256 price = _amount * sellPrice;
        require(price <= IERC20(token).balanceOf(address(this)),
            "insufficient balance"
        );

        IERC20(token).transfer(
            msg.sender,
            price
        );

        // transfer NFT from user to contract
        require(
            IERC1155(nftContract).isApprovedForAll(msg.sender, address(this)),
            "not approved yet"
        );
        IERC1155(nftContract).safeTransferFrom(
            msg.sender, 
            address(this), 
            nftTokenId, 
            _amount, 
            ""
        );

        emit SellNFT(msg.sender, _amount);
    }
    event SellNFT(address indexed account, uint8 amount);

    function withdrawSales() external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(
            balance > 0, 
            "not enough token"
        );

        IERC20(token).transfer(msg.sender, balance);

        emit WithdrawToken(balance);

    }
    event WithdrawToken(uint256 amount);


    function withdrawNFT(uint8 _amount) external onlyOwner {
        uint256 balance = IERC1155(nftContract).balanceOf(address(this), nftTokenId);
        require(balance >= _amount, "not enough NFT");

        IERC1155(nftContract).safeTransferFrom(
            address(this), 
            msg.sender, 
            nftTokenId, 
            _amount, 
            ""
        );
        emit WithdrawNFT(_amount);
    }
    event WithdrawNFT(uint8 amount);

    function updateSellPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "invalid price");
        sellPrice = _price;
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