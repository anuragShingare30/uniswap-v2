// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test,console} from "forge-std/Test.sol";
import {IUniswapV2Factory} from "lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DAI, WETH, MKR, UNISWAP_V2_FACTORY} from "src/constants.sol";
import {IWeth} from "src/interfaces/IWeth.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {MyToken} from "src/ERC20.sol";

contract CreatePairTest is Test {

    IWeth public constant weth = IWeth(WETH);
    IERC20 public constant dai = IERC20(DAI);
    IERC20 public constant mkr = IERC20(MKR);


    IUniswapV2Factory public factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);

    address public USER = makeAddr("USER");
    MyToken public token;

    function setUp() public {
        token = new MyToken();
    }

    /**
     @notice test_createPair test function
     @dev Function will create the token Pool pair for MyToken and weth on mainnet
     @dev createPair() creates token pool for X/Y tokens
     */
    function test_createPair() public{
        
        address pair = factory.createPair(address(token), address(weth));

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        console.log("Pair address:", pair);
        if(address(token) < WETH){
            assert(token0 == address(token));
            assert(token1 == address(weth));
        }else{
            assert(token0 == address(weth));
            assert(token1 == address(token));
        }
    }

}
