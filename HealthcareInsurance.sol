pragma solidity ^0.4.24;

contract HealthCareInsurance{ //insurance company paying medical insurance to citizens
    address Owner;
    address[] internal citizenAddress; 
    
    struct citizen{             //citizen details
        bool is_UIDgenerated;
        string name;
        uint amountInsured;
    }
    constructor () public{
        Owner=msg.sender;
    }
    mapping (address=>citizen) public citizenData;
    mapping (address=>bool) public doctors; //only doctors address
    
    modifier onlyOwner(){
        require (Owner==msg.sender);
        _;
    }
    
    function setDoctor(address _address)  public onlyOwner{  //only owner of the  contract could set the doctors
        require(!doctors[_address]);    //to avoid duplicate doctor registration
        doctors[_address]=true;
    }
    
    function setcitizenData(string _name,uint _amountInsured) public onlyOwner{ 
       address UID=address(sha256(abi.encodePacked(msg.sender,now)));   //generating random address for citizen
       require(!citizenData[UID].is_UIDgenerated);
       citizenData[UID].is_UIDgenerated=true;
       citizenData[UID].name=_name;
       citizenData[UID].amountInsured=_amountInsured;
       citizenAddress.push(UID);
    }
    
    function getcitizensAddress() public view onlyOwner returns(address[]){ //return array of all address of citizens
        return citizenAddress;
    }
    
    function useInsurance(address _UID,uint _amountToUse) public returns(string){       //only linked doctors could send the insurance request to insurance company on behalf of citizen
        require(doctors[msg.sender]);
        if(citizenData[_UID].amountInsured<_amountToUse){
            revert();
        }
        citizenData[_UID].amountInsured-=_amountToUse;
    }
    
}