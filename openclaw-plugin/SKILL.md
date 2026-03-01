# Spark Node Skill

Spark 节点插件 - 让你的 AI 助手参与 Spark 网络挖矿，赚取 SPARK 代币。

## 功能

- 🔐 **钱包管理** - 创建/导入钱包，查询余额，发送交易
- ⛏️ **自动挖矿** - 后台运行节点，自动发送心跳，赚取 SPARK
- 🎁 **空投领取** - 前 10,000 名矿工可领取 100,000 SPARK
- 📊 **收益统计** - 实时显示挖矿收益和在线时长
- 💬 **聊天控制** - 通过自然语言管理钱包和节点

## 安装

```bash
# 插件已内置，无需额外安装
# 首次使用会自动初始化
```

## 使用

### 初始化钱包

```
你: 初始化 Spark 钱包
AI: 已为你创建新钱包！
    地址: 0x1234...5678
    请妥善保管助记词: word1 word2 word3...
```

### 查询余额

```
你: 查询 SPARK 余额
AI: 你的 SPARK 余额: 1,234.56 SPARK
    节点在线: 5 天 12 小时
    累计挖矿: 234.56 SPARK
```

### 领取空投

```
你: 领取 Spark 空投
AI: 检查资格中...
    ✅ 已挖到 150 SPARK
    ✅ 节点在线 8 天
    ✅ 符合条件！
    
    正在领取 100,000 SPARK...
    ✅ 领取成功！锁仓 3 个月后可提取。
```

### 发送交易

```
你: 发送 100 SPARK 到 0xabcd...
AI: 确认交易：
    接收地址: 0xabcd...
    金额: 100 SPARK
    Gas 费: ~0.01 SPARK
    
    是否确认？(yes/no)
```

## 后台服务

插件会自动：
- 每小时发送心跳到链上
- 统计在线时长
- 监控挖矿收益
- 检查空投资格

## 配置

配置文件: `~/.openclaw/skills/spark/config.json`

```json
{
  "rpc": "http://aispark.aionex.cc:9944",
  "chainId": 42,
  "heartbeatInterval": 3600,
  "autoStart": true
}
```

## 数据存储

- 钱包私钥: `~/.openclaw/skills/spark/data/wallet.enc` (加密)
- 节点数据: `~/.openclaw/skills/spark/data/node.json`
- 交易历史: `~/.openclaw/skills/spark/data/transactions.json`

## 安全提示

⚠️ **助记词和私钥非常重要！**
- 丢失无法找回
- 不要分享给任何人
- 建议离线备份

## 网络信息

- 链名: Spark Chain
- 代币: SPARK
- RPC: http://aispark.aionex.cc:9944
- Chain ID: 42
- 浏览器: (待上线)

## 空投规则

前 10,000 名矿工可领取 100,000 SPARK：
- ✅ 挖到至少 100 SPARK
- ✅ 节点在线至少 7 天
- ✅ 领取后锁仓 3 个月

## 挖矿收益

- 第 1-2 年: 每块 1000 SPARK
- 第 3-4 年: 每块 500 SPARK (减半)
- 每 2 年减半一次
- 15 年后转为手续费模式

## 故障排查

### 节点离线
```bash
# 检查节点状态
openclaw exec "node /usr/lib/node_modules/openclaw/skills/spark/src/node.js status"

# 重启节点
openclaw exec "node /usr/lib/node_modules/openclaw/skills/spark/src/node.js restart"
```

### 心跳失败
```bash
# 手动发送心跳
bash /usr/lib/node_modules/openclaw/skills/spark/scripts/heartbeat.sh
```

## 支持

- GitHub: https://github.com/JustinaHodges/spark-chain
- 文档: https://github.com/JustinaHodges/spark-chain/blob/main/README.md

## License

MIT
