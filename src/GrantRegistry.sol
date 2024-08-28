// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IGrantRegistry } from "./interfaces/IGrantRegistry.sol";
import { IEASResolver } from "./interfaces/IEASResolver.sol";

/// @title Grant Registry
/// @author KarmaGap | 0xneves.eth
/// @notice Registry of grant applications.
/// The Grant Programs can issue and manage grants.
contract GrantRegistry is IGrantRegistry, Ownable {
  /// The proxy address of the Karma EAS Resolver that stored the project owner on-chain.
  address public immutable projectResolver = 0x28BE0b0515be8BB8822aF1467A6613795E74717b;
  /// The global EAS contract.
  address public immutable eas = 0xbD75f629A22Dc1ceD33dDA0b68c546A1c035c458;

  /// Map the grant UID to the grant data
  mapping(bytes32 => Grant) private _grants;

  constructor() Ownable(msg.sender) {}

  /// @inheritdoc IGrantRegistry
  function batchRegister(
    bytes32[] calldata grantUIDs,
    uint256[] calldata grantProgramUIDs,
    uint256[] calldata statuses
  ) external onlyOwner {
    if (grantUIDs.length != grantProgramUIDs.length || grantUIDs.length != statuses.length)
      revert InvalidArrayLength();
    for (uint256 i = 0; i < grantUIDs.length; i++) {
      register(grantUIDs[i], grantProgramUIDs[i], statuses[i]);
    }
  }

  /// @inheritdoc IGrantRegistry
  function register(bytes32 grantUID, uint256 grantProgramUID, uint256 status) public onlyOwner {
    if (_grants[grantUID].grantee != address(0)) revert GrantAlreadyExists();

    // checks if the grantee exists on the Project Resolver
    IEASResolver.Attestation memory attestation = IEASResolver(eas).getAttestation(grantUID);
    address grantee = IEASResolver(projectResolver).projectOwner(attestation.refUID);
    if (grantee == address(0)) revert InvalidGrantOwner();

    _grants[grantUID] = Grant(grantee, grantProgramUID, Status(status));

    emit GrantRegistered(grantUID, grantProgramUID, grantee, status);
  }

  /// @inheritdoc IGrantRegistry
  function update(bytes32 grantUID, uint256 status) external onlyOwner {
    _grantExists(grantUID);
    _grants[grantUID].status = Status(status);
    emit GrantUpdated(grantUID, status);
  }

  /// @inheritdoc IGrantRegistry
  function remove(bytes32 grantUID) external onlyOwner {
    _grantExists(grantUID);
    delete _grants[grantUID];
    emit GrantDeleted(grantUID);
  }

  /// @dev Checks if the grant exists.
  function _grantExists(bytes32 grantUID) internal view {
    if (_grants[grantUID].grantee == address(0)) revert GrantNonExistent();
  }

  /// @inheritdoc IGrantRegistry
  function getGrantee(bytes32 grantUID) public view returns (address) {
    _grantExists(grantUID);
    return _grants[grantUID].grantee;
  }

  /// @inheritdoc IGrantRegistry
  function getGrantProgramUID(bytes32 grantUID) public view returns (uint256) {
    _grantExists(grantUID);
    return _grants[grantUID].grantProgramUID;
  }

  /// @inheritdoc IGrantRegistry
  function getStatus(bytes32 grantUID) public view returns (Status) {
    _grantExists(grantUID);
    return _grants[grantUID].status;
  }

  /// @inheritdoc IGrantRegistry
  function getGrant(bytes32 grantUID) public view returns (Grant memory) {
    _grantExists(grantUID);
    return _grants[grantUID];
  }
}
