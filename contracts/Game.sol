// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Game is ERC721, Ownable {

    uint256 private _tokenIdCounter;

    struct Player {
        bool registered;
        uint256 score;
    }

    struct Asset {
        string name;
        uint256 rarity;
        address owner;
    }

    mapping(address => Player) public players;
    mapping(uint256 => Asset) public assets;

    event PlayerRegistered(address indexed player);
    event AssetMinted(uint256 indexed tokenId, address indexed to, string name, uint256 rarity);
    event ScoreUpdated(address indexed player, uint256 newScore);
    event AssetTransferred(uint256 indexed tokenId, address indexed from, address indexed to);

    constructor() ERC721("GameAsset", "GAST") Ownable(msg.sender) {}

    modifier onlyRegistered(address addr) {
        require(players[addr].registered, "Not registered");
        _;
    }

    function registerPlayer() external {
        require(!players[msg.sender].registered, "Already registered");
        players[msg.sender] = Player(true, 0);
        emit PlayerRegistered(msg.sender);
    }

    function mintAsset(
        address to,
        string calldata name,
        uint256 rarity
    ) external onlyOwner onlyRegistered(to) returns (uint256) {
        require(rarity >= 1 && rarity <= 3, "Invalid rarity");

        _tokenIdCounter++;
        uint256 newId = _tokenIdCounter;

        _safeMint(to, newId);
        assets[newId] = Asset(name, rarity, to);

        emit AssetMinted(newId, to, name, rarity);
        return newId;
    }

    function updateScore(address player, uint256 score) external onlyOwner onlyRegistered(player) {
        players[player].score = score;
        emit ScoreUpdated(player, score);
    }

    function transferAsset(uint256 tokenId, address to) external onlyRegistered(to) {
        require(ownerOf(tokenId) == msg.sender, "Not asset owner");
        _transfer(msg.sender, to, tokenId);
        assets[tokenId].owner = to;
        emit AssetTransferred(tokenId, msg.sender, to);
    }

    function getPlayer(address addr) external view returns (bool registered, uint256 score) {
        Player memory p = players[addr];
        return (p.registered, p.score);
    }

    function getAsset(uint256 tokenId) external view returns (string memory name, uint256 rarity, address owner) {
        Asset memory a = assets[tokenId];
        return (a.name, a.rarity, a.owner);
    }
}