# Bank smart contract user interface

![Project Image](https://i.ibb.co/wWDJrzJ/image.png)

> User interface for the Bank smart contract application.

---

### Table of Contents

- [Description](#description)
- [How To Use](#how-to-use)
- [References](#references)
- [License](#license)
- [Author Info](#author-info)

---

## Description

There is a user interface for the Bank smart contract application.

It is becoming increasingly harder for younger and low income individuals to get loans from banks. At the
same time current interest rates on savings are low, and many would like to be able to invest in areas that
provide higher returns (which would also entail higher risk). Decentralised lending to anonymous individuals
is very risky. A company wants to implement a Peer-to-Peer (P2P) lending system which allows for trusted
third parties to provide guarantees for specific borrowers in exchange for a cut of the interest paid back by
the borrower.

The following functionality encoded within:

• Individuals looking for loans can make a request for a loan by inputting the following details: the amount of Ether they would like to borrow, the date by which they promise to pay back the full amount, and the interest in Ether they promise to pay back upon paying back the full amount.

• Third-party guarantors can choose to provide a guarantee that the amount being requested by the borrower will be paid back to the lender by sending the amount of Ether being requested by the borrower. This amount is to be sent into the smart contract after individuals have made a request for loans, and before borrowers have granted a loan. The guarantor must also specify the amount of interest in Ether they will keep from the amount to be paid by the borrower. Once a guarantee is placed, the borrower must accept or reject the guarantee. Rejecting the guarantee will result in the guarantor’s money being returned to the guarantor.

• Lenders should be able to view: (i) the current requests for loans; (ii) whether a guarantee has been placed on a specific request; (iii) the guarantor’s address (this address could then be translated into
a third party’s identity off-chain); and (iv) the amount of interest in Ether that the lender will make once the full amount is paid (i.e. the full interest amount less the amount of interest that the guarantor
will keep).

• A lender can then chose to provide the loan by sending the appropriate Ether along with identification of the specific loan request they are sending funds for. The funds should be sent to the borrower at this point.

• If a lender does not receive the full loan amount and the expected interest by the date agreed upon, then the lender can withdrawn the guarantee placed by the guarantor.

• If the borrower pays back the full loan amount and the full interest amount then: (i) the guarantor’s funds should immediately be sent back to the guarantor along with the interest amount to be sent to
the guarantor; and (ii) the lender should receive the full loan amount along with the amount of interest due to the lender.

The contract stipulates that users cannot abuse the functionality in any way.

[Back To The Top](#bank-smart-contract-user-interface)

---

## How To Use

#### Installation

`WARNING!!! Installation guide assuming that you already have installed Node Package Manager and MetaMask extension in your browser. `
`Also highly recommended to paste yours contract address instead of the current contract address in the App.js.`

1. Clone the repository.

```
git clone https://github.com/taranchik/bank-contract-react-interface
```

2. Run the following command in order to install required packages.

```
npm install
```

3.  Start the Bank smart contract application with a user interface.

```
npm start
```

4. Sign in to your MetaMask account.

![metamask-login](https://i.ibb.co/5kX14x7/image.png)

Switching between accounts in the MetaMask will cause the role of the current account in the application to change.

![metamask-switch-account-borrower](https://i.ibb.co/wWDJrzJ/image.png)
![metamask-switch-account-guarantor](https://i.ibb.co/mBLbGmy/image.png)

[Back To The Top](#bank-smart-contract-user-interface)

---

## References

[Installation guide of the Node Package Manager](https://www.npmjs.com/get-npm)

[Solidity programming language](https://solidity.readthedocs.io/en/v0.7.4/)

[REMIX IDE](https://remix.ethereum.org/)

[MetaMask](https://metamask.io/)

[Back To The Top](#bank-smart-contract-user-interface)

---

## License

MIT License

Copyright (c) [2021] [Viacheslav Taranushenko]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[Back To The Top](#bank-smart-contract-user-interface)

---

## Author Info

- LinkedIn - [Viacheslav Taranushenko](https://www.linkedin.com/in/viacheslav-taranushenko-727466187/)
- GitHub - [@taranchik](https://github.com/taranchik)
- GitLab - [@taranchik](https://gitlab.com/taranchik)
- Twitter - [@viataranushenko](https://twitter.com/viataranushenko)

[Back To The Top](#bank-smart-contract-user-interface)
