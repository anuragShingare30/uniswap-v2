// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {DAI, WETH, UNISWAP_V2_PAIR_DAI_WETH} from "src/constants.sol";
import {IWeth} from "src/interfaces/IWeth.sol";

contract UniswapFlashSwap {
    using SafeERC20 for IERC20;

    // Errors
    error UniswapFlashSwap__InvalidToken();
    error UniswapFlashSwap_InvalidCaller();
    error UniswapFlashSwap_InvalidSender();

    // Constants
    IUniswapV2Pair public constant pair = IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_WETH);
    IWeth public constant weth = IWeth(WETH);
    IERC20 public constant dai = IERC20(DAI);

    uint256 public amountToRepay = 0;

    function flashswap(address token, uint256 amount) external {
        if (token != address(weth) && token != address(dai)) {
            revert UniswapFlashSwap__InvalidToken();
        }

        // Determine the amount of token to be swapped
        (uint256 amount0Out, uint256 amount1Out) = token == address(weth) ? (amount, uint256(0)) : (uint256(0), amount);

        // Encode the data
        bytes memory data = abi.encode(token, msg.sender);

        // call the swap function
        pair.swap(amount0Out, amount1Out, address(this), data);
    }

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        // Check caller is pair contract
        if (msg.sender != address(pair)) {
            revert UniswapFlashSwap_InvalidCaller();
        }
        // Check sender is this contract
        if (sender != address(this)) {
            revert UniswapFlashSwap_InvalidSender();
        }

        // Decode the data
        (address token, address caller) = abi.decode(data, (address, address));

        // Detremine the amount borrowed
        uint256 amountBorrowed = token == address(weth) ? amount0 : amount1;

        // calculate flash swap fee
        uint256 fee = ((amountBorrowed * 3) / 997) + 1;

        // calculate the amount to repay
        amountToRepay = amountBorrowed + fee;

        // Transfer flash swap fee from caller to this contract
        IERC20(token).safeTransferFrom(caller, address(this), fee);

        // Repay to pair contract
        IERC20(token).safeTransfer(address(pair), amountToRepay);
    }
}
