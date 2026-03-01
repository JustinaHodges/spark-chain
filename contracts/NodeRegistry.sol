// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title NodeRegistry
 * @dev 节点注册和在线时长追踪合约
 * 
 * 功能：
 * 1. 节点注册
 * 2. 心跳上报（每小时）
 * 3. 在线时长统计
 * 4. 为空投合约提供验证
 */
contract NodeRegistry {
    address public owner;
    
    struct Node {
        address nodeAddress;
        uint256 registeredAt;    // 注册时间
        uint256 lastHeartbeat;   // 最后心跳时间
        uint256 totalOnlineTime; // 累计在线时长（秒）
        bool isActive;           // 是否活跃
    }
    
    mapping(address => Node) public nodes;
    address[] public nodeList;
    
    uint256 public constant HEARTBEAT_INTERVAL = 1 hours; // 心跳间隔
    uint256 public constant OFFLINE_THRESHOLD = 2 hours;  // 超时判定
    
    event NodeRegistered(address indexed nodeAddress, uint256 timestamp);
    event HeartbeatReceived(address indexed nodeAddress, uint256 timestamp);
    event NodeOffline(address indexed nodeAddress, uint256 timestamp);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev 注册节点
     */
    function registerNode() external {
        require(nodes[msg.sender].registeredAt == 0, "Already registered");
        
        nodes[msg.sender] = Node({
            nodeAddress: msg.sender,
            registeredAt: block.timestamp,
            lastHeartbeat: block.timestamp,
            totalOnlineTime: 0,
            isActive: true
        });
        
        nodeList.push(msg.sender);
        
        emit NodeRegistered(msg.sender, block.timestamp);
    }
    
    /**
     * @dev 发送心跳
     * 节点每小时调用一次，更新在线时长
     */
    function heartbeat() external {
        Node storage node = nodes[msg.sender];
        require(node.registeredAt > 0, "Node not registered");
        
        // 计算距离上次心跳的时间
        uint256 timeSinceLastHeartbeat = block.timestamp - node.lastHeartbeat;
        
        // 如果超过2小时没心跳，判定为离线过，只计算1小时
        if (timeSinceLastHeartbeat > OFFLINE_THRESHOLD) {
            node.totalOnlineTime += HEARTBEAT_INTERVAL;
            node.isActive = false;
            emit NodeOffline(msg.sender, block.timestamp);
        } else {
            // 正常情况，累加在线时长
            node.totalOnlineTime += timeSinceLastHeartbeat;
            node.isActive = true;
        }
        
        node.lastHeartbeat = block.timestamp;
        
        emit HeartbeatReceived(msg.sender, block.timestamp);
    }
    
    /**
     * @dev 获取节点在线时长（秒）
     */
    function getNodeOnlineTime(address _nodeAddress) external view returns (uint256) {
        Node memory node = nodes[_nodeAddress];
        if (node.registeredAt == 0) return 0;
        
        // 如果节点当前在线，加上距离上次心跳的时间
        uint256 currentOnlineTime = node.totalOnlineTime;
        uint256 timeSinceLastHeartbeat = block.timestamp - node.lastHeartbeat;
        
        if (timeSinceLastHeartbeat <= OFFLINE_THRESHOLD) {
            currentOnlineTime += timeSinceLastHeartbeat;
        }
        
        return currentOnlineTime;
    }
    
    /**
     * @dev 获取节点在线天数
     */
    function getNodeOnlineDays(address _nodeAddress) external view returns (uint256) {
        uint256 onlineTime = this.getNodeOnlineTime(_nodeAddress);
        return onlineTime / 1 days;
    }
    
    /**
     * @dev 检查节点是否在线
     */
    function isNodeOnline(address _nodeAddress) external view returns (bool) {
        Node memory node = nodes[_nodeAddress];
        if (node.registeredAt == 0) return false;
        
        uint256 timeSinceLastHeartbeat = block.timestamp - node.lastHeartbeat;
        return timeSinceLastHeartbeat <= OFFLINE_THRESHOLD;
    }
    
    /**
     * @dev 获取节点详细信息
     */
    function getNodeInfo(address _nodeAddress) external view returns (
        uint256 registeredAt,
        uint256 lastHeartbeat,
        uint256 totalOnlineTime,
        uint256 onlineDays,
        bool isActive,
        bool isOnline
    ) {
        Node memory node = nodes[_nodeAddress];
        uint256 currentOnlineTime = this.getNodeOnlineTime(_nodeAddress);
        
        return (
            node.registeredAt,
            node.lastHeartbeat,
            currentOnlineTime,
            currentOnlineTime / 1 days,
            node.isActive,
            this.isNodeOnline(_nodeAddress)
        );
    }
    
    /**
     * @dev 获取总节点数
     */
    function getTotalNodes() external view returns (uint256) {
        return nodeList.length;
    }
    
    /**
     * @dev 获取活跃节点数
     */
    function getActiveNodes() external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < nodeList.length; i++) {
            if (this.isNodeOnline(nodeList[i])) {
                count++;
            }
        }
        return count;
    }
}
