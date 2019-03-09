pragma solidity ^0.4.11;
contract Purchase {
    uint public purchaseValue;
    address public sellerAddress;
    address public buyerAddress;
    enum purchaseState { Created, Locked, Inactive }
    purchaseState public purchasestate;
    // Make sure that <code data-enlighter-language="generic" class="EnlighterJSRAW">msg.value</code> is an even number.
    // Division truncates if the number is odd.
    // Use multiplication to check that it wasn't an odd number.
    function Purchase() payable {
        sellerAddress = msg.sender;
        purchaseValue = msg.value / 2;
        require((2 * purchaseValue) == msg.value);
    }
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }
    modifier onlyBuyerAddress() {
        require(msg.sender == buyerAddress);
        _;
    }
    modifier onlySellerAddress() {
        require(msg.sender == sellerAddress);
        _;
    }
    modifier inPurchaseState(purchaseState _purchasestate) {
        require(purchasestate == _purchasestate);
        _;
    }
    event abortedPurchase();
    event confirmedPurchase();
    event receivedItem();
    /// Purchase is aborted and ether is reclaimed.
    /// May only be called by the seller before
    /// locking the contract.
    function abortPurchase()
        onlySellerAddress
        inPurchaseState(purchaseState.Created)
    {
        abortedPurchase();
        purchasestate = purchaseState.Inactive;
        sellerAddress.transfer(this.balance);
    }
    /// The purchase confirmed as a buyer.
    /// Transaction includes <code data-enlighter-language="generic" class="EnlighterJSRAW">2 * purchaseValue</code> ether.
    /// The ether is locked until receivedConfirm
    /// is called.
    function purchaseConfirm()
        inPurchaseState(purchaseState.Created)
        condition(msg.value == (2 * purchaseValue))
        payable
    {
        confirmedPurchase();
        buyerAddress = msg.sender;
        purchasestate = purchaseState.Locked;
    }
    /// Confirm that you (the buyerAddress) received the item.
    /// This will release the locked ether.
    function receivedConfirm()
        onlyBuyerAddress
        inPurchaseState(purchaseState.Locked)
    {
        receivedItem();
        // It is crucial to change the purchasestate firsthand since
        // otherwise, the contracts called using <code data-enlighter-language="generic" class="EnlighterJSRAW">send</code> below
        // can call in again here.
        purchasestate = purchaseState.Inactive;
        // NOTE: this will allow both sellerAddress and the buyerAddress to
        // block the refund - it is recommended to use the withdraw pattern.
        buyerAddress.transfer(purchaseValue);
        sellerAddress.transfer(this.balance);
    }
}