# ArcProof

## Digital service escrow, settled in USDC on Arc.

ArcProof is a testnet demo for digital-service escrow on Arc. A client can create a service agreement, lock USDC into a smart contract, let a freelancer or AI service provider submit delivery proof, and release payment after the work is approved.

> Status: testnet prototype. Not audited. Do not use with real funds.

## Live demo

- Frontend: `PASTE_VERCEL_OR_NETLIFY_URL`
- Contract: `PASTE_ARCSCAN_CONTRACT_URL`
- Verified source: `PASTE_ARCSCAN_VERIFIED_URL`

Add one screenshot or short GIF after deployment:

```text
docs/arcproof-demo.gif
```

## Problem

Remote digital work still has a basic trust problem.

Clients do not want to pay before they see the promised work. Freelancers, developers, designers, and AI service providers do not want to deliver work and then chase payment. Centralized marketplaces reduce this risk, but they add custody, platform rules, delays, and high fees.

ArcProof uses on-chain escrow to make the settlement process transparent:

```text
Client creates agreement
  -> Client approves and funds USDC escrow
  -> Provider submits delivery proof
  -> Client or evaluator approves the work
  -> Smart contract releases USDC to provider
```

If there is a dispute, funds stay locked until the arbiter resolves the job with a full release, full refund, or percentage split.

## Why Arc

ArcProof is built for Arc because this use case is naturally stablecoin-native.

- Digital services are usually priced in dollars, so USDC settlement is easier for users to understand.
- Arc Testnet uses USDC as the gas token, which keeps the payment story simple: fund in USDC, pay gas in USDC, settle in USDC.
- Arc is EVM-compatible, so the demo can use familiar wallets, Solidity contracts, ERC-20 approvals, and Arcscan links.
- The product fits future AI agent workflows, where autonomous agents or human operators need programmable payment after verified delivery.

## Why not a normal freelance marketplace?

Traditional platforms such as Upwork or Fiverr are useful, but they are centralized intermediaries. They control account access, payment release, dispute rules, and platform fees.

ArcProof explores a lighter alternative:

- No platform custody after funds enter the smart contract.
- Clear on-chain job state and payment history.
- USDC-based settlement instead of platform credit balances.
- Portable delivery evidence through URLs, Git commits, IPFS CIDs, or file hashes.
- Lower platform overhead for small cross-border digital jobs.

This is not meant to replace full marketplaces yet. It is a settlement primitive that could sit under freelancer tools, AI agent marketplaces, or service DAOs.

## Core features

- Arc Testnet wallet connection with MetaMask, Rabby, or another injected wallet.
- Demo mode that works without a deployed contract.
- Live mode through `VITE_ARCPROOF_ESCROW_ADDRESS`.
- USDC approval and escrow funding.
- Delivery proof hashing with `keccak256`.
- Client or evaluator approval.
- Dispute state with arbiter-controlled split settlement.
- Expired funded jobs can be refunded by the client.
- Arcscan transaction links.
- Foundry deployment script and starter tests.

## Smart contract summary

Contract: `ArcProofEscrow.sol`

Main functions:

```text
createJob()
fundJob()
submitDeliverable()
completeJob()
openDispute()
resolveDispute()
refundExpired()
getJob()
```

Job states:

```text
Open       - Agreement created, not funded yet
Funded     - USDC is locked in escrow
Delivered  - Provider submitted delivery proof
Completed  - Provider was paid
Disputed   - Funds are locked for arbiter review
Refunded   - Client was refunded
```

Security notes:

- The contract uses a simple non-reentrancy guard on functions that transfer USDC.
- Solidity `0.8.24` provides checked arithmetic by default.
- Funds move only through the configured USDC ERC-20 interface.
- The provider, evaluator, and arbiter roles are fixed for a job/deployment.
- This is still a prototype and has not been audited.

## Arbitration model

Either the client or provider can open a dispute while the job is funded or delivered. Once disputed, normal release is blocked.

The arbiter can resolve the dispute with `resolveDispute(jobId, providerBps)`.

Examples:

```text
providerBps = 10000  -> full payment to provider
providerBps = 0      -> full refund to client
providerBps = 5000   -> 50/50 split
```

The current version uses a single arbiter address set at deployment. Future versions can replace this with multi-arbiter review, optimistic dispute resolution, or DAO-based arbitration.

## Contract addresses

| Network | Contract | Address | Status |
|---|---|---|---|
| Arc Testnet | ArcProofEscrow | `PASTE_DEPLOYED_CONTRACT_ADDRESS` | `Pending verification` |
| Arc Testnet | USDC ERC-20 interface | `0x3600000000000000000000000000000000000000` | Arc testnet asset |

## Arc Testnet configuration

```text
Network: Arc Testnet
Chain ID: 5042002
RPC: https://rpc.testnet.arc.network
Explorer: https://testnet.arcscan.app
Gas token: USDC
USDC ERC-20 interface: 0x3600000000000000000000000000000000000000
```

## Local development

```bash
npm install
cp .env.example .env
npm run dev
```

Open the Vite URL, usually:

```text
http://127.0.0.1:5173
```

If `VITE_ARCPROOF_ESCROW_ADDRESS` is empty, ArcProof runs in demo mode and stores data in browser local storage.

## Frontend deployment

Vercel settings:

```text
Framework preset: Vite
Build command: npm run build
Output directory: dist
Node version: 20.19 or newer
```

Netlify settings:

```text
Build command: npm run build
Publish directory: dist
Node version: 20.19 or newer
```

Environment variable:

```env
VITE_ARCPROOF_ESCROW_ADDRESS=0xYourDeployedContract
```

Leave it empty for demo mode.

## Contract development

```bash
cd contracts
forge install foundry-rs/forge-std --no-commit
forge test
```

Deploy:

```bash
cp .env.example .env
# Fill PRIVATE_KEY and optionally ARBITER in contracts/.env
forge script script/DeployArcProof.s.sol:DeployArcProof \
  --rpc-url arc_testnet \
  --broadcast \
  --private-key "$PRIVATE_KEY"
```

## Verify on Arcscan

After deployment, verify the source code on Arcscan so reviewers can compare the deployed bytecode with this repository.

Verification inputs:

```text
Contract: ArcProofEscrow
Compiler: Solidity 0.8.24
License: MIT
Constructor usdc_: 0x3600000000000000000000000000000000000000
Constructor arbiter_: your deployment arbiter address
```

Keep the deployment output in `contracts/broadcast/` until verification is complete.

## Project structure

```text
arcproof/
+-- contracts/
|   +-- src/ArcProofEscrow.sol
|   +-- script/DeployArcProof.s.sol
|   +-- test/ArcProofEscrow.t.sol
+-- deployments/
+-- src/
|   +-- App.tsx
|   +-- lib/arc.ts
|   +-- lib/abi.ts
|   +-- lib/demo.ts
+-- README.md
```

## Current status

- Frontend demo mode is ready for public deployment.
- Live mode supports an Arc Testnet escrow contract address.
- The frontend reads the real on-chain `jobId` from the `JobCreated` event.
- Contract includes escrow, delivery proof, release, dispute split, and expired refund flows.
- Starter Foundry tests are included.

## Roadmap

- Deploy frontend to Vercel.
- Deploy and verify `ArcProofEscrow` on Arc Testnet.
- Add README screenshot or short product GIF.
- Add IPFS or encrypted evidence upload.
- Add milestone-based escrow.
- Add provider profiles and reputation.
- Explore multi-arbiter or optimistic dispute resolution.
