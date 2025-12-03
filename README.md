# The DAO Hack Reproduction (Reentrancy Exploit)

Este projeto é uma reprodução educacional do ataque histórico à **The DAO** (2016), evento que resultou no roubo de milhões de Ether e motivou o **Hard Fork** que dividiu a rede Ethereum em duas: Ethereum (ETH) e Ethereum Classic (ETC).

A atividade utiliza o framework **Foundry** para simular o ambiente e demonstrar a vulnerabilidade de **Reentrância (Reentrancy)** na prática.

## Contexto Histórico

Em 2016, a organização autônoma descentralizada "The DAO" sofreu um ataque devido a uma falha lógica na função `splitDAO`. O contrato enviava Ether para o usuário **antes** de atualizar o saldo interno. Isso permitiu que um atacante utilizasse uma chamada recursiva para sacar fundos repetidamente antes que o contrato registrasse a transação.

*   **Vítima:** Contrato `TheDAO.sol` (simulando a lógica vulnerável).
*   **Ataque:** "Recursive Call Exploit" via `Attacker.sol`.
*   **Código Original de Referência:** [blockchainsllc/DAO (v1.0)](https://github.com/blockchainsllc/DAO/tree/v1.0)

## 🛠️ Tecnologias Utilizadas

*   **Solidity (v0.8.x):** Sintaxe moderna adaptada para reproduzir a lógica de 2016.
*   **Foundry:** Framework avançado para desenvolvimento e testes de Smart Contracts.

## Estrutura do Projeto

*   `src/TheDAO.sol`: O contrato "vítima" que contém a vulnerabilidade de reentrância.
*   `src/Attacker.sol`: O contrato malicioso que explora a falha para drenar os fundos.
*   `test/TheDAOHack.t.sol`: Script de teste que orquestra o cenário (depósito inicial das vítimas e execução do ataque).

## Como Executar

Este projeto está configurado para rodar facilmente no **GitHub Codespaces** ou em qualquer ambiente local com Foundry.

### 1. Instalação do Foundry
Caso o ambiente ainda não tenha o Foundry instalado (ex: um novo Codespace), execute:

```bash
curl -L https://foundry.paradigm.xyz | bash
source /home/codespace/.bashrc
foundryup
```

### 2. Instalação de Dependências
Para baixar as dependências necessárias:

```bash
forge install foundry-rs/forge-std
```

### 3. Compilação
Para compilar os contratos:

```bash
forge build
```

### 4. Reproduzindo o Ataque
Para rodar o teste que simula o roubo dos fundos:

```bash
forge test -vv
```

### Resultado Esperado
Você verá logs no terminal indicando que o saldo da DAO foi zerado e transferido para o atacante:

```text
[PASS] testDaoHack() (gas: ...)
Logs:
  Saldo da DAO antes do ataque: 100000000000000000000
  Saldo do Atacante antes do ataque: 1000000000000000000
  Saldo da DAO apos o ataque: 0
  Saldo do Atacante apos o ataque: 101000000000000000000
```

## Entendendo a Vulnerabilidade

A falha ocorre devido à violação do padrão de segurança **Checks-Effects-Interactions**.

**Lógica Vulnerável (Simulada em `TheDAO.sol`):**

```solidity
function splitDAO() public {
    // ... verificações ...

    // 1. Interação (Envia dinheiro) - PERIGO!
    // O controle passa para o contrato do atacante aqui.
    (bool success, ) = msg.sender.call{value: amount}("");

    // 2. Efeito (Atualiza saldo) - TARDE DEMAIS
    // Esta linha só roda depois que o atacante já sacou tudo recursivamente.
    balances[msg.sender] = 0;
}
```

O atacante utiliza a função `receive()` ou `fallback()` em seu contrato para chamar `splitDAO()` novamente assim que recebe o Ether, criando um loop de saques antes que o saldo seja zerado.

---
*Atividade realizada para fins de estudo sobre segurança em Smart Contracts e história do Ethereum.*