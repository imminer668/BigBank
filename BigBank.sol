// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
    // Mapping to store the balance of each address
    mapping(address => uint256) private balances;
    // Store whether a user is registered
    mapping(address => bool) private registeredUsers;
    // Mapping to store the loan balance of each user
    mapping(address => uint256) private loanBalances;
    // Mapping to store the collateral balance of each user
    mapping(address => uint256) private collateralBalances;

    // Loan-to-value ratio and liquidation threshold
    uint256 private constant LOAN_TO_VALUE_RATIO = 70; // 70%
    uint256 private constant LIQUIDATION_THRESHOLD = 75; // 75%
    
    // Loan interest rate (assumed to be 10%)
    uint256 private constant LOAN_INTEREST_RATE = 10;

    // Reentrancy attack protection
    bool private locked;

    // Admin address
    address private admin;

    // Deposit event
    event Deposited(address indexed account, uint256 amount);
    // Withdrawal event
    event Withdrawn(address indexed account, uint256 amount);
    // Balance check event
    event BalanceChecked(address indexed account, uint256 balance);
    // User registration event
    event UserRegistered(address indexed account);
    // Loan issued event
    event LoanIssued(address indexed account, uint256 amount);
    // Loan repayment event
    event LoanRepaid(address indexed account, uint256 amount);
    // Collateral event
    event CollateralDeposited(address indexed account, uint256 amount);
    // Liquidation event
    event Liquidation(address indexed account, uint256 amount);
    // Admin withdrawal event
    event AdminWithdraw(address indexed admin, uint256 amount);

    // Prevent reentrancy modifier
    modifier noReentrancy() {
        require(!locked, "Reentrancy detected!");
        locked = true; // Lock function
        _; // Execute function
        locked = false; // Unlock after execution
    }

    // Modifier that allows only admin to execute
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute");
        _;
    }

    constructor() {
        // Set the contract creator as the admin
        admin = msg.sender;
    }

    // User registration function
    function register() public {
        require(!registeredUsers[msg.sender], "User already registered");

        // Register user
        registeredUsers[msg.sender] = true;

        // Emit registration event
        emit UserRegistered(msg.sender);
    }

    // Deposit function
    function deposit() public payable noReentrancy {
        require(msg.value > 0, "You must deposit some ether");

        // Update user balance
        balances[msg.sender] += msg.value;
        
        // Emit deposit event
        emit Deposited(msg.sender, msg.value);
    }

    // Withdrawal function
    function withdraw(uint256 amount) public noReentrancy {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // Update balance
        balances[msg.sender] -= amount;
        
        // Transfer the amount
        payable(msg.sender).transfer(amount);
        
        // Emit withdrawal event
        emit Withdrawn(msg.sender, amount);
    }

    // Balance check function
    function getBalance() public noReentrancy returns (uint256) {
        uint256 balance = balances[msg.sender];
        
        // Emit balance check event
        emit BalanceChecked(msg.sender, balance);
        
        return balance;
    }

    // Collateral deposit function
    function depositCollateral() public payable noReentrancy {
        require(msg.value > 0, "You must deposit some ether as collateral");

        // Update collateral balance
        collateralBalances[msg.sender] += msg.value;

        // Emit collateral event
        emit CollateralDeposited(msg.sender, msg.value);
    }

    // Loan application function
    function applyForLoan(uint256 amount) public noReentrancy {
        require(registeredUsers[msg.sender], "User not registered");
        require(amount > 0, "Loan amount must be greater than zero");
        
        // Calculate maximum loan amount
        uint256 collateralValue = collateralBalances[msg.sender];
        uint256 maxLoanAmount = (collateralValue * LOAN_TO_VALUE_RATIO) / 100;

        require(amount <= maxLoanAmount, "Loan exceeds collateral value limit");

        // Grant loan
        loanBalances[msg.sender] += amount;

        // Transfer loan amount
        payable(msg.sender).transfer(amount);
        
        // Emit loan issued event
        emit LoanIssued(msg.sender, amount);
    }

    // Repayment function
    function repayLoan(uint256 amount) public payable noReentrancy {
        require(registeredUsers[msg.sender], "User not registered");
        require(loanBalances[msg.sender] > 0, "No outstanding loan");
        require(msg.value >= amount, "Insufficient repayment amount");

        // Calculate interest
        uint256 totalRepayment = (loanBalances[msg.sender] * (100 + LOAN_INTEREST_RATE)) / 100;

        require(amount >= totalRepayment, "Repayment must cover the full loan and interest");

        // Update loan balance
        loanBalances[msg.sender] = 0;

        // Emit loan repayment event
        emit LoanRepaid(msg.sender, amount);
    }

    // Check and trigger liquidation
    function checkForLiquidation() public noReentrancy {
        require(registeredUsers[msg.sender], "User not registered");
        require(loanBalances[msg.sender] > 0, "No outstanding loan");

        // Calculate collateral value and liquidation threshold
        uint256 collateralValue = collateralBalances[msg.sender];
        uint256 totalLoanAmount = loanBalances[msg.sender];
        uint256 liquidationThreshold = (collateralValue * LIQUIDATION_THRESHOLD) / 100;

        // If loan amount exceeds 75% of collateral, trigger liquidation
        if (totalLoanAmount > liquidationThreshold) {
            // Emit liquidation event
            emit Liquidation(msg.sender, totalLoanAmount);
            // Clear user's loan and collateral
            loanBalances[msg.sender] = 0;
            collateralBalances[msg.sender] = 0;
        }
    }

    // Query loan balance
    function getLoanBalance() public view returns (uint256) {
        return loanBalances[msg.sender];
    }

    // Query collateral balance
    function getCollateralBalance() public view returns (uint256) {
        return collateralBalances[msg.sender];
    }

    // Admin withdrawal function
    function adminWithdraw(uint256 amount) public onlyAdmin noReentrancy {
        require(address(this).balance >= amount, "Contract balance insufficient");

        // Transfer amount to admin
        payable(admin).transfer(amount);
        
        // Emit admin withdrawal event
        emit AdminWithdraw(admin, amount);
    }
}
