// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test,console} from "lib/forge-std/src/Test.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {DAI, WETH, MKR,UNISWAP_V2_ROUTER_02,UNISWAP_V2_PAIR_DAI_WETH,UNISWAP_V2_FACTORY} from "src/constants.sol";
import {IWeth} from "src/interfaces/IWeth.sol";
import {MyToken} from "src/ERC20.sol";


contract RemoveLiquidityTest is Test{
    
    IWeth public constant weth = IWeth(WETH);
    IERC20 public constant dai = IERC20(DAI);
    IERC20 public constant mkr = IERC20(MKR);
    MyToken public token;

    IUniswapV2Router02 public constant router = IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Pair public constant pair = IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_WETH);
    IUniswapV2Factory public constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);
    
    address public USER = makeAddr("USER");
    uint256 public constant amount = 100*1e18;

    function setUp() public {
        token = new MyToken();

        // Fund WETH to user
        vm.deal(USER,amount);
        vm.startPrank(USER);
        weth.deposit{value:amount}();
        weth.approve(address(router),type(uint256).max);
        vm.stopPrank();

        // Fund DAI to user
        deal(DAI,USER, 10000*1e18);
        vm.startPrank(USER);
        dai.approve(address(router), type(uint256).max);
        vm.stopPrank();

        // Fund Token to user
        deal(address(token),USER, 10000*1e18);
        vm.startPrank(USER);
        token.approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_checkWhetherPairExists_RemoveLiquidity() public {
        vm.startPrank(USER);
        address pairAddr = factory.getPair(address(dai), address(weth));
        vm.stopPrank();

        assert(pairAddr != address(0));
    }

    // 1. First check whether pair exist
    // 2. Add liquidity
    // 3. remove liquidity
    function test_removeLiquidity_DAI_WETH() public {
        console.log("User DAI balance before:",dai.balanceOf(USER));
        console.log("User WETH balance before:",weth.balanceOf(USER));

        
        vm.startPrank(USER);
        (uint X, uint Y, uint liquidity) = router.addLiquidity(
            address(dai),
            address(weth),
            1000*1e18,
            100*1e18,
            1,
            1,
            USER,
            block.timestamp
        );
        vm.stopPrank();

        // Liquidity: 11506861706695596196
        // Amount A: 1000000000000000000000
        // Amount B: 559442433341885474
        console.log("Liquidity before removing:",liquidity);
        console.log("Amount of DAI to be Added:",X);
        console.log("Amount of WETH to be Added:",Y);

        vm.roll(block.number + 1000);
        vm.warp(block.timestamp + 1000);

        vm.startPrank(USER);
        pair.approve(address(router), liquidity);
        (uint dX, uint dY) = router.removeLiquidity(
            address(dai),
            address(weth),
            liquidity,
            1,
            1,
            USER,
            block.timestamp
        );
        vm.stopPrank();

        console.log("amount of DAI to be removed:", dX);
        console.log("amount of WETH to be removed:",dY);
        console.log("Liquidity after removing:",liquidity);
    }   


}