// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CertificateVerifier {
    address public admin;
    mapping(bytes32 => bool) private certificateHashes;

    event CertificateAdded(bytes32 indexed hash, address indexed addedBy);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addCertificate(bytes32 hash) external onlyAdmin {
        require(hash != bytes32(0), "Invalid hash");
        require(!certificateHashes[hash], "Certificate already exists");

        certificateHashes[hash] = true;
        emit CertificateAdded(hash, msg.sender);
    }

    function verifyCertificate(bytes32 hash) external view returns (bool) {
        return certificateHashes[hash];
    }
}