const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');
const SparkWallet = require('./wallet');

const DATA_DIR = path.join(__dirname, '../data');
const NODE_FILE = path.join(DATA_DIR, 'node.json');
const CONFIG_FILE = path.join(DATA_DIR, 'config.json');

// NodeRegistry 合约地址
const NODE_REGISTRY_ADDRESS = '0x970951a12F975E6762482ACA81E57D5A2A4e73F4';

// NodeRegistry ABI（简化版）
const NODE_REGISTRY_ABI = [
  'function registerNode() external',
  'function heartbeat() external',
  'function getNodeOnlineTime(address) external view returns (uint256)',
  'function getNodeInfo(address) external view returns (uint256, uint256, uint256, uint256, bool, bool)',
  'function isNodeOnline(address) external view returns (bool)'
];

class SparkNode {
  constructor() {
    this.wallet = new SparkWallet();
    this.provider = null;
    this.contract = null;
    this.nodeData = this.loadNodeData();
  }

  // 加载节点数据
  loadNodeData() {
    if (fs.existsSync(NODE_FILE)) {
      return JSON.parse(fs.readFileSync(NODE_FILE, 'utf8'));
    }
    return {
      registered: false,
      registeredAt: null,
      lastHeartbeat: null,
      totalHeartbeats: 0,
      address: null
    };
  }

  // 保存节点数据
  saveNodeData() {
    fs.writeFileSync(NODE_FILE, JSON.stringify(this.nodeData, null, 2));
  }

  // 初始化合约
  async initContract(password) {
    const walletInstance = await this.wallet.loadWallet(password);
    this.provider = walletInstance.provider;
    this.contract = new ethers.Contract(
      NODE_REGISTRY_ADDRESS,
      NODE_REGISTRY_ABI,
      walletInstance
    );
    return this.contract;
  }

  // 注册节点
  async register(password) {
    if (this.nodeData.registered) {
      return { success: false, message: '节点已注册' };
    }

    await this.initContract(password);
    
    try {
      const tx = await this.contract.registerNode();
      await tx.wait();

      this.nodeData.registered = true;
      this.nodeData.registeredAt = Date.now();
      this.nodeData.address = (await this.wallet.loadWallet(password)).address;
      this.saveNodeData();

      return {
        success: true,
        message: '节点注册成功',
        txHash: tx.hash
      };
    } catch (error) {
      return {
        success: false,
        message: `注册失败: ${error.message}`
      };
    }
  }

  // 发送心跳
  async sendHeartbeat(password) {
    if (!this.nodeData.registered) {
      return { success: false, message: '节点未注册，请先注册' };
    }

    await this.initContract(password);

    try {
      const tx = await this.contract.heartbeat();
      await tx.wait();

      this.nodeData.lastHeartbeat = Date.now();
      this.nodeData.totalHeartbeats++;
      this.saveNodeData();

      return {
        success: true,
        message: '心跳发送成功',
        txHash: tx.hash,
        count: this.nodeData.totalHeartbeats
      };
    } catch (error) {
      return {
        success: false,
        message: `心跳失败: ${error.message}`
      };
    }
  }

  // 查询在线时长
  async getOnlineTime(password) {
    await this.initContract(password);
    const address = (await this.wallet.loadWallet(password)).address;

    try {
      const onlineTime = await this.contract.getNodeOnlineTime(address);
      const days = Number(onlineTime) / 86400;
      const hours = (days % 1) * 24;

      return {
        success: true,
        seconds: Number(onlineTime),
        days: Math.floor(days),
        hours: Math.floor(hours),
        formatted: `${Math.floor(days)} 天 ${Math.floor(hours)} 小时`
      };
    } catch (error) {
      return {
        success: false,
        message: `查询失败: ${error.message}`
      };
    }
  }

  // 查询节点信息
  async getNodeInfo(password) {
    await this.initContract(password);
    const address = (await this.wallet.loadWallet(password)).address;

    try {
      const info = await this.contract.getNodeInfo(address);
      const [registeredAt, lastHeartbeat, totalOnlineTime, onlineDays, isActive, isOnline] = info;

      return {
        success: true,
        registeredAt: new Date(Number(registeredAt) * 1000).toISOString(),
        lastHeartbeat: new Date(Number(lastHeartbeat) * 1000).toISOString(),
        totalOnlineTime: Number(totalOnlineTime),
        onlineDays: Number(onlineDays),
        isActive,
        isOnline
      };
    } catch (error) {
      return {
        success: false,
        message: `查询失败: ${error.message}`
      };
    }
  }

  // 检查节点状态
  async getStatus(password) {
    const address = this.nodeData.address || (await this.wallet.loadWallet(password)).address;

    return {
      registered: this.nodeData.registered,
      address: address,
      registeredAt: this.nodeData.registeredAt ? new Date(this.nodeData.registeredAt).toISOString() : null,
      lastHeartbeat: this.nodeData.lastHeartbeat ? new Date(this.nodeData.lastHeartbeat).toISOString() : null,
      totalHeartbeats: this.nodeData.totalHeartbeats,
      nextHeartbeat: this.nodeData.lastHeartbeat ? new Date(this.nodeData.lastHeartbeat + 3600000).toISOString() : null
    };
  }
}

module.exports = SparkNode;
