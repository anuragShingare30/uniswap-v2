// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {DAI, WETH, MKR, UNISWAP_V2_ROUTER_02, UNISWAP_V2_PAIR_DAI_WETH, UNISWAP_V2_FACTORY} from "src/constants.sol";
import {IWeth} from "src/interfaces/IWeth.sol";
import {MyToken} from "src/ERC20.sol";

contract AddLiquidityTest is Test {
    IWeth public constant weth = IWeth(WETH);
    IERC20 public constant dai = IERC20(DAI);
    IERC20 public constant mkr = IERC20(MKR);
    MyToken public token;

    IUniswapV2Router02 public constant router = IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Pair public constant pair = IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_WETH);
    IUniswapV2Factory public constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);

    address public USER = makeAddr("USER");
    uint256 public constant amount = 100 * 1e18;

    function setUp() public {
        token = new MyToken();
        // Fund WETH to user
        vm.deal(USER, amount);
        vm.startPrank(USER);
        weth.deposit{value: amount}();
        weth.approve(address(router), type(uint256).max);
        vm.stopPrank();

        // Fund DAI to user
        deal(DAI, USER, 10000 * 1e18);
        vm.startPrank(USER);
        dai.approve(address(router), type(uint256).max);
        vm.stopPrank();

        // Fund Token to user
        deal(address(token), USER, 10000 * 1e18);
        vm.startPrank(USER);
        token.approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_checkWhetherPairExists_AddLiquidity() public {
        console.log("User DAI balance:", dai.balanceOf(USER));
        console.log("User WETH balance:", weth.balanceOf(USER));

        vm.prank(USER);
        address pair1 = factory.getPair(address(dai), address(weth));
        address pair2 = factory.getPair(address(dai), address(token));

        assert(pair1 != address(0));
        assert(pair2 == address(0));
    }

    function test_addLiquidity_DAI_WETH() public {
        console.log("User DAI balance before:", dai.balanceOf(USER));
        console.log("User WETH balance before:", weth.balanceOf(USER));

        vm.startPrank(USER);
        (uint256 amountA, uint256 amountB, uint256 liquidity) = router.addLiquidity({
            tokenA: address(dai),
            tokenB: address(weth),
            amountADesired: 1000 * 1e18,
            amountBDesired: 100 * 1e18,
            amountAMin: 1000,
            amountBMin: 100,
            to: USER,
            deadline: block.timestamp
        });
        vm.stopPrank();

        console.log("Liquidity:", liquidity);
        console.log("Amount A:", amountA);
        console.log("Amount B:", amountB);
        console.log("User DAI balance after:", dai.balanceOf(USER));
        console.log("User WETH balance after:", weth.balanceOf(USER));
    }

    function test_addLiquidity_WETH_Token() public {
        console.log("User token balance before:", token.balanceOf(USER));
        console.log("User WETH balance before:", weth.balanceOf(USER));

        vm.startPrank(USER);
        (uint256 amountA, uint256 amountB, uint256 liquidity) = router.addLiquidity({
            tokenA: address(weth),
            tokenB: address(token),
            amountADesired: 100 * 1e18,
            amountBDesired: 1000 * 1e18,
            amountAMin: 100,
            amountBMin: 1000,
            to: USER,
            deadline: block.timestamp
        });
        vm.stopPrank();

        console.log("Liquidity:", liquidity);
        console.log("Amount A:", amountA);
        console.log("Amount B:", amountB);
        console.log("User token balance after:", token.balanceOf(USER));
        console.log("User WETH balance after:", weth.balanceOf(USER));
    }
}
