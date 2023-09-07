// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KittyMinting.sol";

contract KittyCore is KittyMinting {

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    constructor() {
        _pause();

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;

        // start with the mythical kitten 0 - so we don't have generation-0 parent issues
        _createKitty(0, 0, 0, type(uint256).max, address(0x000000000000000000000000000000000000dEaD));
    }

    function setNewAddress(address _v2Address) public onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    receive() external payable {
        require(
            msg.sender == address(saleAuction)
        );
    }

    function getKitty(uint256 _id)
        public
        view
        returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    ) {
        Kitty storage kit = kitties[_id];

        isGestating = (kit.siringWithId != 0);
        isReady = (kit.cooldownEndTime <= block.timestamp);
        cooldownIndex = uint256(kit.cooldownIndex);
        nextActionAt = uint256(kit.cooldownEndTime);
        siringWithId = uint256(kit.siringWithId);
        birthTime = uint256(kit.birthTime);
        matronId = uint256(kit.matronId);
        sireId = uint256(kit.sireId);
        generation = uint256(kit.generation);
        genes = kit.genes;
    }

    // 부모함수와 이름이 같기 때문에 override
    function unpause() public override virtual onlyCEO {
        require(address(saleAuction) != address(0));
        require(newContractAddress == address(0));

        super.unpause();
    }
}
