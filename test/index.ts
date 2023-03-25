import { expect } from "chai";
import { ethers } from "hardhat";
import { generateTree } from "../scripts/merkletree"
import { keccak256 } from 'ethers/lib/utils'


describe("Whitelisting testing", function () {
  it("Whitelisted address minting", async function () {
    const tree = await generateTree();
    const root = tree.getHexRoot();
    const [addr,addr2] = await ethers.getSigners();
    const hashedAddr = keccak256(addr.address)
    const proof = tree.getHexProof(hashedAddr)
    const Merkle = await ethers.getContractFactory("whiteListing");
    const merkle = await Merkle.deploy();
    await merkle.initialize(root,"WHITE","WHT");

    await merkle.connect(addr).safeMint(addr.address,"test_URI",proof);
    expect(await merkle.balanceOf(addr.address)).to.be.eq(1);

  })
  it("non whitelisted address failing to mint", async function () {
    const tree = await generateTree();
    const root = tree.getHexRoot();
    const [addr,addr2] = await ethers.getSigners();
    const hashedAddr = keccak256(addr.address)
    const proof = tree.getHexProof(hashedAddr)
    const Merkle = await ethers.getContractFactory("whiteListing");
    const merkle = await Merkle.deploy();
    await merkle.initialize(root,"WHITE","WHT");
 
    await expect(merkle.connect(addr2).safeMint(addr.address,"test_URI",proof)).to.be.revertedWith("AddressIsNotAllowed");

  })
})
