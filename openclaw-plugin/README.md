# Spark OpenClaw 插件

## 快速开始

### 1. 初始化钱包

```bash
# 设置密码（请使用强密码）
echo "your_strong_password" > ~/.openclaw/spark_password
chmod 600 ~/.openclaw/spark_password

# 创建钱包
cd /usr/lib/node_modules/openclaw/skills/spark
SPARK_PASSWORD=$(cat ~/.openclaw/spark_password) node src/index.js init
```

**重要：请备份显示的助记词！**

### 2. 注册节点

```bash
SPARK_PASSWORD=$(cat ~/.openclaw/spark_password) node src/index.js register
```

### 3. 设置自动心跳（Cron）

```bash
# 每小时发送心跳
crontab -e

# 添加这一行：
0 * * * * bash /usr/lib/node_modules/openclaw/skills/spark/scripts/heartbeat.sh
```

### 4. 查询状态

```bash
SPARK_PASSWORD=$(cat ~/.openclaw/spark_password) node src/index.js status
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

## 目录结构

```
/usr/lib/node_modules/openclaw/skills/spark/
├── SKILL.md              # 技能说明
├── README.md             # 本文件
├── package.json
├── src/
│   ├── index.js          # 主入口
│   ├── wallet.js         # 钱包管理
│   ├── node.js           # 节点功能
│   └── airdrop.js        # 空投管理
├── scripts/
│   └── heartbeat.sh      # 心跳脚本
└── data/                 # 数据目录
    ├── wallet.enc        # 加密钱包
    ├── node.json         # 节点数据
    └── config.json       # 配置
```

## 配置

编辑 `data/config.json`：

```json
{
  "rpc": "http://aispark.aionex.cc:9944",
  "chainId": 42
}
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

## 下一步

- [ ] 部署 NodeRegistry 合约
- [ ] 部署 EarlyAdopterAirdropV2 合约
- [ ] 更新合约地址到代码中
- [ ] 配置区块奖励
- [ ] 开发 Mac GUI 版本

## License

MIT
