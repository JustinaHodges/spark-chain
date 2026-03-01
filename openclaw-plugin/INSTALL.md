# Spark OpenClaw Plugin

OpenClaw 插件，让你的 AI 助手参与 Spark 网络挖矿，赚取 SPARK 代币。

## 功能

- 🔐 **钱包管理** - 创建/导入钱包，查询余额，发送交易
- ⛏️ **自动挖矿** - 后台运行节点，自动发送心跳，赚取 SPARK
- 🎁 **空投领取** - 前 10,000 名矿工可领取 100,000 SPARK
- 📊 **收益统计** - 实时显示挖矿收益和在线时长
- 💬 **聊天控制** - 通过自然语言管理钱包和节点

## 安装

### 方法 1：复制到 OpenClaw skills 目录

```bash
# 复制插件到 OpenClaw
cp -r openclaw-plugin /usr/lib/node_modules/openclaw/skills/spark

# 安装依赖
cd /usr/lib/node_modules/openclaw/skills/spark
npm install

# 设置密码
echo "your_strong_password" > ~/.openclaw/spark_password
chmod 600 ~/.openclaw/spark_password
```

### 方法 2：符号链接（开发模式）

```bash
# 创建符号链接
ln -s $(pwd)/openclaw-plugin /usr/lib/node_modules/openclaw/skills/spark

# 安装依赖
cd openclaw-plugin
npm install
```

## 快速开始

### 1. 初始化钱包

```bash
cd /usr/lib/node_modules/openclaw/skills/spark
SPARK_PASSWORD=$(cat ~/.openclaw/spark_password) node src/index.js init
```

**⚠️ 重要：请备份显示的助记词！**

### 2. 注册节点

```bash
SPARK_PASSWORD=$(cat ~/.openclaw/spark_password) node src/index.js register
```

### 3. 设置自动心跳

```bash
# 编辑 crontab
crontab -e

# 添加这一行（每小时发送心跳）
0 * * * * bash /usr/lib/node_modules/openclaw/skills/spark/scripts/heartbeat.sh
```

### 4. 查询状态

```bash
SPARK_PASSWORD=$(cat ~/.openclaw/spark_password) node src/index.js status
```

## 命令行接口

```bash
# 初始化钱包
node src/index.js init

# 查询余额
node src/index.js balance

# 注册节点
node src/index.js register

# 发送心跳
node src/index.js heartbeat

# 完整状态
node src/index.js status

# 检查空投资格
node src/index.js airdrop-check

# 领取空投
node src/index.js airdrop-claim
```

## 通过 OpenClaw 使用

在 OpenClaw 聊天中：

```
你: 初始化 Spark 钱包
AI: (调用 spark skill，创建钱包)

你: 查询 SPARK 余额
AI: (显示余额和节点状态)

你: 领取 Spark 空投
AI: (检查资格并领取)
```

## 空投规则

前 10,000 名矿工可领取 100,000 SPARK：

- ✅ 挖到至少 100 SPARK
- ✅ 节点在线至少 7 天
- ✅ 领取后锁仓 3 个月

## 合约地址

### 主网（待上线）

- SparkToken (ERC20): `待部署`
- NodeRegistry: `待部署`
- EarlyAdopterAirdropV2: `待部署`

### 测试网

- SparkToken (ERC20): `0x3649E46eCD6A0bd187f0046C4C35a7B31C92bA1E`
- NodeRegistry: `0x970951a12F975E6762482ACA81E57D5A2A4e73F4`
- EarlyAdopterAirdropV2: `0xb6F2B9415fc599130084b7F20B84738aCBB15930`

## 网络信息

- 链名: Spark Chain
- 代币: SPARK
- RPC: http://aispark.aionex.cc:9944
- Chain ID: 42
- 浏览器: (待上线)

## 目录结构

```
openclaw-plugin/
├── README.md              # 本文件
├── SKILL.md               # OpenClaw 技能说明
├── package.json           # 依赖配置
├── .gitignore
├── src/
│   ├── index.js           # 主入口
│   ├── wallet.js          # 钱包管理
│   ├── node.js            # 节点功能
│   └── airdrop.js         # 空投管理
├── scripts/
│   └── heartbeat.sh       # 心跳脚本
└── data/                  # 数据目录（不提交到 git）
    ├── wallet.enc         # 加密钱包
    ├── node.json          # 节点数据
    └── config.json        # 配置
```

## 安全提示

1. **密码文件权限**：`chmod 600 ~/.openclaw/spark_password`
2. **备份助记词**：离线保存，不要截图或发送
3. **定期备份**：`data/` 目录
4. **不要分享**：私钥、助记词、密码

## 故障排查

### 心跳失败

```bash
# 查看日志
tail -f /var/log/spark-heartbeat.log

# 手动测试
bash /usr/lib/node_modules/openclaw/skills/spark/scripts/heartbeat.sh
```

### 钱包问题

```bash
# 检查钱包文件
ls -la /usr/lib/node_modules/openclaw/skills/spark/data/

# 重新创建（会丢失旧钱包！）
rm data/wallet.enc
node src/index.js init
```

## 开发

```bash
# 安装依赖
npm install

# 运行测试
npm test

# 查看日志
tail -f /var/log/spark-heartbeat.log
```

## 相关链接

- [Spark Chain GitHub](https://github.com/JustinaHodges/spark-chain)
- [白皮书](../WHITEPAPER.md)
- [经济模型](../TOKENOMICS.md)
- [智能合约](../contracts/)

## License

MIT
