// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EarlyAdopterAirdrop
 * @dev 早期用户自动空投合约
 * 前10,000个持有SPARK的地址，每个自动获得 100,000 SPARK
 * 无需注册，自动检测，自动发放
 */
contract EarlyAdopterAirdrop {
    address public owner;
    address public sparkToken;
    
    uint256 public constant AIRDROP_AMOUNT = 100_000 * 10**18; // 每人10万SPARK
    uint256 public constant MAX_RECIPIENTS = 10_000; // 前1万个地址
    uint256 public constant TOTAL_ALLOCATION = 1_000_000_000 * 10**18; // 总共10亿SPARK
    
    uint256 public recipientCount;
    mapping(address => bool) public hasReceived;
    address[] public recipients;
    
    bool public airdropActive = true;
    
    event AirdropClaimed(address indexed recipient, uint256 amount, uint256 recipientNumber);
    event AirdropCompleted(uint256 totalRecipients);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor(address _sparkToken) {
        owner = msg.sender;
        sparkToken = _sparkToken;
    }
    
    /**
     * @dev 自动空投 - 任何人调用都会触发检测
     * 如果调用者符合条件且未领取，自动发放
     */
    function claim() external {
        require(airdropActive, "Airdrop ended");
        require(recipientCount < MAX_RECIPIENTS, "Airdrop completed");
        require(!hasReceived[msg.sender], "Already received");
        
        // 检查调用者是否持有SPARK（余额>0）
        (bool success, bytes memory data) = sparkToken.call(
            abi.encodeWithSignature("balanceOf(address)", msg.sender)
        );
        require(success, "Balance check failed");
        uint256 balance = abi.decode(data, (uint256));
        require(balance > 0, "Must hold SPARK to claim");
        
        // 发放空投
        hasReceived[msg.sender] = true;
        recipients.push(msg.sender);
        recipientCount++;
        
        (bool transferSuccess, ) = sparkToken.call(
            abi.encodeWithSignature("transfer(address,uint256)", msg.sender, AIRDROP_AMOUNT)
        );
        require(transferSuccess, "Transfer failed");
        
        emit AirdropClaimed(msg.sender, AIRDROP_AMOUNT, recipientCount);
        
        // 如果达到1万人，自动结束
        if (recipientCount >= MAX_RECIPIENTS) {
            airdropActive = false;
            emit AirdropCompleted(recipientCount);
        }
    }
    
    /**
     * @dev 批量空投 - owner可以主动给符合条件的地址发放
     */
    function airdropBatch(address[] calldata _recipients) external onlyOwner {
        requirpActive, "Airdrop ended");
        
        for (uint256 i = 0; i < _recipients.length; i++) {
            if (recipientCount >= MAX_RECIPIENTS) break;
            if (hasReceived[_recipients[i]]) continue;
            
            // 检查是否持有SPARK
            (bool success, bytes memory data) = sparkToken.call(
                abi.encodeWithSignature("balanceOf(address)", _recipients[i])
            );
            if (!success) continue;
            
            uint256 balance = abi.decode(data, (uint256));
            if (balance == 0) continue;
            
            // 发放
            hasReceived[_recipients[i]] = true;
       cipients.push(_recipients[i]);
            recipientCount++;
            
            (bool transferSuccess, ) = sparkToken.call(
                abi.encodeWithSignature("transfer(address,uint256)", _recipients[i], AIRDROP_AMOUNT)
            );
            
            if (transferSuccess) {
                emit AirdropClaimed(_recipients[i], AIRDROP_AMOUNT, recipientCount);
            }
        }
        
        if (recipientCount >= MAX_RECIPIENTS) {
            airdropActive = false;
            emit AirdropCompleted(recipientCount);
        }
    }
    
      * @dev 检查地址是否符合空投条件
     */
    function isEligible(address _address) external view returns (bool) {
        if (!airdropActive) return false;
        if (hasReceived[_address]) return false;
        if (recipientCount >= MAX_RECIPIENTS) return false;
        
        (bool success, bytes memory data) = sparkToken.staticcall(
            abi.encodeWithSignature("balanceOf(address)", _address)
        );
        if (!success) return false;
        
        uint256 balance = abi.decode(data, (uint256));
        return balance > 0;
    }
    
    /**
     * @dev 查询剩余名额
     */
    function getRemainingSlots() external view returns (uint256) {
        if (recipientCount >= MAX_RECIPIENTS) return 0;
        return MAX_RECIPIENTS - recipientCount;
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
    function withdrawRemaining() external onlyOwner {
        require(!airdropActive, "Airdrop still active");
        
        (bool success, bytes memory data) = sparkToken.call(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        require(success, "Balance check failed");
        
        uint256 remaining = abi.decode(data, (uint256));
        if (remaining > 0) {
            (bool transferSuccess, ) = sparkToken.call(
                abi.encodeWithSignature("transfer(address,uint256)", owner, remaining)
            );
            require(transferSuccess, "Transfer failed");
        }
    }
}
