async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("deployer: ", deployer.address);
    const contract = await ethers.getContractFactory("NftVending");
    const deployed = await contract.deploy();
    console.log("contract address: ", deployed.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });


