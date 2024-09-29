// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GenericToken.sol";

contract ChrisToken is GenericToken {
    // O construtor recebe um uint256 para o fornecimento inicial
    // Usamos uint256 para garantir que possamos ter um grande número de tokens
    // sem preocupações com overflow
    constructor(uint256 initialSupply) GenericToken("ChrisToken", "CHRIS", 18, initialSupply) {
        // O construtor da classe pai é chamado com os parâmetros específicos do ChrisToken:
        // - Nome: "ChrisToken"
        // - Símbolo: "CHRIS"
        // - Decimais: 18 (padrão para a maioria dos tokens ERC20)
        // - Fornecimento inicial: passado como parâmetro para permitir flexibilidade
        // Atribui explicitamente o saldo inicial ao msg.sender (owner)
        balances[msg.sender] = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    // Função adicional específica do ChrisToken para queimar tokens
    // Esta função permite que os usuários destruam seus próprios tokens,
    // reduzindo o fornecimento total
    function burn(uint256 amount) public returns (bool success) {
        // Verifica se o remetente tem saldo suficiente para queimar
        require(amount <= balances[msg.sender], "Saldo insuficiente para queima");

        // Reduz o saldo do remetente
        balances[msg.sender] = safeSub(balances[msg.sender], amount);
        // Reduz o fornecimento total
        _totalSupply = safeSub(_totalSupply, amount);
        
        // Emite um evento Transfer para o endereço zero, indicando a queima
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}