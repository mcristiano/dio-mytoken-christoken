// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "remix_tests.sol";
import "remix_accounts.sol";
import "hardhat/console.sol";
import "../contracts/GenericToken.sol";

contract GenericTokenTest {
    GenericToken token;
    address acc0;
    address acc1;
    address acc2;

    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        
        // Print account balances
        console.log("Account 0 balance:", acc0.balance);
        console.log("Account 1 balance:", acc1.balance);
        console.log("Account 2 balance:", acc2.balance);
    }

    /// #sender: account-0
    function deployToken() public {
        console.log("Deploying token from account:", msg.sender);
        token = new GenericToken("Test Token", "TST", 18, 1000000 * 10**18);
        console.log("Token deployed at:", address(token));
        Assert.ok(address(token) != address(0), "Token deployment failed");
    }
    /// #sender: account-0
    function testInitialState() public {
        console.log("Testing initial state");
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("Token decimals:", token.decimals());
        console.log("Total supply:", token.totalSupply());
        console.log("Account 0 balance:", token.balanceOf(acc0));
        
        Assert.equal(token.name(), "Test Token", "Incorrect token name");
        Assert.equal(token.symbol(), "TST", "Incorrect token symbol");
        Assert.equal(token.decimals(), 18, "Incorrect decimals");
        Assert.equal(token.totalSupply(), 1000000 * 10**18, "Incorrect total supply");
        Assert.equal(token.balanceOf(acc0), 1000000 * 10**18, "Incorrect initial balance");
    }

    /// #sender: account-0
    function testTransfer() public {
        uint256 initialBalance = token.balanceOf(acc0);
        Assert.ok(token.transfer(acc1, 1000), "Transfer failed");
        Assert.equal(token.balanceOf(acc1), 1000, "Recipient balance incorrect");
        Assert.equal(token.balanceOf(acc0), initialBalance - 1000, "Sender balance incorrect");
    }

    /// #sender: account-0
    function testApprove() public {
        Assert.ok(token.approve(acc1, 500), "Approval failed");
        Assert.equal(token.allowance(acc0, acc1), 500, "Allowance not set correctly");
    }

    /// #sender: account-1
    function testTransferFrom() public {
        uint256 initialBalance0 = token.balanceOf(acc0);
        uint256 initialBalance1 = token.balanceOf(acc1);
        Assert.ok(token.transferFrom(acc0, acc2, 300), "TransferFrom failed");
        Assert.equal(token.balanceOf(acc2), 300, "Recipient balance incorrect");
        Assert.equal(token.balanceOf(acc0), initialBalance0 - 300, "Sender balance incorrect");
        Assert.equal(token.balanceOf(acc1), initialBalance1, "Middleman balance should not change");
        Assert.equal(token.allowance(acc0, acc1), 200, "Allowance not updated correctly");
    }

    /// #sender: account-0
    function testFailTransferInsufficientFunds() public {
        uint256 balance = token.balanceOf(acc0);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", acc1, balance + 1)
        );
        Assert.equal(success, false, "Transfer should fail with insufficient funds");
    }

    /// #sender: account-1
    function testFailTransferFromInsufficientAllowance() public {
        uint256 allowance = token.allowance(acc0, acc1);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", acc0, acc2, allowance + 1)
        );
        Assert.equal(success, false, "TransferFrom should fail with insufficient allowance");
    }

    /// #sender: account-0
    function testBurnTokens() public {
        uint256 initialSupply = token.totalSupply();
        uint256 burnAmount = 1000 * 10**18;
        Assert.ok(token.transfer(address(token), burnAmount), "Burn transfer failed");
        Assert.equal(token.totalSupply(), initialSupply - burnAmount, "Total supply not reduced after burn");
    }

    /// #sender: account-0
    function testTotalSupplyDecrease() public {
        uint256 initialSupply = token.totalSupply();
        uint256 transferAmount = 1000;
        Assert.ok(token.transfer(address(0), transferAmount), "Transfer to zero address failed");
        Assert.equal(token.totalSupply(), initialSupply - transferAmount, "Total supply not reduced after transfer to zero address");
    }
}