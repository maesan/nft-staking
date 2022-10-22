const hre = require('hardhat');

const NftVendingContractAddress = '0x45104F64abb46E75d74d623FB1Be470D56B96Fde';
const vendingAbi = require('../abi/NftVending.json');

const MaeTokenAddress = '0xD11689f04A861e329fbF13bd65d6Eb9b286B42B0';
const ERC20Abi = require('../abi/IERC20.json');

const MaeNftAddress = '0xF4c9380bed5a49ea99fa6f8ad34f0C1Ac59f72Ca';
const MaeTokenId = 1122;
const ERC1155Abi = require('../abi/IERC1155.json');


async function main() {
    const [account] = await ethers.getSigners();
    const vending = new hre.ethers.Contract(NftVendingContractAddress, vendingAbi, account);
    const token = new hre.ethers.Contract(MaeTokenAddress, ERC20Abi, account);
    const nft = new hre.ethers.Contract(MaeNftAddress, ERC1155Abi, account);

    // await token.approve(NftVendingContractAddress, BigInt(10000000000000000000000));
    res = await vending.buyNFT(1);
    // await nft.setApprovalForAll(
    //     NftVendingContractAddress,
    //     true
    // );
    // res = await vending.sellNFT(1);
    // res = await vending.updateSellPrice(BigInt(10000000000000000000));

    // await vending.withdrawNFT(2);
    // res = await vending.withdrawSales();
    console.log(res);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });


