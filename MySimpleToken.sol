pragma solidity ^0.4.18;

import "https://github.com/OpenZeppelin/zeppelin-solidity/contracts/token/MintableToken.sol";

contract SimpleTokenCoin is MintableToken {

    string public constant name = "Simple Coint Token";

    string public constant symbol = "SCT";

    uint32 public constant decimals = 18;

}

contract Crowdsale is Ownable {

    using SafeMath for uint;

    address restricted;

    address multisig;

    uint restrictedPercent;

    SimpleTokenCoin public token = new SimpleTokenCoin();

    uint start;

    uint period;

    uint hardcap;

    uint rate;

    uint today = now;

    function Crowdsale() public {
        multisig = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;
        restricted = 0xb3eD172CC64839FB0C0Aa06aa129f402e994e7De;
        restrictedPercent = 40;
        rate = 100000000000000000000;
        start = 1512086400;
        period = 28;
        hardcap = 10000000000000000000000;
    }

    modifier saleIsOn() {
    	require(today > start && today < start + period * 1 days);
    	_;
    }

    modifier isUnderHardCap() {
        require(multisig.balance <= hardcap);
        _;
    }

    function finishMinting() public onlyOwner {
        uint issuedTokenSupply = token.totalSupply();
        uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
        token.mint(restricted, restrictedTokens);
        token.finishMinting();
    }

   function createTokens() isUnderHardCap saleIsOn public payable {
        multisig.transfer(msg.value);
        uint tokens = rate.mul(msg.value).div(1 ether);
        uint bonusTokens = 0;
        if(today < start + (period * 1 days).div(4)) {
          bonusTokens = tokens.div(4);
        } else if(today >= start + (period * 1 days).div(4) && today < start + (period * 1 days).div(4).mul(2)) {
          bonusTokens = tokens.div(10);
        } else if(today >= start + (period * 1 days).div(4).mul(2) && today < start + (period * 1 days).div(4).mul(3)) {
          bonusTokens = tokens.div(20);
        }
        tokens += bonusTokens;
        token.mint(msg.sender, tokens);
    }

    function() external payable {
        createTokens();
    }

}
