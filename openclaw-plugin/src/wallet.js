const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const DATA_DIR = path.join(__dirname, '../data');
const WALLET_FILE = path.join(DATA_DIR, 'wallet.enc');
const CONFIG_FILE = path.join(DATA_DIR, 'config.json');

// 默认配置
const DEFAULT_CONFIG = {
  rpc: 'http://aispark.aionex.cc:9944',
  chainId: 42,
  password: null // 用户设置的密码
};

class SparkWallet {
  constructor() {
    this.provider = null;
    this.wallet = null;
    this.config = this.loadConfig();
  }

  // 加载配置
  loadConfig() {
    if (fs.existsSync(CONFIG_FILE)) {
      return JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
    }
    return DEFAULT_CONFIG;
  }

  // 保存配置
  saveConfig() {
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(this.config, null, 2));
  }

  // 初始化 Provider
  async initProvider() {
    if (!this.provider) {
      this.provider = new ethers.JsonRpcProvider(this.config.rpc);
    }
    return this.provider;
  }

  // 加密私钥
  encrypt(privateKey, password) {
    const algorithm = 'aes-256-cbc';
    const key = crypto.scryptSync(password, 'salt', 32);
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(algorithm, key, iv);
    let encrypted = cipher.update(privateKey, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return iv.toString('hex') + ':' + encrypted;
  }

  // 解密私钥
  decrypt(encrypted, password) {
    const algorithm = 'aes-256-cbc';
    const key = crypto.scryptSync(password, 'salt', 32);
    const parts = encrypted.split(':');
    const iv = Buffer.from(parts[0], 'hex');
    const encryptedText = parts[1];
    const decipher = crypto.createDecipheriv(algorithm, key, iv);
    let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  }

  // 创建新钱包
  async createWallet(password) {
    if (fs.existsSync(WALLET_FILE)) {
      throw new Error('钱包已存在！如需创建新钱包，请先备份并删除旧钱包。');
    }

    // 生成随机钱包
    const wallet = ethers.Wallet.createRandom();
    
    // 加密并保存私钥
    const encrypted = this.encrypt(wallet.privateKey, password);
    fs.writeFileSync(WALLET_FILE, encrypted);

    // 保存密码哈希（用于验证）
    this.config.password = crypto.createHash('sha256').update(password).digest('hex');
    this.saveConfig();

    return {
      address: wallet.address,
      mnemonic: wallet.mnemonic.phrase
    };
  }

  // 导入钱包（通过助记词）
  async importWallet(mnemonic, password) {
    if (fs.existsSync(WALLET_FILE)) {
      throw new Error('钱包已存在！如需导入新钱包，请先备份并删除旧钱包。');
    }

    // 从助记词恢复钱包
    const wallet = ethers.Wallet.fromPhrase(mnemonic);
    
    // 加密并保存私钥
    const encrypted = this.encrypt(wallet.privateKey, password);
    fs.writeFileSync(WALLET_FILE, encrypted);

    // 保存密码哈希
    this.config.password = crypto.createHash('sha256').update(password).digest('hex');
    this.saveConfig();

    return {
      address: wallet.address
    };
  }

  // 加载钱包
  async loadWallet(password) {
    if (!fs.existsSync(WALLET_FILE)) {
      throw new Error('钱包不存在！请先创建或导入钱包。');
    }

    // 验证密码
    const passwordHash = crypto.createHash('sha256').update(password).digest('hex');
    if (this.config.password && passwordHash !== this.config.password) {
      throw new Error('密码错误！');
    }

    // 解密私钥
    const encrypted = fs.readFileSync(WALLET_FILE, 'utf8');
    const privateKey = this.decrypt(encrypted, password);

    // 创建钱包实例
    await this.initProvider();
    this.wallet = new ethers.Wallet(privateKey, this.provider);

    return this.wallet;
  }

  // 查询余额
  async getBalance(password) {
    await this.loadWallet(password);
    const balance = await this.provider.getBalance(this.wallet.address);
    return ethers.formatEther(balance);
  }

  // 发送交易
  async sendTransaction(to, amount, password) {
    await this.loadWallet(password);

    const tx = await this.wallet.sendTransaction({
      to: to,
      value: ethers.parseEther(amount.toString())
    });

    await tx.wait();
    return tx.hash;
  }

  // 获取地址
  getAddress(password) {
    if (!fs.existsSync(WALLET_FILE)) {
      return null;
    }
    // 从加密文件中提取地址（不需要解密）
    // 这里简化处理，实际应该存储地址
    return this.wallet ? this.wallet.address : null;
  }
}

module.exports = SparkWallet;
