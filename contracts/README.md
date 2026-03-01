# Spark Chain Smart Contracts

## 1. Early Adopter Airdrop (早期用户空投)

**自动空投合约** - 前 10,000 个持有 SPARK 的地址，每个自动获得 100,000 SPARK

### 特性

- ✅ **零门槛**: 只要持有任意数量的 SPARK 就能领取
- ✅ **自动检测**: 合约自动检测持币地址
- ✅ **先到先得**: 前 10,000 个领取的地址获得空投
- ✅ **一键领取**: 调用 `claim()` 即可
- ✅ **防重复**: 每个地址只能领取一次

### 使用方法

#### 用户领取空投

```javascript
// 1. 检查是否符合条件
const eligible = await airdrop.isEligible("你的地址");

// 2. 查看剩余名额
const remaining = await airdrop.getRemainingSlots();

// 3. 领取空投
await airdrop.claim();
```

#### 部署合约

```javascript
// 部署时传入 SPARK 代币地址
const airdrop = await EarlyAdopterAirdrop.deploy(sparkTokenAddress);

// 向合约转入 10 亿 SPARK (10,000 * 100,000)
await sparkToken.transfer(airdrop.address, "1000000000000000000000000000");
```

### 工作流程

1. **用户持有 SPARK** → 通过转账、挖矿等方式获得任意数量 SPARK
2. **调用 claim()** → 合约自动检测余额 > 0
3. **自动发放** → 立即收到 100,000 SPARK
4. **名额满** → 前 10,000 人领完后自动结束

### 示例场景

```
用户 A: 持有 1 SPARK → 调用 claim() → 获得 100,000 SPARK ✅
用户 B: 持有 0 SPARK → 调用 claim() → 失败 ❌
用户 C: 已领取过 → 再次调用 → 失败 ❌
第 10,001 人 → 调用 claim() → 失败（名额已满）❌
```

---

## 2. Early Investor Vesting (早期投资者锁仓)

**锁仓释放合约** - 管理早期投资者的 10% (100B SPARK) 代币

### 特性

- ✅ 总量控制：100,000,000,000 SPARK (10%)
- ✅ 锁仓期：6个月 cliff
- ✅ 线性释放：2年线性解锁
- ✅ 批量注册：支持批量添加投资者

### 使用方法

#### 注册投资者

```javascript
// 单个注册
await vesting.registerInvestor(
  "0x投资者地址",
  1000000000  // 10亿 SPARK
);

// 批量注册
await vesting.registerInvestorsBatch(
  ["0x地址1", "0x地址2"],
  [1000000000, 2000000000]
);
```

#### 启动释放

```javascript
await vesting.startVesting();
// 从此刻开始：6个月后开始释放，2年内线性解锁
```

#### 投资者领取

```javascript
// 查询可领取金额
const claimable = await vesting.getClaimableAmount("0x地址");

// 领取
await vesting.claim();
```

### 时间线

- **Day 0**: 启动释放计划
- **Month 6**: 锁仓期结束，开始线性释放
- **Year 1**: 已释放 25%
- **Year 1.5**: 已释放 50%
- **Year 2**: 已释放 75%
- **Year 2.5**: 全部释放完毕 (100%)

---

## 部署到 Spark Chain

```bash
# 1. 安装依赖
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox

# 2. 编译合约
npx hardhat compile

# 3. 部署空投合约
npx hardhat run scripts/deploy-airdrop.js --network spark

# 4. 部署锁仓合约
npx hardhat run scripts/deploy-vesting.js --network spark
```

## 合约地址（待部署）

- **EarlyAdopterAirdrop**: `待部署`
- **EarlyInvestorVesting**: `待部署`

## 安全审计

⚠️ 合约尚未经过专业审计，请谨慎使用。

## License

MIT
