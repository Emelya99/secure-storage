// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

contract SecureStorage {
    address public owner;
    
    struct Record {
        uint256 value;
        address createdBy;
    }
    
    mapping (address => Record) public records;

    string private version = "v1";

    event AddRecord(address _address);
    event ResetRecord(address _address);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not an owner!");
        _;
    }

    modifier onlyExistingRecord(address _address) {
        if (records[_address].value == 0) {
            revert("You don't have records yet!");
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function getVersion() external view returns ( string memory ) {
        return version;
    }

    function store (uint256 _value) external {
        require(_value > 0, "Must be > 0");
        assert(_value <= 1000);
        records[msg.sender].value = _value;
        records[msg.sender].createdBy = msg.sender;
        emit AddRecord(msg.sender);
    }

    function getMyRecord () public view onlyExistingRecord(msg.sender) returns ( uint256 ) {
        return records[msg.sender].value;
    }

    function reset (address _user) external onlyOwner onlyExistingRecord(_user) {
        delete records[_user];
        emit ResetRecord(_user);
    }
}