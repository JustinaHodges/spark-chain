// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EarlyAdopterAirdrop V2
 * @dev 早期用户空投合约 - 防女巫攻击版本
 * 
 * 领取条件：
 * 1. 必须挖到至少 100 SPARK
 * 2. 节点在线至少 7 天
 * 3. 领到的 100,000 SPARK 锁仓 3 个月
 * 
 * 前 10,000 名符合条件的用户可领取
 */
contract EarlyAdopterAirdropV2 {
    address public owner;
    address public sparkToken;
    address public nodeRegistry; // 节点注册合约地址
    
    uint256 public constant AIRDROP_AMOUNT = 100_000 * 10**18; // 10万SPARK
    uint256 public constant MIN_BALANCE = 100 * 10**18; // 最低持有100 SPARK
    uint256 public constant MIN_ONLINE_DAYS = 7 days; // 最少在线7天
    uint256 public constant LOCK_PERIOD = 90 days; // 锁仓3个月
    uint256 public constant MAX_RECIPIENTS = 10_000; // 前1万名
    
    uint256 public recipientCount;
    bool public airdropActive = true;
    
    struct Claim {
        uint256 amount;          // 领取数量
        uint256 claimTime;       // 领取时间
        uint256 unlockTime;      // 解锁时间
        uint256 withdrawn;       // 已提取
    }
    
    mapping(address => Claim) public claims;
    mapping(address => bool) public hasReceived;
    address[] public recipients;
    
    event AirdropClaimed(address indexed recipient, uint256 amount, uint256 unlockTime, uint256 recipientNumber);
    event TokensWithdrawn(address indexed recipient, uint256 amount);
    event AirdropCompleted(uint256 totalRecipients);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor(address _sparkToken, address _nodeRegistry) {
        owner = msg.sender;
        sparkToken = _sparkToken;
        nodeRegistry = _nodeRegistry;
    }
    
    /**
     * @dev 领取空投
     * 检查：余额 >= 100 SPARK + 节点在线 >= 7天
     */
    function claim() external {
        require(airdropActive, "Airdrop ended");
        require(recipientCount < MAX_RECIPIENTS, "Airdrop completed");
        require(!hasReceived[msg.sender], "Already claimed");
        
        // 1. 检查 SPARK 余额
        (bool success, bytes memory data) = sparkToken.call(
            abi.encodeWithSignature("balanceOf(address)", msg.sender)
        );
        require(success, "Balance check failed");
        uint256 balance = abi.decode(data, (uint256));
        require(balance >= MIN_BALANCE, "Need at least 100 SPARK");
        
        // 2. 检查节点在线时长
        (bool nodeSuccess, bytes memory nodeData) = nodeRegistry.call(
            abi.encodeWithSignature("getNodeOnlineTime(address)", msg.sender)
        );
        require(nodeSuccess, "Node check failed");
        uint256 onlineTime = abi.decode(nodeData, (uint256));
        require(onlineTime >= MIN_ONLINE_DAYS, "Node must be online for 7+ days");
        
        // 3. 记录领取信息（锁仓）
        uint256 unlockTime = block.timestamp + LOCK_PERIOD;
        claims[msg.sender] = Claim({
            amount: AIRDROP_AMOUNT,
            claimTime: block.timestamp,
            unlockTime: unlockTime,
            withdrawn: 0
        });
        
        hasReceived[msg.sender] = true;
        recipients.push(msg.sender);
        recipientCount++;
        
        emit AirdropClaimed(msg.sender, AIRDROP_AMOUNT, unlockTime, recipientCount);
        
        // 4. 达到1万人自动结束
        if (recipientCount >= MAX_RECIPIENTS) {
            airdropActive = false;
            emit AirdropCompleted(recipientCount);
        }
    }
    
    /**
     * @dev 提取解锁的代币
     */
    function withdraw() external {
        Claim storage userClaim = claims[msg.sender];
        require(userClaim.amount > 0, "No claim found");
        require(block.timestamp >= userClaim.unlockTime, "Still locked");
        
        uint256 available = userClaim.amount - userClaim.withdrawn;
        require(available > 0, "Already withdrawn");
        
        userClaim.withdrawn = userClaim.amount;
        
        (bool success, ) = sparkToken.call(
            abi.encodeWithSignature("transfer(address,uint256)", msg.sender, available)
        );
        require(success, "Transfer failed");
        
        emit TokensWithdrawn(msg.sender, available);
    }
    
    /**
     * @dev 查询可提取金额
     */
    function getWithdrawable(address _user) external view retu256) {
        Claim memory userClaim = claims[_user];
        if (userClaim.amount == 0) return 0;
        if (block.timestamp < userClaim.unlockTime) return 0;
        return userClaim.amount - userClaim.withdrawn;
    }
    
    /**
     * @dev 查询锁仓剩余时间（秒）
     */
    function getTimeUntilUnlock(address _user) external view returns (uint256) {
        Claim memory userClaim = claims[_user];
        if (userClaim.amount == 0) return 0;
        if (block.timestamp >= userClaim.unlockTime) return 0;
        return userClaim.unlockTime - block.timestamp;
    }
    
    /**
     * @dev 检查是否符合领取条件
     */
    function isEligible(address _address) external view returns (
        bool eligible,
        string memory reason,
        uint256 balance,
        uint256 onlineDays
    ) {
        if (!airdropActive) return (false, "Airdrop ended", 0, 0);
        if (hasReceived[_address]) return (false, "Already claimed", 0, 0);
        if (recipientCount >= MAX_RECIPIENTS) return (false, "Airdrop completed", 0, 0);
        
        // 检查余额
        (bool success, bytes memory data) = sparkToken.staticcall(
            abi.encodeWithSignature("balanceOf(address)", _address)
        );
        if (!success) return (false, "Balance check failed", 0, 0);
        balance = abi.decode(data, (uint256));
        
        if (balance < MIN_BALANCE) {
            return (false, "Need at least 100 SPARK", balance, 0);
        }
        
        // 检查在线时长
        (bool nodeSuccess, bytes memory nodeData) = nodeRegistry.staticcall(
            abi.encodeWithSignature("getNodeOnlineTime(address)", _address)
        );
        if (!nodeSuccess) return (false, "Node check failed", balance, 0);
        uint256 onlineTime = abi.decode(nodeData, (uint256));
        onlineDays = onlineTime / 1 days;
        
        if (onlineTime < MIN_ONLINE_DAYS) {
            return (false, "Node must be online for 7+ days", balance, onlineDays);
        }
        
        return (true, "Eligible", balance, onlineDays);
    }
    
    /**
     * @dev 查询剩余名额
     */
    function getRemainingSlots() external view returns (uint256) {
        if (recipientCount >= MAX_RECIPIENTS) return 0;
        return MAX_RECIPIENTS - recipientCount;
    }
    
    /**
     * @dev 更新节点注册合约地址
     */
    function setNodeRegistry(address _nodeRegistry) external onlyOwner {
        nodeRegistry = _nodeRegistry;
    }
    
    /**
     * @dev 手动结束空投
     */
    function endAirdrop() external onlyOwner {
        airdropActive = false;
        emit AirdropCompleted(recipientCount);
    }
    
    /**
     * @dev 紧急提取剩余代币
     */
    function emergencyWithdraw() external onlyOwner {
        require(!airdropActive, "Airdrop still active");
        
        (bool success, bytes memory data) = sparkToken.call(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        require(success, "Balance check failed");
        
        uint256 balance = abi.decode(data, (uint256));
        
        // 计算已锁仓但未提取的总额
        uint256 locked = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            Claim memory userClaim = claims[recipients[i]];
            locked += (userClaim.amount - userClaim.withdrawn);
        }
        
        // 只能提取未分配的部分
        require(balance > locked, "No excess balance");
        uint256 excess = balance - locked;
        
        (bool transferSuccess, ) = sparkToken.call(
            abi.encodeWithSignature("transfer(address,uint256)", owner, excess)
        );
        require(transferSuccess, "Transfer failed");
    }
}
