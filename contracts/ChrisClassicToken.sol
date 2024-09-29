// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./GenericToken.sol";

contract ChrisToken is GenericToken {
    constructor() GenericToken("Chris Classic Coin", "CHRIS-Classic", 4, 10000000000) {
        // O token ChrisToken será criado com 10.000.000.000 de suprimento e 2 casas decimais.
    }
}
