// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



import "remix_tests.sol";
//import "remix_accounts.sol";
import "hardhat/console.sol";
import "../contracts/ChrisToken.sol";


contract TestChrisToken {
    ChrisToken public chrisToken;
    uint256 public initialSupply = 1000000 * 10**18; // 1 milhao de tokens com 18 casas decimais
    
    address owner;
    address acc1;
    address acc2;

    function beforeAll() public {
        // owner = TestsAccounts.getAccount(0); // O owner sera a conta que faz o deployment
        // acc1 = TestsAccounts.getAccount(1);
        // acc2 = TestsAccounts.getAccount(2);
        
        owner = payable(msg.sender); //0x61839C7e297cb455dc0a7029BA12DF5BAF6643e0 // A conta que deploya o contrato de teste
        acc1 = payable(address(0xb346C111ba12a8B97167f2Fa76C5312db4703E7D));  // Substitua pelo endereço real do Ganache
        acc2 = payable(address(0xcfAd83f3B485AAB06175d2f42E7baa927B95ff34));  // Substitua pelo endereço real do Ganache

   

        console.log("Owner address:", owner);
        console.log("Acc1 address:", acc1);
        console.log("Acc2 address:", acc2);
        console.log("---------------------------------------------------------------------------");       

        console.log("Account owner balance:", owner.balance);
        console.log("Account nro 1 balance:", acc1.balance);
        console.log("Account nro 2 balance:", acc2.balance);
        console.log("---------------------------------------------------------------------------");

        
        // Deploy do contrato ChrisToken
        chrisToken = new ChrisToken(initialSupply);
        console.log("ChrisToken deployed com fornecimento inicial:", initialSupply);
    }

    /// Teste do construtor e fornecimento inicial
    function testInitialSupply() public {
        Assert.equal(chrisToken.totalSupply(), initialSupply, "Fornecimento inicial incorreto");
        console.log("Fornecimento total verificado:", chrisToken.totalSupply());
        
        uint256 ownerBalance = chrisToken.balanceOf(owner);
        Assert.equal(ownerBalance, initialSupply, "Saldo inicial do owner incorreto");
        console.log("Saldo inicial do owner verificado:", ownerBalance);
    }

    /// Teste de transferencia de tokens
    function testTransfer() public {
        uint256 amount = 100 * 10**18; // 100 tokens
        
        uint256 initialOwnerBalance = chrisToken.balanceOf(owner);
        console.log("Saldo inicial do owner antes da transferencia:", initialOwnerBalance);
        
        // Transfere tokens do owner para acc1
        bool success = chrisToken.transfer(acc1, amount);
        Assert.ok(success, "Falha na transferencia");
        console.log("Transferencia de", amount, "tokens para acc1 realizada");
        
        // Verifica o saldo de acc1
        uint256 acc1Balance = chrisToken.balanceOf(acc1);
        Assert.equal(acc1Balance, amount, "Saldo de acc1 incorreto apos transferencia");
        console.log("Saldo de acc1 apos transferencia:", acc1Balance);
        
        // Verifica o novo saldo do owner
        uint256 newOwnerBalance = chrisToken.balanceOf(owner);
        Assert.equal(newOwnerBalance, initialOwnerBalance - amount, "Saldo do owner incorreto apos transferencia");
        console.log("Novo saldo do owner:", newOwnerBalance);
    }

    // ... (o resto dos testes permanece o mesmo, mas você pode adicionar logs semelhantes)
}