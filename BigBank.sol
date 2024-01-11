// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
    //balances User address => amount
    mapping(address => uint256) public UserBalances;

    //top3
    address[3] public Top3Address;

    //totalBalances
    uint256 public TotalBalances = 0;

    constructor() {}

    //error balance too low tips
    error BalanceTooLow(address account);

    //error deposit eth too few tips
    error EthTooLow(uint256 eth);

    //deposit eth must be greater than 0,and sender balance >0.001 ETH
    modifier balanceLimit() {
        if (msg.sender.balance <= 0.001 ether) revert BalanceTooLow(msg.sender);
        if (msg.value <= 0) revert EthTooLow(msg.value);
        _;
    }

    function deposit() public payable balanceLimit {
        uint256 data = UserBalances[msg.sender] + msg.value;
        UserBalances[msg.sender] = data;
        TotalBalances = TotalBalances + msg.value;
        sort(msg.sender, data);
    }

    //sort the top 3
    function sort(address s, uint256 data) internal {
        uint256 min = data;
        uint8 index = 3;
        for (uint8 i = 0; i < 3; i++) {
            //exixt
            if (Top3Address[i] == s) {
                index = 3;
                break;
            }
            if (UserBalances[Top3Address[i]] < min) {
                min = UserBalances[Top3Address[i]];
                index = i;
            }
        }
        if (index < 3) {
            Top3Address[index] = s;
        }
    }

    //top3 address
    function getTop3() public view returns (address[3] memory) {
        return Top3Address;
    }
    receive() external payable { }
    
}

contract Ownable {
    address private _owner;

    error invalidAddress(address _owner);
    error transferFailed(address _address);
    //dev The caller account is not authorized to perform an operation
    error ownableUnauthorizedAccount(address account);
    error OwnableInvalidOwner(address owner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert invalidAddress(address(0));
        }
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != msg.sender) {
            revert ownableUnauthorizedAccount(msg.sender);
        }
    }
    //Transfers ownership of the contract to a new account (`newOwner`),Can only be called by the current owner.
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert OwnableInvalidOwner(address(0));
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        //emit important even
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
}

contract BigBank is Bank, Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}

    function withdraw(address payable recipient, uint256 amount)
        public
        onlyOwner
    {
        //require(msg.sender==owner,"only owner can withdraw eth");
        //payable(msg.sender).transfer(TotalBalances);
        if (recipient == address(0)) revert invalidAddress(address(0));
        if (amount <= 0 || amount > TotalBalances) revert EthTooLow(amount);

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) revert transferFailed(recipient);
        TotalBalances = TotalBalances - amount;
    }
}
