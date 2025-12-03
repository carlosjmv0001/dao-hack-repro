// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TheDAO.sol";
import "../src/Attacker.sol";

contract TheDAOHackTest is Test {
    TheDAO public dao;
    Attacker public attacker;

    address public alice; // Investidor inocente
    address public bob;   // Investidor inocente

    function setUp() public {
        dao = new TheDAO();
        
        // Criando investidores inocentes para encher a DAO de dinheiro
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        // Dando dinheiro para Alice e Bob (cheatcodes do Foundry)
        vm.deal(alice, 50 ether);
        vm.deal(bob, 50 ether);

        // Alice e Bob depositam na DAO (Total: 100 Ether)
        vm.prank(alice);
        dao.deposit{value: 50 ether}();
        
        vm.prank(bob);
        dao.deposit{value: 50 ether}();

        // Agora a DAO tem 100 Ether no total
        assertEq(address(dao).balance, 100 ether);

        // Deploy do contrato do atacante
        attacker = new Attacker(address(dao));
    }

    function testDaoHack() public {
        // O Atacante começa com 1 Ether
        vm.deal(address(attacker), 1 ether); 
        
        console.log("Saldo da DAO antes do ataque:", address(dao).balance);
        console.log("Saldo do Atacante antes do ataque:", address(attacker).balance);

        // --- EXECUÇÃO DO ATAQUE ---
        vm.prank(address(attacker)); // Simula que a chamada vem do contrato Attacker
        attacker.attack{value: 1 ether}();
        // --------------------------

        console.log("Saldo da DAO apos o ataque:", address(dao).balance);
        console.log("Saldo do Atacante apos o ataque:", address(attacker).balance);

        // Validações (Asserts)
        
        // 1. A DAO deve estar vazia (ou quase vazia)
        assertEq(address(dao).balance, 0);

        // 2. O Atacante deve ter muito mais que 1 Ether (os 100 da DAO + o 1 dele)
        assertGt(address(attacker).balance, 100 ether);
    }
}