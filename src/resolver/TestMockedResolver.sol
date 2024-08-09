// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
//OBS: Temporary mocked file to deploy a resolver
import "./Resolver.sol";

contract TestMockedResolver is Resolver {
    constructor(IEAS eas) Resolver(eas) {}

    mapping(string => bool) public allowedAttestationTitles;

    function setAttestationTitle(string memory title, bool allowed) public {
        allowedAttestationTitles[title] = allowed;
    }

    function attest(Attestation calldata /*attestation*/) external payable override returns (bool) {
        return true;
    }

    function revoke(Attestation calldata /*attestation*/) external payable override returns (bool) {
        return true;
    }

    function onAttest(Attestation calldata /*attestation*/, uint256 /*value*/) internal pure override returns (bool) {
        return true;
    }

    function onRevoke(Attestation calldata /*attestation*/, uint256 /*value*/) internal pure override returns (bool) {
        return true;
    }
}
