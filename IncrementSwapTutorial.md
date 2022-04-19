# Increment-Swap

## Introduction
A Uniswap-V2 like AMM-based decentralized exchange (DEX) on flow blockchain. It allows users to create arbitrary trading pairs between fungible tokens in a permissionless way, including basic functionalities like CreatePair, AddLiquidity, RemoveLiquidity, Swap, TWAP-Oracle, etc.
* It adopts the factory pattern that each unique trading pair is deployed using the SwapPair template file, with a factory contract storing all deployed pairs.
* On-chain time-weighted average price oracle of each of the trading pair is supported by snapshoting cumulative data on the first call of any block. Developers can choose different window size to support different TWAP data.
* The trading fee is fixed to 0.3%, with all of fees going to liquidity providers (LP) initially. However, there's a switch that factory admin can opt to turn on to earn 1/6 of the trading fees.
* Flash swap is not supported initially.

### Token Identifier
On flow blockchain, the unique identifier for a fungible token is composed of "A" + token address + contract name.

For example:
| FVM | EVM |
| :-: | :-: |
| A.e223d8a629e49c68.FUSD | 0x55d398326f99059fF775485246999027B3197955 |

Some token identifiers on mainnet:
| Token | Identifiter |
| ---: | :--------- |
| FlowToken | A.1654653399040a61.FlowToken |
| FUSD | A.3c5959b568896393.FUSD|
| USDC | A.b19436aae4d94622.FiatToken |
| tUSDT | A.cfdd90d4a00f7b5b.TeleportedTetherToken |
| ceWETH | A.231cc0dbbcffc4b7.ceWETH |
| ceWBTC | A.231cc0dbbcffc4b7.ceWBTC |

It can be found that the ceWETH, ceWBTC are deployed in the same address with different contract names.

### Vault Path of Token
On flow blockchain, token is stored in a resource object called `vault` which is saved in the user account's local storage.
Every fungible tokens has their own vault. And each vault is saved in different storage path.

For example:
FUSD token is stored in FUSD vault which located at user's `/storage/fusdVault` path. And FlowToken vault is saved at `/storage/flowTokenVault`. 

Please find more token addresses and paths at [github: flow-token-list](https://github.com/FlowFans/flow-token-list/blob/main/src/tokens/flow-mainnet.tokenlist.json)

### Create local vault for new token
An empty vault need to be created in the user's local storage before first holding the token.
For example: when first using FUSD token, an empty vault need to be created in the local storage.
#### transaction: create_FUSD_vault.cdc
```cadence
    import FUSD from 0xe223d8a629e49c68
    import FungibleToken from 0x9a0766d93b6608b7
    transaction() {
        prepare(userAccount: AuthAccount) {
            let vaultPath = /storage/fusdVault
            let receiverPath = /public/fusdReceiver
            let balancePath = /public/fusdBalance

            if userAccount.borrow<&FungibleToken.Vault>(from: vaultPath) == nil {
                userAccount.save(<- FUSD.createEmptyVault(), to: vaultPath)
                userAccount.link<&FUSD.Vault{FungibleToken.Receiver}>(receiverPath, target: vaultPath)
                userAccount.link<&FUSD.Vault{FungibleToken.Balance}>(balancePath, target: vaultPath)
            }
        }
    }
```
After the local vault is created, you can deposit or withdraw token with it.
The vault of FlowToken does not need to be initialized and it will be automatically generated when an account is created.


---

## Contract Addresses
| Contract | Address |
| --: | :-- |
| SwapFactory | 0xb063c16cac85dbd1 |
| SwapRouter | 0xa6850776a94e6551 |
| SwapConfig | 0xb78ef7afa52ff906 |
| SwapInterfaces | 0xb78ef7afa52ff906 |
| SwapError | 0xb78ef7afa52ff906 |

## A quick example swap from Flow to FUSD
Similar to uniswap, most interactions with Dex are done through SwapRouter.

### transaction: swap_exact_Flow_for_FUSD.cdc
```cadence
    import FungibleToken from 0xf233dcee88fe0abe
    import SwapRouter from 0xa6850776a94e6551
    /// SwapExactTokensForTokens
    ///
    /// Make sure the exact amountIn in swap start
    /// @Param  - tokenKeyPath:  Chained swap
    ///                          e.g. if swap from FUSD to USDC through FlowToken
    ///                               [A.3c5959b568896393.FUSD, A.1654653399040a61.FlowToken, A.b19436aae4d94622.FiatToken]
    /// @Param  - exactAmountIn: Exact amountIn which will be withdrawn from local vault
    /// @Param  - amountOutMin:  Desired minimum amountOut to do slippage check
    /// @Param  - deadline:      The timeout block timestamp for the transaction
    transaction(
        tokenKeyPath: [String],
        exactAmountIn: UFix64,
        amountOutMin: UFix64,
        deadline: UFix64
    ) {
        prepare(userAccount: AuthAccount) {
            let tokenInVaultPath = /storage/flowTokenVault
            let tokenOutVaultPath = /storage/fusdVault
            
            var tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)!
            
            let exactVaultIn <- userAccount.borrow<&FungibleToken.Vault>(from: tokenInVaultPath)!.withdraw(amount: exactAmountIn)
            /// SwapExactTokensForTokens
            let vaultOut <- SwapRouter.swapExactTokensForTokens(
                exactVaultIn: <-exactVaultIn,
                amountOutMin: amountOutMin,
                tokenKeyPath: tokenKeyPath,
                deadline: deadline
            )
            tokenOutReceiverRef.deposit(from: <-vaultOut)
        }
    }
```
* Run under flow CLI to Swap from 0.1 FlowToken to FUSD with unlimited slippage and timeout:
```bash
    flow transactions send ./swap_exact_Flow_for_FUSD.cdc \
        '["A.1654653399040a61.FlowToken", "A.3c5959b568896393.FUSD"]' \
        0.1 \
        0.0 \
        4849184416.0 \
        --network mainnet\
        --signer mainnet-user
```


### transaction: Swap FlowToken for exact FUSD
```cadence
    /// SwapTokensForExactTokens
    ///
    /// @Param  - tokenKeyPath:   Chained swap
    ///                           e.g. if swap from FUSD to USDC through FlowToken
    ///                                [A.f8d6e0586b0a20c7.FUSD, A.f8d6e0586b0a20c7.FlowToken, A.f8d6e0586b0a20c7.USDC]
    /// @Param  - amountInMax:    Vault with enough input to swap, checks slippage
    /// @Param  - exactAmountOut: Make sure the exact amountOut in swap end
    /// @Param  - deadline:       The timeout block timestamp for the transaction
    import FungibleToken from 0xf233dcee88fe0abe
    import SwapRouter from 0xa6850776a94e6551

    transaction(
        tokenKeyPath: [String],
        amountInMax: UFix64,
        exactAmountOut: UFix64,
        deadline: UFix64
    ) {
        prepare(userAccount: AuthAccount) {
            let tokenInVaultPath = /storage/flowTokenVault
            let tokenOutVaultPath = /storage/fusdVault
            
            var tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
            
            let vaultInRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenInVaultPath)
            let vaultInMax <- vaultInRef!.withdraw(amount: amountInMax)
            /// SwapTokensForExactTokens
            let swapResVault <- SwapRouter.swapTokensForExactTokens(
                vaultInMax: <-vaultInMax,
                exactAmountOut: exactAmountOut,
                tokenKeyPath: tokenKeyPath,
                deadline: deadline
            )
            let vaultOut <- swapResVault.removeFirst()
            let vaultInLeft <- swapResVault.removeLast()
            destroy swapResVault

            tokenOutReceiverRef!.deposit(from: <-vaultOut)
            vaultInRef!.deposit(from: <-vaultInLeft)
        }
    }
```
* Run under flow CLI to Swap from FlowToken to exact 0.2 FUSD with unlimited slippage and timeout:
```bash
    flow transactions send ./swap_tokens_for_exact_tokens.cdc \
        '["A.1654653399040a61.FlowToken", "A.3c5959b568896393.FUSD"]' \
        0.2 \
        0.0 \
        4849184416.0 \
        --network mainnet\
        --signer mainnet-user
```


### Setup the deadline paramter
* Query the current timestamp before sending the swap transaction
```cadence
    // script: query current timestamp
    pub fun main(): UFix64 {
        return getCurrentBlock().timestamp  // return 1649415103.00000000(seconds)
}
```
* If the desired timeout is ten minutes, add 60*10 = 600 seconds to the current timestamp. The transaction will revert if it is pending over this deadline timestamp.
```cadence
    deadline = 1649415103.00000000 + 600.0
```

### Setup the slippage
* Before sending the swap transaction, use the script:getAmountsOut() to calculate how much FUSD can be exchanged out currently.
1. Script: getAmountsOut()
```cadence
    /// Perform a chained swap calculation starting with exact amountIn
    ///
    /// @Param  - amountIn:     e.g. 50.0
    /// @Param  - tokenKeyPath: e.g. [A.f8d6e0586b0a20c7.FUSD, A.f8d6e0586b0a20c7.FlowToken, A.f8d6e0586b0a20c7.USDC]
    /// @Return - [UFix64]:     e.g. [50.0, 10.0, 48.0]
    ///
    import SwapRouter from 0xa6850776a94e6551
    pub fun main(): UFix64 {
        let amounts: [UFix64] = SwapRouter.getAmountsOut(
            amountIn: 0.1,
            tokenKeyPath: ["A.1654653399040a61.FlowToken", "A.3c5959b568896393.FUSD"]
        )
        return amounts[1] // return 0.23677003
    }
```

2. If the slippage setting is 10%, the value of the parameter `amountOutMin` is 0.53*0.9
```cadence
    amountOutMin = 0.23677003 * 0.9
```

3. Similarly, getAmountsIn() performs a chained swap calculation end with exact amountOut
```cadence
    import SwapRouter from 0xe8987e89f3f69baf
    pub fun main(): UFix64 {
        let amounts: [UFix64] = SwapRouter.getAmountsIn(
            amountOut: 0.23677003,
            tokenKeyPath: ["A.1654653399040a61.FlowToken", "A.3c5959b568896393.FUSD"]
        )
        return amounts[0]  // return 0.1
    }
```


### Script: Query all pools' balances
```cadence
    import SwapFactory from 0xb063c16cac85dbd1
    pub fun main(): [AnyStruct] {
        return SwapFactory.co(from: 0, to: 9999)
    }
    /*
    returns
    [
        [
            "A.f9dad0d4c14a92b5.wFlow",  // TokenKeyA
            "A.e5b5624186770886.FUSD",   // TokenKeyB
            1565444.37373731,            // TokenA Balance
            9981433.96018309,            // TokenB Balance
            0xeed888ccf5740766,          // Pair Address
            3952847.07521047             // Total lpTokens
        ]
    ]
    */
```

### Script: Query pool's balance by TokenKeys
```cadence
    import SwapFactory from 0xb063c16cac85dbd1
    pub fun main(token0Key:String, token1Key:String): AnyStruct? {

        return SwapFactory.getPairInfo(token0Key: token0Key, token1Key: token1Key)
    }
```

### Script: Query user's local FUSD vault balance
```cadence
    import FungibleToken from 0xf233dcee88fe0abe

    pub fun main(userAddr: Address): UFix64 {
        let vaultPath = /public/fusdBalance

        let vaultBalance = getAccount(userAddr).getCapability<&{FungibleToken.Balance}>(vaultPath)
        if vaultBalance.check() == false || vaultBalance.borrow() == nil {
            return 0.0
        } else {
            return vaultBalance.borrow()!.balance
        }
    }
```

