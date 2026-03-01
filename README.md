# ⚡ Spark Chain (SPARK)

**The energy token powering the AI internet economy.**

> Every Spark represents real value — no wasted electricity, no pointless hash puzzles.

## What is Spark?

Spark is the native token of the Aionex network — a blockchain built for AI agents. It enables AI assistants to own assets, transact with each other, and participate in a decentralized economy.

**Get Started:**
1. Install Spark Node client
2. Run a node and start mining
3. Earn SPARK through Proof of Contribution
4. First 10,000 miners get 100,000 SPARK bonus!

## Core Principles

- **Proof of Contribution** — Tokens are released through real ecosystem contributions (storage, bandwidth, validation), not energy-wasting mining
- **AI-Native Economy** — Every AI instance gets a wallet, enabling autonomous economic activity
- **Decentralized & Fair** — Anti-monopoly mechanisms ensure fair distribution across all node types

## Token Info

| Property | Value |
|---|---|
| Name | Spark |
| Symbol | SPARK |
| Total Supply | 1,000,000,000,000 (1 Trillion) |
| Framework | Substrate (Rust) |
| Consensus | PoS + Proof of Contribution |

## Token Distribution

| Allocation | Percentage | Amount | Purpose |
|---|---|---|---|
| Community Rewards | 50% | 500B SPARK | Mining, airdrops, staking rewards |
| Ecosystem Fund | 30% | 300B SPARK | Development grants, partnerships, liquidity |
| Team | 20% | 200B SPARK | Core team (4-year vesting with 1-year cliff) |

**No pre-sale, no private sale, no VC allocation. 100% fair launch.**

**Vesting Schedule:**
- Community Rewards: Released through mining (15 years), airdrops, and staking
- Ecosystem Fund: Controlled by DAO governance
- Team: 1-year cliff, then linear vesting over 4 years

**Want to invest? Buy on the open market after launch!**

## Early Adopter Airdrop 🎁

**First 10,000 miners get 100,000 SPARK bonus!**

### How to Qualify (Anti-Sybil Protection)

1. **Install Spark Node** - Download and install the Spark node client
2. **Mine 100+ SPARK** - Prove you're a real miner (prevents multi-wallet attacks)
3. **Stay Online 7 Days** - Keep your node running (prevents bot farming)
4. **Claim Bonus** - Receive 100,000 SPARK (locked for 3 months)

**Requirements:**
- ✅ Must mine at least **100 SPARK**
- ✅ Node must be online for **7+ days**
- ✅ Tokens **locked for 3 months** after claim
- ✅ First 10,000 addresses only
- ✅ One claim per address

**Total Pool:** 1,000,000,000 SPARK (10,000 × 100,000)

**Why these requirements?** To ensure only real, committed miners get the airdrop and prevent abuse.

## Architecture

- **Full Nodes** — Infrastructure providers, store full chain data, highest rewards
- **Light Nodes** — Regular users running Spark nodes, moderate rewards
- **Micro Nodes** — Mobile/light devices, small rewards for staying online

## Roadmap

1. **Phase 1** — Token launch + node network
2. **Phase 2** — AI-to-AI transactions + DEX listing
3. **Phase 3** — AI model provider integration
4. **Phase 4** — Full AI autonomous economy

## Documentation

- [Whitepaper (中文)](./WHITEPAPER.md)
- [Tokenomics](./TOKENOMICS.md)
- [Smart Contracts](./contracts/)
- [OpenClaw Plugin](./openclaw-plugin/)

## OpenClaw Plugin

Spark 提供了 OpenClaw 插件，让你的 AI 助手自动参与挖矿：

```bash
# 安装插件
cp -r openclaw-plugin /usr/lib/node_modules/openclaw/skills/spark
cd /usr/lib/node_modules/openclaw/skills/spark
npm install

# 初始化钱包
node src/index.js init

# 注册节点
node src/index.js register

# 设置自动心跳
crontab -e
# 添加: 0 * * * * bash /usr/lib/node_modules/openclaw/skills/spark/scripts/heartbeat.sh
```

详细说明：[openclaw-plugin/INSTALL.md](./openclaw-plugin/INSTALL.md)

## Built With

- [Substrate](https://substrate.io/) — Blockchain framework by Parity Technologies
- [Rust](https://www.rust-lang.org/) — Systems programming language

## License

MIT

---

**Aionex — Igniting the AI Era** 🔥
