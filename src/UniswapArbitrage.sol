// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IUniswapV2Router02} from "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Callee} from "lib/v2-core/contracts/interfaces/IUniswapV2Callee.sol";

contract UniswapArbitrage is IUniswapV2Callee {
    using SafeERC20 for IERC20;

    error UniswapArbitrage_InsufficientProfit();
    error UniswapArbitrage_InsufficientProfit_FlashSwap();

    // External functions

    /**
     * @notice swap function
     * Function performs arbitrage between Uniswap and Sushiswap
     * Function performs two swaps:
     *         1. Swap DAI to WETH
     *         2. Swap WETH to DAI
     */
    function swap(
        address router0, // Uniswap DAI/WETH
        address router1, // Sushiswap DAI/WETH
        address tokenIn, // DAI
        address tokenOut, // WETH
        uint256 amountIn, // 100 DAI
        uint256 minProfit // 1 DAI
    ) external {
        // Transfer amountIn to contract to perform further operation
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        // Check the profit from arbitrage
        uint256 amountOut = _swap(
            router0, // Uniswap DAI/WETH
            router1, // Sushiswap DAI/WETH
            tokenIn, // DAI
            tokenOut, // WETH
            amountIn // 100 DAI
        );
        if (amountOut - amountIn < minProfit) {
            revert UniswapArbitrage_InsufficientProfit();
        }

        // Transfer amountOut to msg.sender
        IERC20(tokenIn).safeTransfer(msg.sender, amountOut);
    }

    function flashSwap(
        address pair, // from which we will borrow tokens
        bool isToken0, // track for token0
        address router0, // Uniswap DAI/WETH
        address router1, // Sushiswap DAI/WETH
        address tokenIn, // DAI
        address tokenOut, // WETH
        uint256 amountIn, // 100 DAI
        uint256 minProfit // 1 DAI
    ) external {
        // Encode the data
        bytes memory data = abi.encode(pair, msg.sender, router0, router1, tokenIn, tokenOut, amountIn, minProfit);

        (uint256 amount0Out, uint256 amount1Out) = isToken0 ? (amountIn, uint256(0)) : (uint256(0), amountIn);

        // call the swap function -> To initiate the flashswap
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function uniswapV2Call(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata data) external override {
        // decode the data
        (
            address pair,
            address caller,
            address router0,
            address router1,
            address tokenIn,
            address tokenOut,
            uint256 amountIn,
            uint256 minProfit
        ) = abi.decode(data, (address, address, address, address, address, address, uint256, uint256));

        // Verify the caller is the pair contract
        require(msg.sender == pair, "UniswapArbitrage: INVALID_CALLER");

        // Calculate the fee
        uint256 amountBorrowed = amountIn;
        uint256 fee = ((amountBorrowed * 3) / 997) + 1;
        uint256 amountToRepay = amountBorrowed + fee;

        // First perform the arbitrage to get the tokens
        uint256 amountOut = _swap(router0, router1, tokenIn, tokenOut, amountIn);
        uint256 profit = amountOut - amountToRepay;

        if (profit < minProfit) {
            revert UniswapArbitrage_InsufficientProfit_FlashSwap();
        }

        // Now that we have the tokens, repay the pair
        IERC20(tokenIn).safeTransfer(pair, amountToRepay);

        // Transfer the profit to caller
        IERC20(tokenIn).safeTransfer(caller, profit);
    }

    // Internal functions

    function _swap(
        address router0, // Uniswap DAI/WETH
        address router1, // Sushiswap DAI/WETH
        address tokenIn, // DAI
        address tokenOut, // WETH
        uint256 amountIn // 100 DAI
    ) internal returns (uint256 amountOut) {
        // swap with router0
        IERC20(tokenIn).approve(router0, amountIn);

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint256[] memory amounts = IUniswapV2Router02(address(router0)).swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });

        // swap with router1
        IERC20(tokenOut).approve(router1, amounts[1]);

        path[0] = tokenOut; // WETH
        path[1] = tokenIn; // DAI

        amounts = IUniswapV2Router02(router1).swapExactTokensForTokens({
            amountIn: amounts[1],
            amountOutMin: amountIn,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });

        amountOut = amounts[1]; // DAI amount out
    }
}
