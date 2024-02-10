# Bank
###  Multi-Signature Administration:

* The contract allows multiple admin addresses to manage permissions using an array admins and a mapping isAdmin.

### User Registration:

* Users can register using the register function, which is required to perform deposits, loans, and other operations.

### Deposit and Withdrawal:

* Users can deposit and withdraw Ether, managed through the deposit and withdraw functions.

### Loan Management:

* Users can apply for loans based on the value of their collateral, adhering to the Loan-to-Value (LTV) ratio restrictions.

### Collateral Management:

* Users can deposit collateral, which can be used during loan applications.

### Liquidation Mechanism: 

* If a user's loan amount exceeds 75% of the collateral value, a liquidation process is triggered, clearing the user's loans and collateral.

### Admin Operations: 

* Only admins can perform withdrawals and manage other admin actions.

### Reentrancy Attack Protection: 

* The contract employs a noReentrancy modifier to prevent reentrancy attacks.

# Bank

• 模拟银行业务，支持存款、取款、质押、贷款、封控平台等功能。
### 多签名管理员: 

* 合约允许多个管理员地址管理权限，通过数组 admins 和映射 isAdmin 来管理这些管理员。

### 用户注册: 

* 用户可以通过 register 函数注册，注册后才能进行存款、贷款等操作。

### 存款与取款: 

* 用户可以存入和取出以太币，合约使用 deposit 和 withdraw 函数进行管理。

### 贷款管理: 

* 用户可以申请贷款，贷款金额基于其抵押品的价值，并需遵循贷款价值比（LTV）的限制。

### 抵押品管理: 

* 用户可以存入抵押品，并在贷款申请中使用。

### 清算机制: 

* 如果用户的贷款金额超过其抵押品价值的75%，则触发清算，清算过程中会清除用户的贷款和抵押品。

### 管理员操作: 

* 只有管理员可以进行提款和管理其他管理员的操作。

### 重入攻击防护: 

* 合约使用 noReentrancy 修饰符防止重入攻击。

### 代码仅为示例代码，具体实现可能需要根据实际需求进行调整。