// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

contract AcademicDiploma is ERC721 {
    using EnumerableSet for EnumerableSet.UintSet;

    struct Diploma {
        uint256 id;
        string ownerName;
        uint256 issueDate;
        mapping (string => string) metadata;
        EnumerableSet.UintSet soulboundTokens;
    }

    address owner;
    Diploma[] diplomas;

    constructor() ERC721("AcademicDiploma", "ADP") {
        owner = msg.sender;
    }

   function issueDiploma(address _owner, string memory _ownerName, string[] memory _metadata, uint256[] memory _soulboundTokens) public {
    require(msg.sender == owner, "You do not have permission to issue diplomas.");
    uint256 diplomaId = diplomas.length + 1;
    uint256 issueDate = block.timestamp;
    Diploma storage newDiploma = diplomas.push();
    newDiploma.id = diplomaId;
    newDiploma.ownerName = _ownerName;
    newDiploma.issueDate = issueDate;
    for(uint i=0; i<_metadata.length; i+=2) {
        newDiploma.metadata[_metadata[i]] = _metadata[i+1];
    }
    for(uint i=0; i<_soulboundTokens.length; i++) {
        newDiploma.soulboundTokens.add(_soulboundTokens[i]);
        require(this.ownerOf(_soulboundTokens[i]) == _owner, "You can only soulbind tokens that you own.");
        this.transferFrom(_owner, address(this), _soulboundTokens[i]);
    }
    _safeMint(_owner, diplomaId);
}


    function soulboundTokens(uint256 _diplomaId) public view returns (uint256[] memory) {
        require(_exists(_diplomaId), "This diploma does not exist.");
        Diploma storage diploma = diplomas[_diplomaId-1];
        uint256[] memory result = new uint256[](diploma.soulboundTokens.length());
        for(uint i=0; i<diploma.soulboundTokens.length(); i++) {
            result[i] = diploma.soulboundTokens.at(i);
        }
        return result;
    }

  }
