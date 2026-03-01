# Spark Chain Smart Contracts

## 1. Early Adopter Airdrop V2 (防女巫攻击版)

**自动空投合约** - 前 10,000 个符合条件的矿工，每人获得 100,000 SPARK

### 领取条件（方案 E）

✅ **必须挖到至少 100 SPARK**（防止女巫攻击）  
✅ **节点在线至少 7 天**（防止机器人刷号）  
✅ **领到的代币锁仓 3 个月**（防止砸盘）

### 工作流程

```
1. 用户安装 Spark Node 客户端
   ↓
2. 运行节点挖矿，挖到 100+ SPARK
   ↓
3. 节点持续在线 7 天（每小时发送心跳）
   ↓
4. 调用 claim() 领取 100,000 SPARK
   ↓
5. 代币锁仓 3 个月后可提取
```

### 用户操作

#### 1. 注册节点

```javascript
// 首次运行节点时自动注册
await nodeRegistry.registerNode();
```

#### 2. 发送心跳（节点自动）

```javascript
// 节点每小时自动调用
await nodeRegistry.heartbeat();
```

#### 3. 检查资格

```javascript
const { eligible, reason, balance, onlineDays } = await airdrop.isEligible("你的地址");

console.log("是否符合:", eligible);
console.log("原因:", reason);
console.log("SPARK 余额:", balance);
console.log("在线天数:", onlineDays);
```

#### 4. 领取空投

```javascript
// 符合条件后领取（自动锁仓3个月）
await airdrop.claim();
```

#### 5. 提取代币（3个月后）

```javascript
// 查询可提取金额
const withdrawable = await airdrop.getWithdrawable("你的地址");

// 查询剩余锁仓时间
const timeLeft = await airdrop.getTimeUntilUnlock("你的地址");
console.log("还需等待:", timeLeft / 86400, "天");

// 解锁后提取
await airdrop.withdraw();
```

### 防作弊机制

| 攻击方式 | 防御措施 | 成本 |
|---------|---------|------|
| 女巫攻击（多钱包） | 每个地址需挖 100 SPARK | 需要真实算力 |
| 机器人刷号 | 节点必须在线 7 天 | 时间成本 |
| 领了就跑 | 锁仓 3 个月 | 流动性成本 |
| 假心跳 | 链上验证，无法伪造 | - |

### 示例场景

```
✅ 用户 A: 挖了 150 SPARK，在线 10 天 → 领取成功，3个月后提取
❌ 用户 B: 挖了 50 SPARK，在线 10 天 → 失败（余额不足）
❌ 用户 C: 挖了 200 SPARK，在线 5 天 → 失败（在线时长不够）
❌ 用户 D: 已领取过 → 失败（重复领取）
❌ 第 10,001 人 → 失败（名额已满）
```

---

## 2. Node Registry (节点注册合约)

**节点在线时长追踪合约** - 为空投提供验证

### 功能

- 节点注册
- 心跳上报（每小时）
- 在线时长统计
- 活跃节点统计

### 节点客户端集成

```javascript
// 启动时注册
if (!await nodeRegistry.nodes(myAddress).registeredAt) {
  await nodeRegistry.registerNode();
}

// 每小时发送心跳
setInterval(async () => {
  await nodeRegistry.heartbeat();
}, 3600000); // 1小时

// 查询在线时长
const onlineTime = await nodeRegistry.getNodeOnlineTime(myAddress);
const onlineDays = onlineTime / 86400;
console.log("在线天数:", onlineDays);
```

---

## 3. Early Investor Vesting (早期投资者锁仓)

**锁仓释放合约** - 管理早期投资者的 10% (100B SPARK) 代币

（详见之前的文档）

---

## 部署顺序

```bash
# 1. 部署节点注册合约
npx hardhat run scripts/deploy-node-registry.js --network spark

# 2. 部署空投合约（传入节点注册合约地址）
npx hardhat run scripts/deploy-airdrop-v2.js --network spark

# 3. 向空投合约转入 10 亿 SPARK
await sparkToken.transfer(airdropAddress, "1000000000000000000000000000");
```

## 合约地址（待部署）

- **NodeRegistry**: `待部署`
- **EarlyAdopterAirdropV2**: `待部署`
- **EarlyInvestorVesting**: `待部署`

## 安全审计

⚠️ 合约尚未经过专业审计，请谨慎使用。

## License

MIT
