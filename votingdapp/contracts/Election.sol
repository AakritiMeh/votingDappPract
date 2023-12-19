//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Election {
    uint256 candidateCount;
    uint256 voterCount;
    bool start;
    bool end;
    address public admin;

    constructor() {
        admin = msg.sender;
        voterCount = 0;
        candidateCount = 0;
        start = false;
        end = true;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin has access");
        _;
    }
    struct candidate {
        uint256 votes;
        uint256 candidateId;
        string header;
        string slogan;
        bool isVerified;
        bool isParticipating;
    }

    mapping(uint256 => candidate) public candidateList;

    function addCandidate(
        string memory _header,
        string memory _slogan
    ) public onlyAdmin {
        candidate memory newCandidate = candidate({
            candidateId: candidateCount,
            header: _header,
            slogan: _slogan,
            votes: 0,
            isVerified: true,
            isParticipating: true
        });
        candidateList[candidateCount] = newCandidate;
        candidateCount++;
    }

    function checkCandidateVerificationStatus(
        uint256 cndidateId
    ) public view returns (bool) {
        return candidateList[cndidateId].isVerified;
    }

    function checkVotesForCandidate(
        uint256 candidateId
    ) public view returns (uint256) {
        return candidateList[candidateId].votes;
    }

    struct voter {
        address addr;
        string name;
        string phone;
        bool isRegistered;
        bool isVerified;
        bool hasVoted;
    }

    address[] public voters;
    mapping(address => voter) public voterList;

    function registerVoter(string memory _name, string memory _phone) public {
        voter memory newVoter = voter({
            addr: msg.sender,
            name: _name,
            phone: _phone,
            isRegistered: true,
            isVerified: false,
            hasVoted: false
        });

        voterList[msg.sender] = newVoter;
        voters.push(msg.sender);
        voterCount++;
    }

    function returnVoterAddress(
        uint256 idNo
    ) public view returns (address addr) {
        address x = voters[idNo];
        return (x);
    }

    function verifyVoter(
        bool _verifiationStatus,
        address voterAddr
    ) public onlyAdmin {
        voterList[voterAddr].isVerified = _verifiationStatus;
    }

    function returnVoterDetails(
        uint256 idNo
    )
        public
        view
        returns (
            address addr,
            string memory name,
            string memory phone,
            bool isRegistered,
            bool isVerified,
            bool hasVoted
        )
    {
        address x = returnVoterAddress(idNo);
        return (
            x,
            voterList[x].name,
            voterList[x].phone,
            voterList[x].isRegistered,
            voterList[x].isVerified,
            voterList[x].hasVoted
        );
    }

    function returnVerificationStatusOfVoter(
        uint256 idNo
    ) public view returns (bool) {
        address x = returnVoterAddress(idNo);
        return voterList[x].isVerified;
    }

    function returnHasVoted(uint256 IdNo) public view returns (bool) {
        address x = returnVoterAddress(IdNo);
        return voterList[x].hasVoted;
    }

    struct ElectionDetails {
        string adminName;
        string adminEmail;
        string adminTitle;
        string electionTitle;
        string organizationTitle;
    }

    ElectionDetails electionDetails;

    function setElectionDetails(
        string memory _adminName,
        string memory _adminEmail,
        string memory _adminTitle,
        string memory _electionTitle,
        string memory _organizationTitle
    ) public onlyAdmin {
        electionDetails = ElectionDetails(
            _adminName,
            _adminEmail,
            _adminTitle,
            _electionTitle,
            _organizationTitle
        );
        start = true;
        end = false;
    }

    function getElectionDetails()
        public
        view
        returns (
            string memory _adminName,
            string memory _adminEmail,
            string memory _adminTitle,
            string memory _electionTitle,
            string memory _organizationTitle
        )
    {
        return (
            electionDetails.adminName,
            electionDetails.adminEmail,
            electionDetails.adminTitle,
            electionDetails.electionTitle,
            electionDetails.organizationTitle
        );
    }

    function getTotalCandidates() public view returns (uint256) {
        return candidateCount;
    }

    function getTotalVoters() public view returns (uint256) {
        return voterCount;
    }

    function vote(uint256 candidateId) public {
        require(voterList[msg.sender].hasVoted == false);
        require(voterList[msg.sender].isVerified == true);
        require(start == true);
        require(end == false);
        candidateList[candidateId].votes += 1;
        voterList[msg.sender].hasVoted = true;
    }

    function endElection() public onlyAdmin {
        end = true;
        start = false;
    }

    function getStart() public view returns (bool) {
        return start;
    }

    function getEnd() public view returns (bool) {
        return end;
    }
}
