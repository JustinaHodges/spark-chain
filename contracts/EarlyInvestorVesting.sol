// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title EarlyInvestorVesting
 * @dev 早期投资者代币锁仓合约
 * 总量: 100,000,000,000 SPARK (10%)
 * 锁仓期: 6个月
 * 释放期: 2年线性释放
 */
contract EarlyInvestorVesting {
    address public owner;
    address public sparkToken;
    
    uint256 public constant TOTAL_ALLOCATION = 100_000_000_000 * 10**18; // 1000亿 SPARK
    uint256 public constant CLIFF_DURATION = 180 days; // 6个月锁仓
    uint256 public constant VESTING_DURATION = 730 days; // 2年释放
    
    uint256 public startTime;
    uint256 public totalClaimed;
    
    struct Investor {
        uint256 allocation;      // 分配额度
        uint256 claimed;         // 已领取
        bool registered;         // 是否注册
    }
    
    mapping(address => Investor) public investors;
    address[] public investorList;
    
    event InvestorRegistered(address indexed investor, uint256 allocation);
    event TokensClaimed(address indexed investor, uint256 amount);
    event VestingStarted(uint256 startTime);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor(address _sparkToken) {
        owner = msg.sender;
        sparkToken = _sparkToken;
    }
    
    /**
     * @dev 注册早期投资者
     * @param _investor 投资者地址
     * @param _allocation 分配额度（单位：SPARK，会自动乘以10^18）
     */
    function registerInvestor(address _investor, uint256 _allocation) external onlyOwner {
        require(!investors[_investor].registered, "Already registered");
        require(_allocation > 0, "Invalid allocation");
        
        uint256 allocationWei = _allocation * 10**18;
        require(getTotalAllocated() + allocationWei <= TOTAL_ALLOCATION, "Exceeds total allocation");
        
        investors[_investor] = Investor({
            allocation: allocationWei,
            claimed: 0,
            registered: true
        });
        
        investorList.push(_investor);
        
        emit InvestorRegistered(_investor, allocationWei);
    }
    
    /**
     * @dev 批量注册投资者
     */
    function registerInvestorsBatch(address[] calldata _investors, uint256[] calldata _allocations) external onlyOwner {
        require(_investors.length == _allocations.length, "Length mismatch");
        
        for (uint256 i = 0; i < _investors.length; i++) {
            if (!investors[_investors[i]].registered && _allocations[i] > 0) {
                uint256 allocationWei = _allocations[i] * 10**18;
                
                investors[_investors[i]] = Investor({
                    allocation: allocationWei,
                    claimed: 0,
                    registered: true
                });
                
                investorList.push(_investors[i]);
                emit InvestorRegistered(_investors[i], allocationWei);
            }
        }
    }
    
    /**
     * @dev 启动释放计划
     */
    function startVesting() external onlyOwner {
        require(startTime == 0, "Already started");
        startTime = block.timestamp;
        emit VestingStarted(startTime);
    }
    
    /**
     * @dev 计算可领取金额
     */
    function getClaimableAmount(address _investor) public view returns (uint256) {
        if (startTime == 0) return 0;
        if (!investors[_investor].registered) return 0;
        
        uint256 elapsed = block.timestamp - startTime;
        
        // 锁仓期内不能领取
        if (elapsed < CLIFF_DURATION) {
            return 0;
        }
        
        // 计算已解锁金额
        uint256 vestedAmount;
        if (elapsed >= CLIFF_DURATION + VESTING_DURATION) {
            // 全部解锁
            vestedAmount = investors[_investor].allocation;
        } else {
            // 线性解锁
            uint256 vestingElapsed = elapsed - CLIFF_DURATION;
            vestedAmount = (investors[_investor].allocation * vestingElapsed) / VESTING_DURATION;
        }
        
        // 减去已领取
        return vestedAmount - investors[_investor].claimed;
    }
    
    /**
     * @dev 领取代币
     */
    function claim() external {
        require(investors[msg.sender].registered, "Not registered");
        
        uint256 claimable = getClaimableAmount(msg.sender);
        require(claimable > 0, "Nothing to claim");
        
        investors[msg.sender].claimed += claimable;
        totalClaimed += claimable;
        
        // 转账 SPARK 代币
        (bool success, ) = sparkToken.call(
            abi.encodeWithSignature("transfer(address,uint256)", msg.sender, claimable)
        );
        require(success, "Transfer failed");
        
        emit TokensClaimed(msg.sender, claimable);
    }
    
    /**
     * @dev 查询总分配额度
     */
    function getTotalAllocated() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < investorList.length; i++) {
            total += investors[investorList[i]].allocation;
        }
        return total;
    }
    
    /**
     * @dev 查询投资者数量
     */
    function getInvestorCount() external view returns (uint256) {
        return investorList.length;
    }
    
    /**
     * @dev 查询投资者信息
     */
    function getInvestorInfo(address _investor) external view returns (
        uint256 allocation,
        uint256 claimed,
        uint256 claimable,
        bool registered
    ) {
        Investor memory inv = investors[_investor];
        return (
            inv.allocation,
            inv.claimed,
            getClaimableAmount(_investor),
            inv.registered
        );
    }
    
    /**
     * @dev 紧急提取（仅owner，用于迁移或紧急情况）
     */
    function emergencyWithdraw(address _token, uint256 _amount) external onlyOwner {
        (bool success, ) = _token.call(
            abi.encodeWithSignature("transfer(address,uint256)", owner, _amount)
        );
        require(success, "Transfer failed");
    }
}
