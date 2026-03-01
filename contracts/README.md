# Early Investor Vesting Contract

早期投资者代币锁仓合约，管理 10% (100B SPARK) 的代币分配。

## 功能特性

- ✅ 总量控制：100,000,000,000 SPARK (10%)
- ✅ 锁仓期：6个月 cliff
- ✅ 线性释放：2年线性解锁
- ✅ 批量注册：支持批量添加投资者
- ✅ 自动计算：自动计算可领取金额
- ✅ 安全保护：防止超额分配

## 使用流程

### 1. 部署合约

```javascript
// 部署时传入 SPARK 代币地址
const vesting = await EarlyInvestorVesting.deploy(sparkTokenAddress);
```

### 2. 注册投资者

```javascript
// 单个注册
await vesting.registerInvestor(
  "0x投资者地址",
  1000000000  // 10亿 SPARK
);

// 批量注册
await vesting.registerInvestorsBatch(
  ["0x地址1", "0x地址2", "0x地址3"],
  [1000000000, 2000000000, 500000000]  // 单位：SPARK
);
```

### 3. 启动释放计划

```javascript
await vesting.startVesting();
// 从此刻开始计时：6个月后开始释放，2年内线性解锁
```

### 4. 投资者领取代币

```javascript
// 查询可领取金额
const claimable = await vesting.getClaimableAmount("0x投资者地址");

// 领取
await vesting.claim();
```

## 时间线示例

假设 2026-03-01 启动释放计划：

- **2026-03-01**: 启动，开始计时
- **2026-09-01**: 6个月锁仓期结束，开始线性释放
- **2027-03-01**: 1年，已释放 25%
- **2027-09-01**: 1.5年，已释放 50%
- **2028-03-01**: 2年，已释放 75%
- **2028-09-01**: 2.5年，全部释放完毕 (100%)

## 查询接口

```javascript
// 查询投资者信息
const info = await vesting.getInvestorInfo("0x地址");
// 返回: { allocation, claimed, claimable, registered }

// 查询总分配额度
const total = await vesting.getTotalAllocated();

// 查询投资者数量
const count = await vesting.getInvestorCount();
```

## 安全特性

1. **防超额分配**: 总分配不能超过 100B SPARK
2. **锁仓保护**: 6个月内无法领取
3. **线性释放**: 避免砸盘风险
4. **Owner控制**: 只有owner可以注册投资者和启动释放
5. **紧急提取**: 支持紧急情况下的资金迁移

## 部署到 Spark Chain

```bash
# 1. 编译合约
npx hardhat compile

# 2. 部署
npx hardhat run scripts/deploy-vesting.js --network spark

# 3. 验证合约
npx hardhat verify --network spark <合约地址> <SPARK代币地址>
```

## License

MIT
