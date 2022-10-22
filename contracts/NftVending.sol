// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";


contract NftVending is Ownable, IERC1155Receiver {


    function initialize(
        address _nftContract,
        uint256 _nftTokenId,
        uint256 _sellPrice
    ) external onlyOwner {

    }

    function buyNFT(uint8 _amount) external {

    }

    function sellNFT(uint8 _amount) external {

    }

    function withdrawSales() external onlyOwner {

    }

    function updateSellPrice(uint256 _price) external onlyOwner {

    }

    function withdrawNFT(uint8 _amount) external onlyOwner {

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