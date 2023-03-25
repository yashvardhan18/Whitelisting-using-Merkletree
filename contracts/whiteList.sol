pragma solidity >=0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract whiteListing is ERC721URIStorageUpgradeable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenId;
    bytes32 public root;
    mapping(address => bool) private whitelist;
    mapping(address => bool) private hasMinted;
    error zeroAddressAdded();
    error AddressIsNotAllowed();
    event NFTDetails(address owner, uint tokenId, string uri);

    function initialize(
        bytes32 _root,
        string memory _name,
        string memory _symbol
    ) external initializer {
        __ERC721_init_unchained(_name, _symbol);
        __ERC721URIStorage_init_unchained();
        root = _root;
    }

    function safeMint(address to,string memory _uri ,bytes32[] memory _proof) external {
        if (to == address(0)) {
            revert zeroAddressAdded();
        }
        if (!verify(_proof, keccak256(abi.encodePacked(msg.sender))) && !whitelist[msg.sender]) {
            revert AddressIsNotAllowed();
        }
        uint id = tokenId.current();
        tokenId.increment();
        hasMinted[msg.sender] = true;
        _safeMint(to, id);
        _setTokenURI(id,_uri);
        emit NFTDetails(to, id, _uri);
    }

    function whiteListStatus(address _newUser, bool status) external {
        if (_newUser == address(0)) {
            revert zeroAddressAdded();
        }

        whitelist[_newUser] = status;
    }

    function verify(
        bytes32[] memory _proof,
        bytes32 leaf
    ) private view returns (bool) {
        return
            MerkleProof.verify(_proof, root, leaf);
    }
}
