//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Voting {

    struct Voter {
        bool voted;
        address vote;
    }

    bool public votingStatus;

    mapping (address => uint256) private votesReceived;
    mapping (address => uint256) private moneyReceived;
    mapping (address => Voter)   private voters;

    address   private owner;
    address[] private candidateList;
    uint      private creationDate;


    constructor(address[] memory addressesOfCandidates) {
        owner        = msg.sender;
        creationDate = 1648342101;//block.timestamp;

        for (uint256 i = 0; i < addressesOfCandidates.length; i++) {
            candidateList.push(addressesOfCandidates[i]);
        }
        votingStatus = true;
    }

    function addCandidate(address addressOfCandidate) public {
        require(owner == msg.sender, "Has no right to add candidate"); 
        bool isNotExist = true;

        for (uint256 i = 0; i < candidateList.length; i++) {
            if (addressOfCandidate == candidateList[i]) {
                isNotExist = false;
            }
        }
        require(isNotExist, "Candidat has been already added"); 
        candidateList.push(addressOfCandidate);
    }

    function getAllCandidates() external view returns (address[] memory) {
        return candidateList;
    }

    function getCandidateVotes(address addressOfCandidate) external view returns (uint256 votesCount_) {
        votesCount_ = votesReceived[addressOfCandidate];
    }
    
    function vote(address addressOfCandidate) public payable {
        require(votingStatus, "The voting was completed");
        require(msg.value >= 10000000000000000, "Sum must be greater than 0,01 ETH");

        Voter storage voter = voters[msg.sender];
        require(!voter.voted, "Already voted.");

        voter.voted = true;
        voter.vote  = addressOfCandidate;

        votesReceived[addressOfCandidate] += 1;
        moneyReceived[addressOfCandidate] += msg.value;
    }

    function getFinishDate() public view returns (uint finishingDate_) {
        finishingDate_ = creationDate + 3 days;
    }

    function finishVoting() public returns (address winnerAddress_) {
        require(owner == msg.sender || getFinishDate() < block.timestamp, "Voting has not finished");
        
        uint256 sum         = 0;
        winnerAddress_      = candidateList[getWinnerPosition()];
        address payable _to = payable(winnerAddress_);
        sum                 = moneyReceived[winnerAddress_]/10*9;
        
        _to.transfer(sum);

        votingStatus = false;
    }

    function withdrawCommision() public {
        require(owner == msg.sender, "Has no right to withdraw commision");

        address payable _to   = payable(owner);
        address _thisContract = address(this);  

        _to.transfer(_thisContract.balance);
    }

    function getCurrentlyWinner() public view returns (address winnerAddress_) {
        winnerAddress_ = candidateList[getWinnerPosition()];
    }

    function getWinnerPosition() private view returns (uint256 winnerPosition_) {
        uint256 winningVoteCount = 0;
        uint256 voteCount        = 0;
        bool isSingleWinner      = true;
        for (uint256 p = 0; p < candidateList.length; p++) {
            voteCount = votesReceived[candidateList[p]];
            if (voteCount == winningVoteCount) {
                isSingleWinner = false;
            }
            if (voteCount > winningVoteCount) {
                winningVoteCount = voteCount;
                winnerPosition_  = p;
                isSingleWinner   = true;
            }
        }
        require(winningVoteCount != 0, "There are no one voted");
        require(isSingleWinner, "There must be one winner in the voting.");
    }
}