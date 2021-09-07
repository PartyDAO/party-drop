// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

interface IPartyBid {
    function totalContributed(address) external view returns (uint256);
}

contract PartyDrop is ERC721Burnable, Ownable {
    uint256 lastMintedId;
    string public imageURI;
    string public description;
    IPartyBid public party;
    mapping(address => bool) public minted;
    bool public locked;

    constructor(
        string memory nftName,
        string memory nftSymbol,
        string memory _description,
        string memory _imageURI,
        address _partyAddress
    ) public ERC721(nftName, nftSymbol) {
        imageURI = _imageURI;
        party = IPartyBid(_partyAddress);
        description = _description;
    }

    function claim() public {
        require(
            party.totalContributed(msg.sender) > 0,
            "didn't contribute to PartyBid"
        );
        require(minted[msg.sender] == false, "NFT already minted");
        minted[msg.sender] = true;

        uint256 newTokenId = lastMintedId + 1;
        lastMintedId = newTokenId;
        _safeMint(msg.sender, newTokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "must exist");
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name(),
                        " #",
                        toString(tokenId),
                        '", "description": "',
                        description,
                        '", "image": "',
                        imageURI,
                        '"}'
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function adminChangeImageURI(string memory _imageURI) public onlyOwner {
        require(!locked, "NFT locked");
        imageURI = _imageURI;
    }

    function adminChangeDescription(string memory _description)
        public
        onlyOwner
    {
        require(!locked, "NFT locked");
        description = _description;
    }

    function lock() public onlyOwner {
        locked = true;
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
