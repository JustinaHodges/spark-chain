const SparkWallet = require('./wallet');
const SparkNode = require('./node');
const SparkAirdrop = require('./airdrop');

class SparkSkill {
  constructor() {
    this.wallet = new SparkWallet();
    this.node = new SparkNode();
    this.airdrop = new SparkAirdrop();
  }

  // 初始化（创建钱包）
  async init(password) {
    try {
      const result = await this.wallet.createWallet(password);
      return {
        success: true,
        message: '✅ Spark 钱包创建成功！',
        address: result.address,
        mnemonic: result.mnemonic,
        warning: '⚠️ 请妥善保管助记词，丢失无法找回！'
      };
    } catch (error) {
      return {
        success: false,
        message: error.message
      };
    }
  }

  // 导入钱包
  async import(mnemonic, password) {
    try {
      const result = await this.wallet.importWallet(mnemonic, password);
      return {
        success: true,
        message: '✅ 钱包导入成功！',
        address: result.address
      };
    } catch (error) {
      return {
        success: false,
        message: error.message
      };
    }
  }

  // 查询余额
  async balance(password) {
    try {
      const balance = await this.wallet.getBalance(password);
      const walletInstance = await this.wallet.loadWallet(password);
      return {
        success: true,
        address: walletInstance.address,
        balance: balance,
        formatted: `${parseFloat(balance).toLocaleString()} SPARK`
      };
    } catch (error) {
      return {
        success: false,
        message: error.message
      };
    }
  }

  // 发送交易
  async send(to, amount, password) {
    try {
      const txHash = await this.wallet.sendTransaction(to, amount, password);
      return {
        success: true,
        message: '✅ 交易发送成功！',
        txHash,
        to,
        amount
      };
    } catch (error) {
      return {
        success: false,
        message: error.message
      };
    }
  }

  // 注册节点
  async registerNode(password) {
    return await this.node.register(password);
  }

  // 发送心跳
  async heartbeat(password) {
    return await this.node.sendHeartbeat(password);
  }

  // 查询节点状态
  async nodeStatus(password) {
    return await this.node.getStatus(password);
  }

  // 查询在线时长
  async onlineTime(password) {
    return await this.node.getOnlineTime(password);
  }

  // 检查空投资格
  async checkAirdrop(password) {
    return await this.airdrop.checkEligibility(password);
  }

  // 领取空投
  async claimAirdrop(password) {
    return await this.airdrop.claim(password);
  }

  // 提取空投
  async withdrawAirdrop(password) {
    return await this.airdrop.withdraw(password);
  }

  // 空投状态
  async airdropStatus(password) {
    return await this.airdrop.getStatus(password);
  }

  // 完整状态（一次性获取所有信息）
  async fullStatus(password) {
    try {
      const [balance, nodeStatus, onlineTime, airdropStatus] = await Promise.all([
        this.balance(password),
        this.nodeStatus(password),
        this.onlineTime(password).catch(() => ({ success: false })),
        this.airdropStatus(password).catch(() => ({ success: false }))
      ]);

      return {
        success: true,
        wallet: balance,
        node: nodeStatus,
        onlineTime: onlineTime.success ? onlineTime : null,
        airdrop: airdropStatus.success ? airdropStatus : null
      };
    } catch (error) {
      return {
        success: false,
        message: error.message
      };
    }
  }
}

module.exports = SparkSkill;

// CLI 支持
if (require.main === module) {
  const spark = new SparkSkill();
  const command = process.argv[2];
  const password = process.env.SPARK_PASSWORD || 'default_password'; // 生产环境应该安全获取

  (async () => {
    let result;
    
    switch (command) {
      case 'init':
        result = await spark.init(password);
        break;
      case 'balance':
        result = await spark.balance(password);
        break;
      case 'register':
        result = await spark.registerNode(password);
        break;
      case 'heartbeat':
        result = await spark.heartbeat(password);
        break;
      case 'status':
        result = await spark.fullStatus(password);
        break;
      case 'airdrop-check':
        result = await spark.checkAirdrop(password);
        break;
      case 'airdrop-claim':
        result = await spark.claimAirdrop(password);
        break;
      default:
        console.log('Usage: node index.js [init|balance|register|heartbeat|status|airdrop-check|airdrop-claim]');
        process.exit(1);
    }

    console.log(JSON.stringify(result, null, 2));
  })();
}
