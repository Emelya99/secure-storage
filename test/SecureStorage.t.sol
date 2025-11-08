// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {SecureStorage} from "../src/SecureStorage.sol";

contract SecureStorageTest is Test {
    SecureStorage public secureStorage;

    uint constant VALUE = 120;
    address tester = makeAddr("tester");
    address attacker = makeAddr("attacker");

    event AddRecord(address _address);
    event ResetRecord(address _address);
    
    function setUp() public {
        secureStorage = new SecureStorage();
    }

    // Check version from getVersion()
    function test_Version() public view {
        assertEq(secureStorage.getVersion(), 'v1');
    }

    // Add new record, success case
    function test_StoreRecord_EmitsAddRecord() public {
        vm.expectEmit();
        emit AddRecord(tester);

        _storeRecord(tester);
    
        (uint256 value, address createdBy) = secureStorage.records(tester);

        assertEq(VALUE, value);
        assertEq(tester, createdBy);
    }

    // Add new record, fail cases 
    function test_StoreRecordRevert() public {
        vm.expectRevert();
        secureStorage.store(1001);

        vm.expectRevert(bytes("Must be > 0"));
        secureStorage.store(0);
    }

    // Get Record, success case
    function test_GetRecord() public {
        _storeRecord(tester);

        vm.prank(tester);
        uint256 value = secureStorage.getMyRecord();

        assertEq(VALUE, value);
    }

    // Get Record, fail cases with no record yet
    function test_GetRecordRevert() public {
        vm.expectRevert(bytes("You don't have records yet!"));
        secureStorage.getMyRecord();
    }

    // Reset Record, success case
    function test_ResetRecord_EmitsResetRecord() public {
        _storeRecord(tester);
        
        vm.expectEmit();
        emit ResetRecord(tester);

        secureStorage.reset(tester);
        
        (uint256 valueAfter, address createdByAfter) = secureStorage.records(tester);
        assertEq(valueAfter, 0);
        assertEq(createdByAfter, address(0));
    }

    // Reset Record, all fail cases
    function test_ResetRecordRevert() public {
        vm.expectRevert(bytes("You don't have records yet!"));
        secureStorage.reset(tester);

        _storeRecord(tester);

        vm.expectRevert(bytes("You are not an owner!"));
        vm.prank(attacker);
        secureStorage.reset(tester);
    }

    // Private function for store value
    function _storeRecord (address _address) private {
        vm.prank(_address);
        secureStorage.store(VALUE);
    }
}