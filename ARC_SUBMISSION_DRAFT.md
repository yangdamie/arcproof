# Arc Office Hours Submission Draft

## Project name

ArcProof

## One-line description

ArcProof is a digital-service escrow app on Arc Testnet that lets clients fund USDC, providers submit delivery proof, and evaluators release payment after the work is verified.

## Longer description

ArcProof solves a common trust problem in remote digital work: clients do not want to pay before receiving the promised work, while service providers do not want to deliver work and then be refused payment. The app creates an onchain service agreement, escrows USDC, stores a cryptographic hash of the delivery reference, and releases funds only after the client or evaluator approves.

The prototype includes a React/Vite frontend, wallet connection, Arc Testnet network switching, USDC approval and funding, delivery proof submission, release flow, dispute state, and a Solidity escrow contract with arbiter-controlled split settlement.

## Why this fits Arc

ArcProof is stablecoin-native by design. Digital-service work is priced in dollars, so USDC escrow is a natural product primitive. Arc's USDC gas and settlement story makes the UX easier to explain to non-crypto clients and providers: fund the job in USDC, pay gas in USDC, and settle in USDC.

Because Arc is EVM-compatible, ArcProof can use familiar wallets, ERC-20 approvals, Solidity contracts, and explorer links while focusing the product experience on practical stablecoin payments.

## Current status

- Frontend prototype is ready for Vercel/Netlify deployment after dependency installation.
- Demo mode works without a contract address.
- Live mode supports a deployed `ArcProofEscrow` contract address via `VITE_ARCPROOF_ESCROW_ADDRESS`.
- The frontend now reads the real onchain `jobId` from the `JobCreated` event, so follow-up actions target the correct escrow.
- Contract includes create, fund, submit delivery, complete, dispute, resolve split, and expired refund flows.
- Foundry starter tests are included for core lifecycle behavior.

## What I want feedback on

- Is digital-service escrow a strong early builder use case for Arc's stablecoin-native payments?
- What is the recommended Arc Testnet contract verification flow and how should verified contracts be presented for demos?
- Should the next milestone prioritize IPFS evidence upload, milestone payments, provider reputation, or dispute resolution design?
- What would make this project more compelling for real users in the Arc ecosystem?

## Demo links to add

- GitHub: `PASTE_GITHUB_URL`
- Frontend: `PASTE_VERCEL_OR_NETLIFY_URL`
- Contract: `PASTE_ARCSCAN_CONTRACT_URL`
- Demo video or screenshots: `PASTE_LINK`

## Safety note

This is a prototype and has not been audited. It should only be used on Arc Testnet with test funds.
