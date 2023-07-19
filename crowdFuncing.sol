// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


contract Crowdfunding{
    mapping(address => uint) public funders;
    uint public deadline;
    uint public targetFunds;
    string public name;
    address public owner;
    bool public fundsWithdrawn;

    event Funded(address _funder, uint _amount);
    event OwnerWithdraw(uint _amount);
    event FunderWithdraw(address _funder, uint _amount);

    constructor(string memory _name, uint _targetFunds, uint _deadline){
        owner = msg.sender;
        name = _name;
        targetFunds = _targetFunds;
        deadline = _deadline;
    }

    function isFundSuccess() public view returns(bool){
        if (address(this).balance>= targetFunds ||fundsWithdrawn){
            return true;
        }else {
            return false;
        }
    }
    function fund() public payable{
        require(isFundEnabled() == true, "Funding is now disabled");
        funders[msg.sender] += msg.value;
        emit Funded(msg.sender, msg.value);
    }

    function withdrawOwner() public{
        require(msg.sender == owner, "Not authorized");
        require(isFundSuccess() == true, "Cannot withdraw");
        uint amountToSend = address(this).balance;
        (bool success,) = msg.sender.call{value: amountToSend}("");
        require(success, "unable to send");
        fundsWithdrawn = true;
        emit OwnerWithdraw(amountToSend);
    }

    function withdrawFunder() public{
        require(isFundEnabled() == false && isFundSuccess() == false,"Not eligible");
        uint amountToSend = funders[msg.sender];
        (bool success,) = msg.sender.call{value: amountToSend}("");
        require(success, "unable to send");
        funders[msg.sender] = 0;
        emit FunderWithdraw(msg.sender, amountToSend);
    }
 

    function isFundEnabled() public view returns(bool){
        if ((block.timestamp) > deadline || fundsWithdrawn){
            return false;
         }           else{
             return true;
         }
    }
}