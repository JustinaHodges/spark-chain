const { ethers } = require('ethers');
const SparkWallet = require('./wallet');

// EarlyAdopterAirdropV2 合约地址（快速测试版）
const AIRDROP_ADDRESS = '0x294c664f6D63bd1521231a2EeFC26d805ce00a08';

// Airdrop ABI（简化版）
const AIRDROP_ABI = [
  'function claim() external',
  'function withdraw() external',
  'function isEligible(address) external view returns (bool, string, uint256, uint256)',
  'function getWithdrawable(address) external view returns (uint256)',
  'function getTimeUntilUnlock(address) external view returns (uint256)',
  'function hasReceived(address) external view returns (bool)',
  'function getRemainingSlots() external view returns (uint256)'
];

class SparkAirdrop {
  constructor() {
    this.wallet = new SparkWallet();
    this.provider = null;
    this.contract = null;
  }

  // 初始化合约
  async initContract(password) {
    const walletInstance = await this.wallet.loadWallet(password);
    this.provider = walletInstance.provider;
    this.contract = new ethers.Contract(
      AIRDROP_ADDRESS,
      AIRDROP_ABI,
      walletInstance
    );
    return this.contract;
  }

  // 检查空投资格
  async checkEligibility(password) {
    await this.initContract(password);
    const address = (await this.wallet.loadWallet(password)).address;

    try {
      const [eligible, reason, balance, onlineDays] = await this.contract.isEligible(address);

      return {
        success: true,
        eligible,
        reason,
        balance: ethers.formatEther(balance),
        onlineDays: Number(onlineDays),
        address
      };
    } catch (error) {
      return {
        success: false,
        message: `检查失败: ${error.message}`
      };
    }
  }

  // 领取空投
  async claim(password) {
    await this.initContract(password);

    try {
      // 先检查资格
      const eligibility = await this.checkEligibility(password);
      if (!eligibility.eligible) {
        return {
          success: false,
          message: `不符合条件: ${eligibility.reason}`
        };
      }

      // 领取
      const tx = await this.contract.claim();
      await tx.wait();

      return {
        success: true,
        message: '空投领取成功！100,000 SPARK 已锁仓，3个月后可提取',
        txHash: tx.hash,
        amount: '100000'
      };
    } catch (error) {
      return {
        success: false,
        message: `领取失败: ${error.message}`
      };
    }
  }

  // 提取解锁的代币
  async withdraw(password) {
    await this.initContract(password);
    const address = (await this.wallet.loadWallet(password)).address;

    try {
      // 检查可提取金额
      const withdrawable = await this.contract.getWithdrawable(address);
      if (withdrawable === 0n) {
        const timeLeft = await this.contract.getTimeUntilUnlock(address);
        const days = Number(timeLeft) / 86400;
        return {
          success: false,
          message: `还需等待 ${Math.ceil(days)} 天才能提取`
        };
      }

      // 提取
      const tx = await this.contract.withdraw();
      await tx.wait();

      return {
        success: true,
        message: '提取成功！',
        txHash: tx.hash,
        amount: ethers.formatEther(withdrawable)
      };
    } catch (error) {
      return {
        success: false,
        message: `提取失败: ${error.message}`
      };
    }
  }

  // 查询空投状态
  async getStatus(password) {
    await this.initContract(password);
    const address = (await this.wallet.loadWallet(password)).address;

    try {
      const hasReceived = await this.contract.hasReceived(address);
      const remainingSlots = await this.contract.getRemainingSlots();

      let withdrawable = 0n;
      let timeLeft = 0n;

      if (hasReceived) {
        withdrawable = await this.contract.getWithdrawable(address);
        timeLeft = await this.contract.getTimeUntilUnlock(address);
      }

      return {
        success: true,
        hasReceived,
        remainingSlots: Number(remainingSlots),
        withdrawable: ethers.formatEther(withdrawable),
        timeLeft: Number(timeLeft),
        daysLeft: Math.ceil(Number(timeLeft) / 86400),
        canWithdraw: withdrawable > 0n
      };
    } catch (error) {
      return {
        success: false,
        message: `查询失败: ${error.message}`
      };
    }
  }
}

module.exports = SparkAirdrop;
