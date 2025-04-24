# Uniswap-v2

- v2-periphery
- v2-core


# Swapping


**Swapping `X` token for `Y` token**
- first, user will call `swapExactTokensForTokens` from `router contract`
- User will transfer `X` token to X/Y token pool
- After transferring, router contract will call `swap function`
- X/Y pool will transfer `Y` token to user



1. **`swapExactTokensForTokens()`**:
   - Takes input token and returns `max amount of output token`
   - path[] = [WETH,DAI,MKR]
   - amounts[] = [1e18,1e18,1e18]
   - path[0] -> Input Token <==>  path[n-1] -> Output token
   - amounts[0] -> amount of input token
   - amounts[n-1] -> amount of output token
   - `getAmountsOut()` -> returns the amounts[] for amount of input token


2. **`swapTokensForExactTokens()`**:
   - Takes output token and returns `min amount of input token`
   - `getAmountsIn()` -> returns the amounts[] for amount of output token





# Sources

1. **Articles to understand v2 contract**:
   - https://medium.com/better-programming/uniswap-v2-in-depth-98075c826254
   - https://ethereum.org/en/developers/tutorials/uniswap-v2-annotated-code/


2. **v2-core and v2-periphery contract**:
   - https://github.com/Uniswap/v2-periphery
   - https://github.com/Uniswap/v2-core