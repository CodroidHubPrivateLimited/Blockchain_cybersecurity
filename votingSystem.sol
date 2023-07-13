/*** The Address Book

The Chairperson:    0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

Proposal names:     Alice, Betty, Cecilia, Dana
Proposal names:     Alice, Betty, Cecilia, Dana
(name, bytes32-encoded name, account)

Alice:              0x416c696365000000000000000000000000000000000000000000000000000000  0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

Betty:              0x4265747479000000000000000000000000000000000000000000000000000000  0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

Cecilia:            0x436563696c696100000000000000000000000000000000000000000000000000  0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB

Dana:               0x44616e6100000000000000000000000000000000000000000000000000000000  0x617F2E2fD72FD9D5503197092aC168c91465E7f2

Contract input argument:
["0x416c696365000000000000000000000000000000000000000000000000000000","0x4265747479000000000000000000000000000000000000000000000000000000","0x436563696c696100000000000000000000000000000000000000000000000000","0x44616e6100000000000000000000000000000000000000000000000000000000"]
***/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

contract Ballot {
    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    function giveRightToVote(address voter) external {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            require(to != msg.sender, "Found loop in delegation.");
        }

        Voter storage delegate_ = voters[to];
        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() external view
            returns (bytes32 winnerName_)
    {   
        winnerName_ = proposals[winningProposal()].name;
    }
}   