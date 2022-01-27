# Deal smart contract

![Project Image](https://i.ibb.co/r0DmPV1/image.png)

> Output of the Deal smart contract testing.

---

### Table of Contents

- [Description](#description)
- [How To Use](#how-to-use)
- [Author Info](#author-info)

---

## Description

There is Deal smart contract to make transactions between parties.

Deal smart contract handles contracts between two users to sell a material item in exchange for ETH or any ERC-20 token. In the event of disputes, there is a role of the arbitrator for resolving the dispute.

Deal smart contract is:
1) Resistant from theft of contractual funds
2) Third party dispute resolution
3) Supports any token in the ERC-20 standard

Source files contains: implementation in the solidity programming language, automatic tests with the ability to generate a coverage report, commissioning documentation.


[Back To The Top](#deal-smart-contract)

---

## How To Use

#### Installation

1. Install Ganache CLI.

```
npm install -g ganache-cli
```

2. Make fork Ethereum mainnet using Ganache.

```
ganache-cli --fork https://mainnet.infura.io/v3/{infura_project_id}
```

3. Clone the repository.

```
git clone https://github.com/taranchik/deal-smart-contract
```

4. Change directory to the directory with the app.

```
cd deal-smart-contract/
```

5. Install dependepcies.

```
npm install
```

6. Compile a Truffle project.

```
truffle compile
```

7. Deploy contracts to the network.

```
truffle migrate
```

8. Run truffle tests.

```
truffle test
```

[Back To The Top](#deal-smart-contract)

---

## Author Info

- LinkedIn - [Viacheslav Taranushenko](https://www.linkedin.com/in/viacheslav-taranushenko-727466187/)
- GitHub - [@taranchik](https://github.com/taranchik)
- GitLab - [@taranchik](https://gitlab.com/taranchik)
- Twitter - [@viataranushenko](https://twitter.com/viataranushenko)

[Back To The Top](#deal-smart-contract)
