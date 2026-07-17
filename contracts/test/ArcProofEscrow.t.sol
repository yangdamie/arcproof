// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/ArcProofEscrow.sol";

contract MockUSDC {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        if (balanceOf[msg.sender] < amount) return false;
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        if (balanceOf[sender] < amount) return false;
        if (allowance[sender][msg.sender] < amount) return false;
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }
}

contract ArcProofEscrowTest is Test {
    MockUSDC internal usdc;
    ArcProofEscrow internal escrow;

    address internal client = address(0xA11CE);
    address internal provider = address(0xB0B);
    address internal evaluator = address(0xE0A1);
    address internal arbiter = address(0xA4B17E2);

    uint96 internal constant AMOUNT = 500e6;
    bytes32 internal constant DESCRIPTION_HASH = keccak256("service scope");
    bytes32 internal constant DELIVERABLE_HASH = keccak256("ipfs://delivery");

    function setUp() public {
        usdc = new MockUSDC();
        escrow = new ArcProofEscrow(address(usdc), arbiter);
        usdc.mint(client, 2_000e6);
    }

    function _createAndFund() internal returns (uint256 jobId) {
        vm.prank(client);
        jobId = escrow.createJob(provider, evaluator, AMOUNT, uint64(block.timestamp + 7 days), DESCRIPTION_HASH);

        vm.prank(client);
        usdc.approve(address(escrow), AMOUNT);

        vm.prank(client);
        escrow.fundJob(jobId);
    }

    function testClientCanFundProviderCanDeliverAndEvaluatorCanRelease() public {
        uint256 jobId = _createAndFund();

        vm.prank(provider);
        escrow.submitDeliverable(jobId, DELIVERABLE_HASH);

        vm.prank(evaluator);
        escrow.completeJob(jobId);

        ArcProofEscrow.Job memory job = escrow.getJob(jobId);
        assertEq(uint8(job.state), uint8(ArcProofEscrow.JobState.Completed));
        assertEq(usdc.balanceOf(provider), AMOUNT);
    }

    function testArbiterCanResolveDisputeWithSplit() public {
        uint256 jobId = _createAndFund();

        vm.prank(provider);
        escrow.openDispute(jobId);

        vm.prank(arbiter);
        escrow.resolveDispute(jobId, 4_000);

        assertEq(usdc.balanceOf(provider), 200e6);
        assertEq(usdc.balanceOf(client), 1_800e6);
    }

    function testClientCanRefundExpiredFundedJob() public {
        uint256 jobId = _createAndFund();

        vm.warp(block.timestamp + 8 days);

        vm.prank(client);
        escrow.refundExpired(jobId);

        ArcProofEscrow.Job memory job = escrow.getJob(jobId);
        assertEq(uint8(job.state), uint8(ArcProofEscrow.JobState.Refunded));
        assertEq(usdc.balanceOf(client), 2_000e6);
    }

    function testUnauthorizedCallerCannotComplete() public {
        uint256 jobId = _createAndFund();

        vm.prank(provider);
        escrow.submitDeliverable(jobId, DELIVERABLE_HASH);

        vm.expectRevert(ArcProofEscrow.Unauthorized.selector);
        vm.prank(address(0xBAD));
        escrow.completeJob(jobId);
    }
}
