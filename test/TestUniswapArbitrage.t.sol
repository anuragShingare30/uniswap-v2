// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {IUniswapV2Router02} from "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IWeth} from "src/interfaces/IWeth.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {
    DAI, WETH, MKR, SUSHISWAP_V2_ROUTER_02, UNISWAP_V2_ROUTER_02, UNISWAP_V2_PAIR_DAI_MKR,UNISWAP_V2_PAIR_DAI_WETH
} from "src/constants.sol";
import {UniswapArbitrage} from "src/UniswapArbitrage.sol";

contract TestUniswapArbitrage is Test {
    IUniswapV2Router02 public constant router0 = IUniswapV2Router02(UNISWAP_V2_ROUTER_02); // Uniswap DAI/WETH
    IUniswapV2Router02 public constant router1 = IUniswapV2Router02(SUSHISWAP_V2_ROUTER_02); // Sushiswap DAI/WETH
    UniswapArbitrage public arbitrage;
    IUniswapV2Pair public constant pair = IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_WETH);

    IWeth public constant weth = IWeth(WETH);
    IERC20 public constant dai = IERC20(DAI);
    IERC20 public constant mkr = IERC20(MKR);

    address public USER = makeAddr("USER");

    function setUp() public {
        arbitrage = new UniswapArbitrage();

        // Fund WETH to this contract
        deal(address(this), 100 * 1e18);

        weth.deposit{value: 100 * 1e18}();
        weth.approve(address(router0), type(uint256).max);



        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(dai);

        router0.swapExactTokensForTokens({
            amountIn: 100 * 1e18,
            amountOutMin: 1,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });

        // Fund WETH to user
        vm.deal(USER, 2000 * 1e18);
        vm.startPrank(USER);
        weth.deposit{value: 2000 * 1e18}();
        weth.approve(address(router0), type(uint256).max);
        vm.stopPrank();

        // Fund DAI to user
        deal(DAI, USER, 10000 * 1e18);
        vm.startPrank(USER);
        dai.approve(address(arbitrage), type(uint256).max);
        vm.stopPrank();
    }

    function test_arbitrageSwap() public {
        uint256 bal1 = dai.balanceOf(USER);
        console.log("DAI balance before arbitrage:", bal1);

        vm.startPrank(USER);
        arbitrage.swap({
            router0: address(router0), // uniswap
            router1: address(router1), // sushiswap
            tokenIn: DAI,
            tokenOut: WETH,
            amountIn: 100*1e18, // DAI input
            minProfit: 1
        });
        vm.stopPrank();

        uint256 bal2 = dai.balanceOf(USER);
        console.log("DAI balance after arbitrage:", bal2);
        assertGt(bal2, bal1);
        console.log("Profit:", bal2 - bal1);
    }

    function test_ArbitrageFlashSwap() public {
        uint256 bal1 = dai.balanceOf(USER);
        console.log("DAI balance before arbitrage:", bal1);

        vm.startPrank(USER);
        arbitrage.flashSwap({
            pair: address(pair),
            isToken0: true,
            router0: address(router0),
            router1: address(router1),
            tokenIn: DAI,
            tokenOut: WETH,
            amountIn: bal1, // borrowed amount
            minProfit: 1
        });
        vm.stopPrank();

        uint256 bal2 = dai.balanceOf(USER);
        console.log("DAI balance after arbitrage:", bal2);
        console.log("Profit:", bal2 - bal1);
    }
}
