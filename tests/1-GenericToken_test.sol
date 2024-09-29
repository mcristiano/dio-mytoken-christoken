// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "remix_tests.sol";
import "hardhat/console.sol";
import "remix_accounts.sol";
import "../contracts/GenericToken.sol";

contract TestGenericToken {
    GenericToken token;

    address acc0;
    address acc1;
    address acc2;    

    function beforeAll() public {
        token = new GenericToken("Test Token", "TST", 18, 1000000 * 10**18);

        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        
        console.log("Account 0:", acc0);
        console.log("Account 1:", acc1);
        console.log("Account 2:", acc2);            
    }

    function testInitialDeployment() public {
        Assert.equal(token.name(), "Test Token", "Token name should be set correctly");
        Assert.equal(token.symbol(), "TST", "Token symbol should be set correctly");
        Assert.equal(token.decimals(), 18, "Token decimals should be set correctly");
        Assert.equal(token.totalSupply(), 1000000 * 10**18, "Initial supply should be set correctly");
    }

    function testInitialBalance() public {
        Assert.equal(token.balanceOf(address(this)), 1000000 * 10**18, "Owner should have all tokens initially");
    }

    function testTransfer() public {
        Assert.ok(token.transfer(address(0x1234), 100), "Transfer should return true");
        Assert.equal(token.balanceOf(address(0x1234)), 100, "Balance should be updated after transfer");
    }

    function testApproveAndTransferFrom() public {
        uint256 initialBalance0 = token.balanceOf(acc0);
        uint256 initialBalance1 = token.balanceOf(acc1);
        uint256 initialBalance2 = token.balanceOf(acc2);
        
        console.log("Initial balance acc0:", formatTokens(initialBalance0));
        console.log("Initial balance acc1:", formatTokens(initialBalance1));
        console.log("Initial balance acc2:", formatTokens(initialBalance2));

        Assert.ok(token.approve(acc1, 500 * 10**18), "Approval failed");
        uint256 allowance = token.allowance(acc0, acc1);
        console.log("Allowance set for acc1:", formatTokens(allowance));
        Assert.equal(allowance, 500 * 10**18, "Allowance not set correctly");

        Assert.ok(token.transferFrom(acc0, acc2, 300 * 10**18), "TransferFrom failed");

        uint256 finalBalance0 = token.balanceOf(acc0);
        uint256 finalBalance1 = token.balanceOf(acc1);
        uint256 finalBalance2 = token.balanceOf(acc2);

        console.log("Final balance acc0:", formatTokens(finalBalance0));
        console.log("Final balance acc1:", formatTokens(finalBalance1));
        console.log("Final balance acc2:", formatTokens(finalBalance2));

        Assert.equal(finalBalance2, initialBalance2 + 300 * 10**18, "Recipient balance incorrect");
        Assert.equal(finalBalance0, initialBalance0 - 300 * 10**18, "Sender balance incorrect");
        Assert.equal(finalBalance1, initialBalance1, "Middleman balance should not change");

        uint256 finalAllowance = token.allowance(acc0, acc1);
        console.log("Final allowance for acc1:", formatTokens(finalAllowance));
        Assert.equal(finalAllowance, 200 * 10**18, "Allowance not updated correctly");
    }    

    function testFailTransferInsufficientFunds() public {
        // Try to transfer more tokens than the total supply
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", address(0x1234), 1000000 * 10**18 + 1)
        );
        Assert.equal(success, false, "Transfer should fail when insufficient funds");
    }

    function testFailTransferFromInsufficientAllowance() public {
        token.approve(address(0x5678), 100);
        // Try to transfer more tokens than allowed
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", address(this), address(0x9ABC), 101)
        );
        Assert.equal(success, false, "TransferFrom should fail when insufficient allowance");
    }

    function formatTokens(uint256 amount) internal pure returns (string memory) {
        uint256 wholeTokens = amount / 10**18;
        uint256 fractionalPart = amount % 10**18;
        string memory fractionalStr = uint2str(fractionalPart);
        while (bytes(fractionalStr).length < 18) {
            fractionalStr = string(abi.encodePacked("0", fractionalStr));
        }
        return string(abi.encodePacked(uint2str(wholeTokens), ".", fractionalStr));
    }

    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }
}