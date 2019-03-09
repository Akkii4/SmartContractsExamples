pragma solidity ^0.4.19;


contract CrowdFunder {
    
    address public creator;
    address public fundRecipient; 
    uint public minimumToRaise; 
    string campaignUrl;
    byte constant version = 1;

   
    enum State {
        Fundraising,
        ExpiredRefund,
        Successful
    }
    struct Contribution {
        uint amount;
        address contributor;
    }

    
    State public state = State.Fundraising; 
    uint public totalRaised;
    uint public raiseBy;
    uint public completeAt;
    Contribution[] contributions;

    event LogFundingReceived(address addr, uint amount, uint currentTotal);
    event LogWinnerPaid(address winnerAddress);

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    
    modifier atEndOfLifecycle() {
    require(((state == State.ExpiredRefund || state == State.Successful) &&
        completeAt + 24 weeks < now));
        _;
    }

    constructor (
        uint timeInHoursForFundraising,
        string _campaignUrl,
        address _fundRecipient,
        uint _minimumToRaise)
        public
    {
        creator = msg.sender;
        fundRecipient = _fundRecipient;
        campaignUrl = _campaignUrl;
        minimumToRaise = _minimumToRaise;
        raiseBy = now + (timeInHoursForFundraising * 1 hours);
    }

    function contribute()
    public
    payable
    inState(State.Fundraising)
    returns(uint256 id)
    {
        contributions.push(
            Contribution({
                amount: msg.value,
                contributor: msg.sender
            }) 
        );
        totalRaised += msg.value;

        emit LogFundingReceived(msg.sender, msg.value, totalRaised);

        checkIfFundingCompleteOrExpired();
        return contributions.length - 1; 
    }

    function checkIfFundingCompleteOrExpired()
    public
    {
        if (totalRaised > minimumToRaise) {
            state = State.Successful;
            payOut();

           
        } else if ( now > raiseBy )  {
            state = State.ExpiredRefund; 
        }
        completeAt = now;
    }

    function payOut()
    public
    inState(State.Successful)
    {
        fundRecipient.transfer(address(this).balance);
        emit LogWinnerPaid(fundRecipient);
    }

    function getRefund(uint256 id)
    inState(State.ExpiredRefund)
    public
    returns(bool)
    {
        require(contributions.length > id && id >= 0 && contributions[id].amount != 0 );

        uint256 amountToRefund = contributions[id].amount;
        contributions[id].amount = 0;

        contributions[id].contributor.transfer(amountToRefund);

        return true;
    }

    function removeContract()
    public
    isCreator()
    atEndOfLifecycle()
    {
        selfdestruct(msg.sender);
      
    }
}