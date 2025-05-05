// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {UniswapFlashSwap} from "src/UniswapFlashSwap.sol";
import {IWeth} from "src/interfaces/IWeth.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {DAI, WETH, MKR, UNISWAP_V2_PAIR_DAI_WETH} from "src/constants.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

/**
 * @title TestUniswapFlashSwap
 * @author anurag Shingare
 * @notice This contract is testing the flashswap function for pair DAI-WETH
 * Here we will test the flashswap function:
    * 1. flashswap()
    * 2. uniswapV2Call()
 */
contract TestUniswapFlashSwap is Test {
    IWeth public constant weth = IWeth(WETH);
    IERC20 public constant dai = IERC20(DAI);
    UniswapFlashSwap public flashswap;

    address public USER = makeAddr("USER");
    uint256 public constant amount = 1000 * 1e18;

    function setUp() public {
        flashswap = new UniswapFlashSwap(UNISWAP_V2_PAIR_DAI_WETH);

        // Fund user with ETH and convert to WETH
        vm.deal(USER, amount * 2); // Give extra for fees
        vm.startPrank(USER);
        weth.deposit{value: amount * 2}();
        weth.approve(address(flashswap), type(uint256).max);
        vm.stopPrank();

        deal(DAI, USER, 10000 * 1e18);
        vm.startPrank(USER);
        dai.approve(address(flashswap), type(uint256).max);
        vm.stopPrank();
    }

    function test_checkFlashSwap() public {
        console.log("WETH balance of USER:", weth.balanceOf(USER));

        uint256 amountToBorrow = 1000 * 1e18;
        vm.startPrank(USER);
        flashswap.flashswap(WETH, amountToBorrow);
        vm.stopPrank();

        uint256 amountToRepay = flashswap.amountToRepay();
        uint256 fee = (amountToBorrow * 3) / 997 + 1;
        console.log("Amount Borrowed:", amountToBorrow);
        console.log("Fee:", fee);
        console.log("Amount to repay:", amountToRepay);
        assertGt(amountToRepay, amountToBorrow);
    }
}
