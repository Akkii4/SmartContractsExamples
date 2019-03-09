pragma solidity^0.4.20;

contract SimpleBank { 
    mapping (address => uint) private balances;

    
    address public owner;
    
    event DepositMade(address accountAddress, uint amount);

    
    constructor() public {
        
  
        owner = msg.sender;
    }

   
    function deposit() public payable returns (uint) {
        require(msg.value>0);
        require((balances[msg.sender] + msg.value) >= balances[msg.sender]);

        balances[msg.sender] += msg.value;
       
        emit DepositMade(msg.sender, msg.value); 

        return balances[msg.sender];
    }

   
    function withdraw(uint withdrawAmount) public returns (uint remainingBal) {
        require(withdrawAmount <= balances[msg.sender]);

     
        balances[msg.sender] -= withdrawAmount;

        msg.sender.transfer(withdrawAmount);

        return balances[msg.sender];
    }

   
    function balance() view public returns (uint) {
        return balances[msg.sender];
    }
    }