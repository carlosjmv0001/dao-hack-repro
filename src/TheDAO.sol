// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TheDAO {
    mapping(address => uint256) public balances;

    // Função para investidores depositarem ETH (Simulando a compra de tokens DAO)
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // A função "splitDAO" simplificada (onde o hack ocorreu)
    // No código original, isso permitia criar uma "Child DAO" e mover fundos.
    function splitDAO() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Saldo insuficiente");

        // VULNERABILIDADE AQUI:
        // 1. Envia o ETH para o usuário (chamada externa)
        // O atacante pode interceptar isso e chamar splitDAO() novamente
        // ANTES da linha que zera o saldo ser executada.
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Falha no envio de Ether");

        // 2. Atualiza o saldo (Tarde demais!)
        balances[msg.sender] = 0;
    }

    // Função auxiliar para ver o saldo do contrato
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}