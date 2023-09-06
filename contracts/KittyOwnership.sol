// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KittyBase.sol";

/// @title The facet of the CryptoKitties core contract that manages ownership, ERC-721 (draft) compliant.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the KittyCore contract documentation to understand how the various contract facets are arranged.
contract KittyOwnership is KittyBase {

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Kitty.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId kitten id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        //return kittyIndexToOwner[_tokenId] == _claimant;
        address owner = ownerOf(_tokenId);
        return (_claimant == owner);
    }

    /// @dev Transfers a kitty owned by this contract to the specified address.
    ///  Used to rescue lost kitties. (There is no "proper" flow where this contract
    ///  should be the owner of any Kitty. This function exists for us to reassign
    ///  the ownership of Kitties that users may have accidentally sent to our address.)
    /// @param _kittyId - ID of kitty
    /// @param _recipient - Address to send the cat to
    function rescueLostKitty(uint256 _kittyId, address _recipient) public onlyCOO whenNotPaused {
        require(_owns(address(this), _kittyId));
        _transfer(address(this), _recipient, _kittyId);
    }

    // ===== ERC721 함수로 대체 =====
    // _approvedFor() 삭제
    // _approve() 삭제
    // _balanceOf() 삭제
    // transfer() 삭제 -> safeTransferFrom()으로 대체
    // approve() 삭제 
    // transferFrom() 삭제
    // totalSupply() 삭제
    // ownerOf() 삭제
    // tokensOfOwnerByIndex() 삭제
}
