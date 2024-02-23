// SPDX-License-Identifier: MIT 
pragma solidity >=0.4.22;

pragma experimental ABIEncoderV2; // Enable experimental ABI encoder

contract TenderAllocator {
    
    struct UserDetails {
        string name;
        string email;
        uint256 phoneNumber;
        mapping(uint256 => Tender) tenders; // Map to store tender details by tender ID
        uint256[] tenderIds; // Array to store IDs of tenders associated with this user
    }
    
    struct Tender {
        
        string tenderName;
        string tenderAmount;
        address tenderIssuer;
    }

    uint public Usercount;
    uint256 public tenderCount;
    string[] public tenderNames;
    string[] public tenderAmounts;
    address[] public tenderIssuers;
    
    
    mapping(address => UserDetails) public users; // Map to store user details by user address
    
    //event UserRegistered(address userAddress, string name, string email, uint256 phoneNumber);
    //event TenderAdded(address userAddress, uint256 tenderId, string tenderName, uint256 tenderAmount, address tenderIssuer);
    
    function registerUser(string memory _name, string memory _email, uint256 _phoneNumber) public {
        Usercount++;
        users[msg.sender].name = _name;
        users[msg.sender].email = _email;
        users[msg.sender].phoneNumber = _phoneNumber;
        
        //emit UserRegistered(msg.sender, _name, _email, _phoneNumber);
    }
    
    function addTender(uint256 _tenderId, string memory _tenderName, string memory _tenderAmount) public {
        require(bytes(_tenderName).length > 0, "Tender name must not be empty");
        require(bytes(_tenderAmount).length > 0, "Tender amount must not be empty");
        
        users[msg.sender].tenders[_tenderId] = Tender(_tenderName, _tenderAmount, msg.sender);
        users[msg.sender].tenderIds.push(_tenderId);
        getAllTendersForUser();
        
        //emit TenderAdded(msg.sender, _tenderId, _tenderName, _tenderAmount, msg.sender);
    }
    
    function getUserTenderCount(address _userAddress) public view returns (uint256) {
        return users[_userAddress].tenderIds.length;
    }
    
    function getTenderDetails(address _userAddress, uint256 _tenderId) public view returns (string memory, string memory, address) {
        return (
            users[_userAddress].tenders[_tenderId].tenderName,
            users[_userAddress].tenders[_tenderId].tenderAmount,
            users[_userAddress].tenders[_tenderId].tenderIssuer
        );
    }
    
    function getAllTendersForUser() public {
        uint256 userTenderCount = getUserTenderCount(msg.sender);
        tenderCount = userTenderCount;
        tenderNames = new string[](userTenderCount);
        tenderAmounts = new string[](userTenderCount);
        tenderIssuers = new address[](userTenderCount);
       
        for (uint256 i = 0; i < userTenderCount; i++) {
            uint256 tenderId = users[msg.sender].tenderIds[i];
            Tender memory tender = users[msg.sender].tenders[tenderId];
            tenderNames[i] = tender.tenderName;
            tenderAmounts[i] = tender.tenderAmount;
            tenderIssuers[i] = tender.tenderIssuer;
        }
    }

    // Getter functions for tender details
    function getTenderNames() public view returns (string[] memory) {
        return tenderNames;
    }

    function getTenderAmounts() public view returns (string[] memory) {
        return tenderAmounts;
    }

    function getTenderIssuers() public view returns (address[] memory) {
        return tenderIssuers;
    }
    function getAllUsersTenderDetails() public view returns (string[][] memory, string[][] memory, address[][] memory) {
    uint256 totalUserTenders = 0;
    for (uint256 i = 0; i < Usercount; i++) {
        totalUserTenders += getUserTenderCount(address(uint160(uint(keccak256(abi.encodePacked(address(this), i))))));
    }

    string[][] memory allTenderNames = new string[][](totalUserTenders);
    string[][] memory allTenderAmounts = new string[][](totalUserTenders);
    address[][] memory allTenderIssuers = new address[][](totalUserTenders);

    uint256 currentIndex = 0;
    for (uint256 j = 0; j < Usercount; j++) {
        address userAddress = address(uint160(uint(keccak256(abi.encodePacked(address(this), j)))));
        uint256 userTenderCount = getUserTenderCount(userAddress);
        for (uint256 k = 0; k < userTenderCount; k++) {
            (string memory tenderName, string memory tenderAmount, address tenderIssuer) = getTenderDetails(userAddress, users[userAddress].tenderIds[k]);
            allTenderNames[currentIndex] = new string[](1);
            allTenderNames[currentIndex][0] = tenderName;
            allTenderAmounts[currentIndex] = new string[](1);
            allTenderAmounts[currentIndex][0] = tenderAmount;
            allTenderIssuers[currentIndex] = new address[](1);
            allTenderIssuers[currentIndex][0] = tenderIssuer;
            currentIndex++;
        }
    }

    return (allTenderNames, allTenderAmounts, allTenderIssuers);
}

}
