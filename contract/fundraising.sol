// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonationContract {
    struct Donation {
        uint id;
        string projectName;
        uint targetAmount;
        uint deadline;
        string description;
        string proofHash;
        string proofUrl;
        address initiator;
        uint donatedAmount;
        uint usedAmount;
        uint donorCount;
        mapping(address => uint) donorAmount;
        DonationRecord[] donationRecordsArray;
        UsageRequest[] usageRequestsArray;
    }

    struct DonationItem {
        uint id;
        string projectName;
        uint targetAmount;
        uint deadline;
        string description;
        string proofHash;
        string proofUrl;
        address initiator;
        uint donatedAmount;
        uint usedAmount;
        uint donorCount;
        uint donorAmount;
    }

    struct DonationRecord {
        uint id;
        uint amount;
        address donor;
        uint timestamp;
    }

    struct UsageRequest {
        uint id;
        uint donationId;
        address recipient;
        uint amount;
        string reason;
        uint time;
    }

    mapping(uint => Donation) private donations;
    uint private donationCount;
    uint private usageCount;

    uint private allAmount;
    uint private donateCount;
    uint private completeCount;

    mapping(address => uint[]) private myInitiatedDonations;
    mapping(address => uint[]) private myDonatedDonations;

    function info() public view returns (uint, uint, uint, uint) {
        return (allAmount, donateCount, completeCount, donationCount);
    }

    function createDonation(
        string memory _projectName,
        uint _targetAmount,
        uint _deadline,
        string memory _description,
        string memory _proofHash,
        string memory _proofUrl
    ) public {
        // check deadline
        require(
            _deadline > block.timestamp,
            "Deadline must be greater than current time"
        );
        donationCount++;
        donations[donationCount].id = donationCount;
        donations[donationCount].projectName = _projectName;
        donations[donationCount].targetAmount = _targetAmount;
        donations[donationCount].deadline = _deadline;
        donations[donationCount].description = _description;
        donations[donationCount].proofHash = _proofHash;
        donations[donationCount].proofUrl = _proofUrl;
        donations[donationCount].initiator = msg.sender;
        donations[donationCount].donatedAmount = 0;
        donations[donationCount].usedAmount = 0;
        donations[donationCount].donorCount = 0;

        myInitiatedDonations[msg.sender].push(donationCount);
    }

    function donate(uint _donationId) public payable {
        uint _amount = msg.value;
        require(_amount > 0, "Donation amount must be greater than 0");
        // check donation id
        require(
            _donationId > 0 && _donationId <= donationCount,
            "Donation id must be valid"
        );
        require(
            donations[_donationId].deadline > block.timestamp,
            "Donation deadline has passed"
        );
        require(
            donations[_donationId].donatedAmount + _amount <=
                donations[_donationId].targetAmount,
            "Donation amount must be less than target amount"
        );
        allAmount += _amount;
        donateCount++;
        donations[_donationId].donatedAmount += _amount;
        donations[_donationId].donationRecordsArray.push(
            DonationRecord({
                id: donateCount,
                amount: _amount,
                donor: msg.sender,
                timestamp: block.timestamp
            })
        );
        // check if already donated
        if (donations[_donationId].donorAmount[msg.sender] == 0) {
            donations[_donationId].donorAmount[msg.sender] = _amount;
            myDonatedDonations[msg.sender].push(_donationId);
            donations[_donationId].donorCount++;
        } else {
            donations[_donationId].donorAmount[msg.sender] += _amount;
        }
        // check if complete
        if (
            donations[_donationId].donatedAmount >=
            donations[_donationId].targetAmount
        ) {
            completeCount++;
        }
    }

    function requestUsage(
        uint _donationId,
        string memory _reason,
        uint amount
    ) public {
        require(
            msg.sender == donations[_donationId].initiator,
            "Only initiator can request usage"
        );
        require(
            donations[_donationId].donatedAmount -
                donations[_donationId].usedAmount >=
                amount,
            "Donated amount must be greater than usage amount"
        );
        usageCount++;
        donations[_donationId].usageRequestsArray.push(
            UsageRequest({
                id: usageCount,
                donationId: _donationId,
                recipient: msg.sender,
                amount: amount,
                reason: _reason,
                time: block.timestamp
            })
        );

        // 转移资金给使用人
        payable(msg.sender).transfer(amount);
        // 更新已使用资金
        donations[_donationId].usedAmount += amount;
    }

    function getDonationDetails(
        uint _donationId
    )
        public
        view
        returns (
            uint,
            string memory,
            uint,
            uint,
            string memory,
            string memory,
            address,
            uint,
            uint,
            uint
        )
    {
        Donation storage donation = donations[_donationId];
        return (
            donation.id,
            donation.projectName,
            donation.targetAmount,
            donation.deadline,
            donation.description,
            donation.proofHash,
            donation.initiator,
            donation.donatedAmount,
            donation.usedAmount,
            donation.donorCount
        );
    }

    

    function getAllDonations(
        string memory name
    ) public view returns (DonationItem[] memory) {
        DonationItem[] memory allDonations = new DonationItem[](donationCount);
        uint itemCount = 0; // 记录满足条件的项目数量

        for (uint i = 0; i < donationCount; i++) {
            if (bytes(name).length > 0) {
                if (
                    keccak256(abi.encodePacked(donations[i + 1].projectName)) !=
                    keccak256(abi.encodePacked(name))
                ) {
                    continue;
                }
            }
            allDonations[itemCount].id = donations[i + 1].id;
            allDonations[itemCount].projectName = donations[i + 1].projectName;
            allDonations[itemCount].targetAmount = donations[i + 1].targetAmount;
            allDonations[itemCount].deadline = donations[i + 1].deadline;
            allDonations[itemCount].description = donations[i + 1].description;
            allDonations[itemCount].proofHash = donations[i + 1].proofHash;

            allDonations[itemCount].initiator = donations[i + 1].initiator;
            allDonations[itemCount].donatedAmount = donations[i + 1].donatedAmount;
            allDonations[itemCount].usedAmount = donations[i + 1].usedAmount;
            allDonations[itemCount].donorCount = donations[i + 1].donorCount;
            itemCount++;
        }
        return allDonations;
    }

    function getDontaionById(
        uint _donationId
    ) public view returns (DonationItem memory) {
        DonationItem memory donationItem;
        donationItem.id = donations[_donationId].id;
        donationItem.projectName = donations[_donationId].projectName;
        donationItem.targetAmount = donations[_donationId].targetAmount;
        donationItem.deadline = donations[_donationId].deadline;
        donationItem.description = donations[_donationId].description;
        donationItem.proofHash = donations[_donationId].proofHash;
        donationItem.proofUrl = donations[_donationId].proofUrl;
        donationItem.initiator = donations[_donationId].initiator;
        donationItem.donatedAmount = donations[_donationId].donatedAmount;
        donationItem.usedAmount = donations[_donationId].usedAmount;
        donationItem.donorCount = donations[_donationId].donorCount;
        return donationItem;
    }

    function getMyInitiatedRecords()
        public
        view
        returns (DonationItem[] memory)
    {
        uint[] memory initiated = myInitiatedDonations[msg.sender];
        DonationItem[] memory initiatedDonations = new DonationItem[](
            initiated.length
        );

        for (uint i = 0; i < initiated.length; i++) {
            initiatedDonations[i].id = donations[initiated[i]].id;
            initiatedDonations[i].projectName = donations[initiated[i]]
                .projectName;
            initiatedDonations[i].targetAmount = donations[initiated[i]]
                .targetAmount;
            initiatedDonations[i].deadline = donations[initiated[i]].deadline;
            initiatedDonations[i].description = donations[initiated[i]]
                .description;
            initiatedDonations[i].proofHash = donations[initiated[i]].proofHash;
            initiatedDonations[i].initiator = donations[initiated[i]].initiator;
            initiatedDonations[i].donatedAmount = donations[initiated[i]]
                .donatedAmount;
            initiatedDonations[i].usedAmount = donations[initiated[i]]
                .usedAmount;
            initiatedDonations[i].donorCount = donations[initiated[i]]
                .donorCount;
        }
        return initiatedDonations;
    }

    function getMyDonation() public view returns (DonationItem[] memory) {
        uint[] memory donated = myDonatedDonations[msg.sender];
        DonationItem[] memory donatedDonations = new DonationItem[](
            donated.length
        );

        for (uint i = 0; i < donated.length; i++) {
            donatedDonations[i].id = donations[donated[i]].id;
            donatedDonations[i].projectName = donations[donated[i]].projectName;
            donatedDonations[i].targetAmount = donations[donated[i]]
                .targetAmount;
            donatedDonations[i].deadline = donations[donated[i]].deadline;
            donatedDonations[i].description = donations[donated[i]].description;
            donatedDonations[i].proofHash = donations[donated[i]].proofHash;
            donatedDonations[i].initiator = donations[donated[i]].initiator;
            donatedDonations[i].donatedAmount = donations[donated[i]]
                .donatedAmount;
            donatedDonations[i].usedAmount = donations[donated[i]].usedAmount;
            donatedDonations[i].donorCount = donations[donated[i]].donorCount;
            donatedDonations[i].donorAmount = donations[donated[i]].donorAmount[
                msg.sender
            ];
        }
        return donatedDonations;
    }

    function getDonationRecords(
        uint _donationId
    ) public view returns (DonationRecord[] memory) {
        DonationRecord[] memory donationRecords = new DonationRecord[](
            donations[_donationId].donationRecordsArray.length
        );
        for (
            uint i = 0;
            i < donations[_donationId].donationRecordsArray.length;
            i++
        ) {
            donationRecords[i].id = donations[_donationId]
                .donationRecordsArray[i]
                .id;
            donationRecords[i].amount = donations[_donationId]
                .donationRecordsArray[i]
                .amount;
            donationRecords[i].donor = donations[_donationId]
                .donationRecordsArray[i]
                .donor;
            donationRecords[i].timestamp = donations[_donationId]
                .donationRecordsArray[i]
                .timestamp;
        }
        return donationRecords;
    }

    function getUsageRequests(
        uint _donationId
    ) public view returns (UsageRequest[] memory) {
        UsageRequest[] memory usageRequests = new UsageRequest[](
            donations[_donationId].usageRequestsArray.length
        );
        for (
            uint i = 0;
            i < donations[_donationId].usageRequestsArray.length;
            i++
        ) {
            usageRequests[i].id = donations[_donationId]
                .usageRequestsArray[i]
                .id;
            usageRequests[i].donationId = donations[_donationId]
                .usageRequestsArray[i]
                .donationId;
            usageRequests[i].recipient = donations[_donationId]
                .usageRequestsArray[i]
                .recipient;
            usageRequests[i].amount = donations[_donationId]
                .usageRequestsArray[i]
                .amount;
            usageRequests[i].reason = donations[_donationId]
                .usageRequestsArray[i]
                .reason;
            usageRequests[i].time = donations[_donationId]
                .usageRequestsArray[i]
                .time;
        }
        return usageRequests;
    }
}
