// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KittyAccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract KittyBase is KittyAccessControl, ERC721Enumerable {
    string _name = "CryptoKitties";
    string _symbol = "CK";

    constructor() ERC721(_name, _symbol) {}

    event Birth(address indexed owner, uint256 kittyId, uint256 matronId, uint256 sireId, uint256 genes);

    struct Kitty {
        // type이 작아지는 순서로 배치한것은 가스비 때문임. 가스비를 컴팩트 시키는 것
        uint256 genes;
        uint64 birthTime;
        uint64 cooldownEndTime;
        uint32 matronId;
        uint32 sireId;
        uint32 siringWithId;
        uint16 cooldownIndex;
        uint16 generation;
    }

    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];

    Kitty[] kitties;

    mapping (uint256 => address) public sireAllowedToAddress;

    function _transfer(address _from, address _to, uint256 _tokenId) override internal virtual {
        if (_from != address(0)) {
            delete sireAllowedToAddress[_tokenId];
        }
        super._transfer(_from, _to, _tokenId);
    }


    /// @param _matronId The kitty ID of the matron of this cat (zero for gen0)
    /// @param _sireId The kitty ID of the sire of this cat (zero for gen0)
    /// @param _generation The generation number of this cat, must be computed by caller.
    /// @param _genes The kitty's genetic code.
    /// @param _owner The inital owner of this cat, must be non-zero (except for the unKitty, ID 0)
    function _createKitty(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    )
        internal
        returns (uint)
    {
        require(_matronId <= 4294967295);
        require(_sireId <= 4294967295);
        require(_generation <= 65535);

        Kitty memory _kitty = Kitty({
            genes: _genes,
            birthTime: uint64(block.timestamp),
            cooldownEndTime: 0,
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            siringWithId: 0,
            cooldownIndex: 0,
            generation: uint16(_generation)
        });
        // 솔리디티 버전이 업그레이드 되면서, push()에 return값이 삭제됨
        kitties.push(_kitty);
        uint256 newKittenId = kitties.length - 1;

        require(newKittenId <= 4294967295);

        emit Birth(
            _owner,
            newKittenId,
            uint256(_kitty.matronId),
            uint256(_kitty.sireId),
            _kitty.genes
        );

        _safeMint(_owner, newKittenId);

        return newKittenId;
    }
}
