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




# createpair() function






# Sources

1. **Articles to understand v2 contract**:
   - https://medium.com/better-programming/uniswap-v2-in-depth-98075c826254
   - https://ethereum.org/en/developers/tutorials/uniswap-v2-annotated-code/


2. **v2-core and v2-periphery contract**:
   - https://github.com/Uniswap/v2-periphery
   - https://github.com/Uniswap/v2-core