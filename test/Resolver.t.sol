// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Test, console2 } from "forge-std/src/Test.sol";
import { Resolver } from "../src/resolver/Resolver.sol";
import { IResolver } from "../src/interfaces/IResolver.sol";
import { ISchemaRegistry } from "../src/interfaces/ISchemaRegistry.sol";
import { IEAS } from "../src/interfaces/IEAS.sol";
import { TestMockedResolver } from "../src/resolver/TestMockedResolver.sol";

contract RegistryTest is Test {
  IEAS eas = IEAS(0xC2679fBD37d54388Ce493F1DB75320D236e1815e);
  ISchemaRegistry schemaRegistry = ISchemaRegistry(0x0a7E2Ff54e76B8E6659aedc9103FB21c038050D0);
  // IResolver resolver;
  TestMockedResolver testMockedResolver;

 address deployer = address(1);
    address user = address(2);

    function setUp() public {
        vm.label(deployer, "deployer");
        vm.label(user, "user");
        vm.startPrank(deployer);
        testMockedResolver = new TestMockedResolver(eas);
        vm.stopPrank();
    }

    function testSetAttestationTitle() public {
        vm.startPrank(deployer);
        string memory title = "Test Title";
        testMockedResolver.setAttestationTitle(title, true);
        assertTrue(testMockedResolver.allowedAttestationTitles(title));
        vm.stopPrank();
    }

    function testAttest() public {
        vm.startPrank(user);
        bytes32 schemaId = 0x0000000000000000000000000000000000000000000000000000000000000000; // Replace with actual schema ID
        bytes memory data = abi.encode("Test data");
        uint256 expirationTime = block.timestamp + 1 days;

        bytes32 attestationId = testMockedResolver.attest(schemaId, data, expirationTime);
        assertTrue(attestationId != bytes32(0));
        vm.stopPrank();
    }

    function testMultiAttest() public {
        vm.startPrank(user);
        bytes32[] memory schemaIds = new bytes32[](2);
        schemaIds[0] = 0x0000000000000000000000000000000000000000000000000000000000000000; // Replace with actual schema IDs
        schemaIds[1] = 0x0000000000000000000000000000000000000000000000000000000000000001;

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encode("Test data 1");
        data[1] = abi.encode("Test data 2");

        uint256[] memory expirationTimes = new uint256[](2);
        expirationTimes[0] = block.timestamp + 1 days;
        expirationTimes[1] = block.timestamp + 2 days;

        bytes32[] memory attestationIds = testMockedResolver.multiAttest(schemaIds, data, expirationTimes);
        assertEq(attestationIds.length, 2);
        assertTrue(attestationIds[0] != bytes32(0));
        assertTrue(attestationIds[1] != bytes32(0));
        vm.stopPrank();
    }
}

