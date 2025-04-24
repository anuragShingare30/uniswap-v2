// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test,console} from "lib/forge-std/src/Test.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IWeth} from "src/interfaces/IWeth.sol";
import {IUniswapV2Router02} from "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DAI, WETH, MKR, UNISWAP_V2_ROUTER_02,UNISWAP_V2_PAIR_DAI_MKR} from "src/constants.sol";

contract SwapContractTest is Test{
    IWeth public constant weth = IWeth(WETH);
    IERC20 public constant dai = IERC20(DAI);
    IERC20 public constant mkr = IERC20(MKR);

    IUniswapV2Router02 public constant router = IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Pair public constant pair = IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_MKR);

    address public USER = makeAddr("USER");


    function setUp() public {
        vm.deal(USER, 100*1e18);
        vm.startPrank(USER);
        weth.deposit{value:100*1e18}();
        weth.approve(address(router), type(uint256).max);
        vm.stopPrank();

    }

    /**
     @dev getAmountsOut() returns the max amount for output token by providing amount of input token
     @notice UniswapV2Router.sol
     @notice The path[] and amounts[] looks like this:
        path[] = [WETH,DAI,MKR]
        amounts[] = [1e18,2342...,8967...]
     */
    function test_getAmountsOut() public{
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256 amountIn = 1e18; // WETH
        uint256[] memory amounts = router.getAmountsOut(amountIn, path);

        // WETH: 1000000000000000000
        // DAI: 1776803230279680854082
        // MKR: 45170670923550656
        console.log("WETH:", amounts[0]);
        console.log("DAI:", amounts[1]);
        console.log("MKR:", amounts[2]);
    }

    /**
     @notice UniswapV2Library.sol
     @dev getAmountsIn() returns the max amount for input token by providing amount of output token
     */
    function test_getAmountsIn() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint256 amountOut = 1e16; // MKR
        uint256[] memory amounts = router.getAmountsIn(amountOut, path);

        // WETH: 10246462953689306
        // DAI: 18335404315979158363
        // MKR: 10000000000000000
        console.log("WETH:", amounts[0]);
        console.log("DAI:", amounts[1]);
        console.log("MKR:", amounts[2]);
    }

    /**
     @dev swapExactTokensForTokens() This function will swap token for given amountIn and returns the max amountOut!!!
     */
     function test_swapExactTokensForTokens() public{
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        console.log("User MKR Balance before swap:", mkr.balanceOf(USER));

        uint256 amountIn = 1e18;
        // amounts[n-1] >= amountOutMin ->> Valid condition
        uint256 amountOutMin = 1e5;
        vm.startPrank(USER);
        uint256[] memory amounts = router.swapExactTokensForTokens(amountIn, amountOutMin, path, USER, block.timestamp);
        vm.stopPrank();

        
        console.log("WETH:", amounts[0]); // in
        console.log("MKR:", amounts[2]); // out
        console.log("User MKR Balance after swap:", mkr.balanceOf(USER));

        assertGe(mkr.balanceOf(USER), amountOutMin);
     }


     /**
      @dev swapTokensForExactTokens() This function will swap token for given amountOut and tries to return minimum amountIn
      */
     function test_swapTokensForExactTokens() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        console.log("User mkr balance before swap:", mkr.balanceOf(USER));

        uint256 amountOut = 1e5;
        uint256 amountInMax = 1e18;
        vm.startPrank(USER);
        uint256[] memory amounts = router.swapTokensForExactTokens(amountOut, amountInMax, path, USER, block.timestamp);
        vm.stopPrank();

        console.log("WETH:", amounts[0]);
        console.log("DAI:", amounts[1]);
        console.log("MKR:", amounts[2]);
        console.log("User mkr balance after swap:", mkr.balanceOf(USER));

        assertEq(mkr.balanceOf(USER), amountOut);
     }
}