// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HealthInsurance {
    struct User {
        address userAddress;
        string name;
        uint age;
        string email;
        bool isRegistered;
    }

    struct Scheme {
        uint schemeId;
        string name;
        string details;
        uint256 premium;
        uint256 coverage;
    }

    struct Policy {
        uint policyId;
        address owner;
        uint schemeId;
        uint256 premium;
        uint256 coverage;
    }

    enum ClaimStatus { Filed, Verified, Approved, Rejected }

    struct Claim {
        uint claimId;
        uint policyId;
        address claimant;
        string description;
        ClaimStatus status;
        uint256 amount;
    }

    struct PaymentRecord {
        uint policyId;
        address payer;
        uint256 amount;
        uint256 timestamp;
    }

    uint public schemeCount;
    uint public policyCount;
    uint public claimCount;
    mapping(address => User) public users;
    mapping(uint => Scheme) public schemes;
    mapping(uint => Policy) public policies;
    mapping(uint => Claim) public claims;
    mapping(uint => PaymentRecord[]) public paymentRecords;

    // User Management
    function registerUser(string memory name, uint age, string memory email) public {
        users[msg.sender] = User(msg.sender, name, age, email, true);
    }

    function isUserRegistered(address userAddress) public view returns (bool) {
        return users[userAddress].isRegistered;
    }

    function getUser(address userAddress) public view returns (User memory) {
        return users[userAddress];
    }

    function updateUser(string memory name, uint age, string memory email) public {
        User storage user = users[msg.sender];
        user.name = name;
        user.age = age;
        user.email = email;
    }

    // Scheme Management
    function addScheme(string memory name, string memory details, uint256 premium, uint256 coverage) public {
        schemeCount++;
        schemes[schemeCount] = Scheme(schemeCount, name, details, premium, coverage);
    }

    function getScheme(uint schemeId) public view returns (Scheme memory) {
        return schemes[schemeId];
    }

    function updateScheme(uint schemeId, string memory name, string memory details, uint256 premium, uint256 coverage) public {
        Scheme storage scheme = schemes[schemeId];
        scheme.name = name;
        scheme.details = details;
        scheme.premium = premium;
        scheme.coverage = coverage;
    }

    function deleteScheme(uint schemeId) public {
        delete schemes[schemeId];
    }

    function schemeExists(uint schemeId) public view returns (bool) {
        return schemes[schemeId].schemeId == schemeId;
    }

    // Insurance Policy Management
    function createPolicy(uint schemeId) public {
        require(isUserRegistered(msg.sender), "User not registered");
        require(schemeExists(schemeId), "Scheme does not exist");

        policyCount++;
        Scheme memory scheme = getScheme(schemeId);
        policies[policyCount] = Policy(policyCount, msg.sender, schemeId, scheme.premium, scheme.coverage);
    }

    function getPolicy(uint policyId) public view returns (Policy memory) {
        return policies[policyId];
    }

    function updatePolicy(uint policyId, uint schemeId) public {
        Policy storage policy = policies[policyId];
        require(policy.owner == msg.sender, "Not authorized");

        require(schemeExists(schemeId), "Scheme does not exist");
        Scheme memory scheme = getScheme(schemeId);

        policy.schemeId = schemeId;
        policy.premium = scheme.premium;
        policy.coverage = scheme.coverage;
    }

    function deletePolicy(uint policyId) public {
        Policy storage policy = policies[policyId];
        require(policy.owner == msg.sender, "Not authorized");
        delete policies[policyId];
    }

    // Payment Management
    function payPremium(uint policyId) public payable {
        require(msg.value > 0, "Payment amount should be greater than 0");
        Policy memory policy = getPolicy(policyId);
        require(policy.owner == msg.sender, "Not authorized");

        paymentRecords[policyId].push(PaymentRecord(policyId, msg.sender, msg.value, block.timestamp));
    }

    function getPayments(uint policyId) public view returns (PaymentRecord[] memory) {
        return paymentRecords[policyId];
    }

    // Claims Management
    function fileClaim(uint policyId, string memory description, uint256 amount) public {
        Policy memory policy = getPolicy(policyId);
        require(policy.owner == msg.sender, "Not authorized");

        claimCount++;
        claims[claimCount] = Claim(claimCount, policyId, msg.sender, description, ClaimStatus.Filed, amount);
    }

    function verifyClaim(uint claimId) public {
        Claim storage claim = claims[claimId];
        require(claim.status == ClaimStatus.Filed, "Claim is not filed");
        claim.status = ClaimStatus.Verified;
    }

    function approveClaim(uint claimId) public {
        Claim storage claim = claims[claimId];
        require(claim.status == ClaimStatus.Verified, "Claim is not verified");
        claim.status = ClaimStatus.Approved;
    }

    function rejectClaim(uint claimId) public {
        Claim storage claim = claims[claimId];
        require(claim.status == ClaimStatus.Verified, "Claim is not verified");
        claim.status = ClaimStatus.Rejected;
    }

    function getClaim(uint claimId) public view returns (Claim memory) {
        return claims[claimId];
    }
}
