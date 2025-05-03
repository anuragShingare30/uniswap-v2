# Uniswap-v2

**Main Contracts for uniswap-v2:**
- v2-periphery
- v2-core



# Constant Product Formula


- X => Reserves of token X in Pool before swap
- Y => Reserves of token Y in Pool before swap
- dX => amountIn
- dY => amountOut 
- F => TNX fees == 0.03


- `Before Swap`
   **(X*Y) = K**
- `After Swap`
   **(X + (dX*(1-F))) * (Y - dY) = newK**
- AMM's always follow the basic condition after swap:
   **newK >= oldK**




# Swapping


**Swapping `X` token for `Y` token**
- first, user will call `swapExactTokensForTokens` from `router contract`
- User will transfer `X` token to X/Y token pool
- After transferring, router contract will call `swap function`
- X/Y pool will transfer `Y` token to user


**General Terms in swapping function:**
- path[] = [WETH,DAI,MKR]
- amounts[] = [1e18,1e18,1e18]
- path[0] -> Input Token <==>  path[n-1] -> Output token
- amounts[0] -> amount of input token
- amounts[n-1] -> amount of output token



1. **`swapExactTokensForTokens()`**:
   - **This function allows users to swap an exact amount of one token for another token**
   - Takes input amount for token
   - Calculates how much output tokens user will recieve
   - Transfer input token to token pool contract
   - Executes `swap()` through the specified path of tokens
   - Lastly, sends output amount to user
   - `getAmountsOut() and getAmountOut()` are common function used


2. **`swapTokensForExactTokens()`**:
   - User specifies how much output amount they expect
   - Protocol calculates the input amount for the specified output amount
   - After verifying -> input amount from user address is `tranfer()` to token pool
   - `swap()` is executed
   - Output token will be transferred to user address
   - `getAmountsIn() and getAmountIn()`


3. **`getAmountsOut() && getAmountOut()`**:
   - The function helps to get the maximum amount out by specifying the input amount
   - User specifies input amount
   - Function will calculate max amount out possible 



- X => Reserves of token X in Pool before swap
- Y => Reserves of token Y in Pool before swap
- dX => amountIn
- dY => amountOut 
- F => TNX fee == 0.03

4. **`swap()`**:
   - This function follows **constant product formula in AMM**:
   - This is one of the main function used for swapping tokens!!!
   - Here we are `swapping X tokens for Y`

   - `Before Swap`
      **(X*Y) = K**
   - `After Swap`
      **(X + (dX*(1-F))) * (Y - dY) = newK**
   - AMM's always follow the basic condition after swap:
      **newK >= oldK**





# Create token pool


1. **createPair()**:
   - This function helps to create the token pair for provided X/Y tokens.
   - `createPair()` is useful during adding liquidity. If pair not exist already this function will create the pair address for tokens


2. **getpair()**:
   - This function returns the address of the token pair
   - If pair not exist returns `address(0)`




# Add Liquidity

**`Note`**:
   - Price of AMM(before) == Price of AMM(after)
   - `applicable for both adding and removing liquidity`


- A liquidity provider (LP) adds equal value of two tokens (say ETH and DAI) to a Uniswap V2 pair contract.
- In return, they receive LP tokens, which represent their share in the pool.
- **Concepts**: `constant product formula, LP tokens, spot price ratio`


**Flow of adding Liquidity**:
1. User calls `addLiquidity()` from router contract
2. Router contract checks whether pair exist or not `getPair()`. If not they will create pair for tokens(X and Y) `createPair()`
3. User will transfer (X n Y) tokens in `equal ratio` to pair contract
4. Here, we will follow `constant product formula` and `spot price ratio` concept to determine the ratio and reserves of tokens in pair contract
5. Router contract will call `mint()`
6. Upon calling mint(), pair contract will transfer `LP tokens` to user
7. **`LP tokens`** -> Keeps the track of liquidity provided by provider `and` Represent ownership in pair contract




# Remove Liquidity

**`Note`**:
   - Price of AMM(before) == Price of AMM(after)

- The Liquidity provider redeems their/burn `LP tokens` to withdraw their share of the pool’s tokens.


**flow of removing liquidity:**
1. User call `removeLiquidity()` from router contract
2. User will `transfer/burn LP tokens` to tokens pair contract
3. Router will call `burn()` function
4. Pair contract will `transfer() X and Y tokens` to user





# Flash Swap

- **Note: Borrowed amount of token should be repaid including fee to pair contract**
- You can borrow tokens from a Uniswap V2 pool for free, use them for something in the same transaction, and then return them (with fees) — all in one block.

- Here, we execute `swap()` and pass `data parameters` to init the `flashswap`.


**flow of flashswap**:
1. When we call `swap()` pass `data params` with some encoded data to init `flashswap`
2. During `flashswap` -> amount to borrowed should be mention and amount not borrowed should be zero
3. Call `swap(amount,0) from pair contract` to init `flashswap`
4. Calculate the `fee and amountToRepay`

```solidity
// Determine the amount borrowed
uint256 amountBorrowed = token == token0 ? amount0 : amount1;

// calculate flash swap fee
uint256 fee = ((amountBorrowed * 3) / 997) + 1;

// calculate the amount to repay
uint256 amountToRepay = amountBorrowed + fee;

```

5. Transfer the `amountToRepay` to pair contract





# Arbitrage (Uniswap and Sushiswap v2 protocol)

- Arbitrage can be performed by -> `swap and flashswap` mechanism
- Check the same token amount on different protocol (Uniswap and Sushiswap)


**Flow of Arbitrage on (Uniswap and Sushiswap):**
1. Borrow 3000 DAI from `DAI/MKR pair contract`
2. Swap 3000 DAI for WETH from `DAI/WETH pair contract from Uniswap`
3. Swap WETH for 3100 DAI from `DAI/WETH pair contract from sushiswap`
4. Repay the borrowed amount to `DAI/MKR pair contract including fee`
5. Calculate the profit gain



```solidity
uint256 amountBorrowed = 3000 DAI

uint256 amountFromSwap = 3100 DAI

uint256 amountToRepay = amountBorrowed + fee = 3010 DAI

uint256 profit = amountFromSwap - amountToRepay = 90 DAI
```






# Sources

1. **Articles to understand v2 contract**:
   - https://medium.com/better-programming/uniswap-v2-in-depth-98075c826254
   - https://ethereum.org/en/developers/tutorials/uniswap-v2-annotated-code/


2. **v2-core and v2-periphery contract**:
   - https://github.com/Uniswap/v2-periphery
   - https://github.com/Uniswap/v2-core