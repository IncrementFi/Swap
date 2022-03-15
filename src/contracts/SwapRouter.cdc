import FungibleToken from "./tokens/FungibleToken.cdc"
import SwapFactory from "./SwapFactory.cdc"
import SwapConfig from "./SwapConfig.cdc"
import SwapError from "./SwapError.cdc"
import SwapInterfaces from "./SwapInterfaces.cdc"


pub contract SwapRouter {
    pub fun getAmountsOut(amountIn: UFix64, tokenKeyPath: [String]): [UFix64] {
        pre {
            tokenKeyPath.length >= 2: "Invalid path."
        }
        var amounts: [UFix64] = []
        for tokenKey in tokenKeyPath {
            amounts.append(0.0)
        }
        amounts[0] = amountIn

        var i: Int = 0
        while (i < tokenKeyPath.length-1) {
            // TODO nil check
            let pairAddr = SwapFactory.getPairAddress(token0Key: tokenKeyPath[i], token1Key: tokenKeyPath[i+1])!
            
            // TODO nil check
            let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!

            amounts[i+1] = pairPublicRef.getAmountOut(amountIn: amounts[i], tokenInKey: tokenKeyPath[i])

            i = i + 1
        }
        
        return amounts
    }

    pub fun getAmountsIn(amountOut: UFix64, tokenKeyPath: [String]): [UFix64] {
        pre {
            tokenKeyPath.length >= 2: "Invalid path."
        }
        var amounts: [UFix64] = []
        for tokenKey in tokenKeyPath {
            amounts.append(0.0)
        }
        amounts[amounts.length-1] = amountOut

        var i: Int = tokenKeyPath.length-1
        while (i > 0) {
            // TODO nil check
            let pairAddr = SwapFactory.getPairAddress(token0Key: tokenKeyPath[i], token1Key: tokenKeyPath[i-1])!
            
            // TODO nil check
            let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!

            amounts[i-1] = pairPublicRef.getAmountIn(amountOut: amounts[i], tokenOutKey: tokenKeyPath[i])

            i = i - 1
        }
        
        return amounts
    }

    pub fun swapExactTokensForTokens(
        vaultIn: @FungibleToken.Vault,
        amountOutMin: UFix64,
        tokenKeyPath: [String],
        deadline: UFix64
    ): @FungibleToken.Vault {
        let amounts = self.getAmountsOut(amountIn: vaultIn.balance, tokenKeyPath: tokenKeyPath)
        assert( amounts[amounts.length-1] >= amountOutMin, message:
            SwapError.ErrorEncode(
                msg: "SLIPPAGE_OFFSET_TOO_LARGE",
                err: SwapError.ErrorCode.SLIPPAGE_OFFSET_TOO_LARGE
            )
        )
        assert( deadline >= getCurrentBlock().timestamp, message:
            SwapError.ErrorEncode(
                msg: "EXPIRED",
                err: SwapError.ErrorCode.EXPIRED
            )
        )
        
        return <- self.swapWithPath(vaultIn: <-vaultIn, tokenKeyPath: tokenKeyPath, exactAmounts: nil)
    }

    pub fun swapTokensForExactTokens(
        vaultIn: @FungibleToken.Vault,
        amountOut: UFix64,
        tokenKeyPath: [String],
        deadline: UFix64
    ): @[FungibleToken.Vault; 2] {
        let amountInMax = vaultIn.balance
        let amounts = self.getAmountsIn(amountOut: amountOut, tokenKeyPath: tokenKeyPath)
        assert( amounts[0] <= amountInMax, message:
            SwapError.ErrorEncode(
                msg: "SLIPPAGE_OFFSET_TOO_LARGE",
                err: SwapError.ErrorCode.SLIPPAGE_OFFSET_TOO_LARGE
            )
        )
        assert( deadline >= getCurrentBlock().timestamp, message:
            SwapError.ErrorEncode(
                msg: "EXPIRED",
                err: SwapError.ErrorCode.EXPIRED
            )
        )
        
        let vaultInExact <- vaultIn.withdraw(amount: amounts[0])

        return <-[<-self.swapWithPath(vaultIn: <-vaultInExact, tokenKeyPath: tokenKeyPath, exactAmounts: amounts), <-vaultIn]
    }

    pub fun swapWithPath(vaultIn: @FungibleToken.Vault, tokenKeyPath: [String], exactAmounts: [UFix64]?): @FungibleToken.Vault {
        pre {
            tokenKeyPath.length >= 2: "Invalid path."
        }
        /// Split the loop to reduce gas cost
        var exactAmountOut1: UFix64? = nil
        if exactAmounts != nil { exactAmountOut1 = exactAmounts![1] }
        let vaultOut1 <- self.swapWithPair(vaultIn: <- vaultIn, exactAmountOut: exactAmountOut1, token0Key: tokenKeyPath[0], token1Key: tokenKeyPath[1])
        if tokenKeyPath.length == 2 {
            return <-vaultOut1
        }

        var exactAmountOut2: UFix64? = nil
        if exactAmounts != nil { exactAmountOut2 = exactAmounts![2] }
        let vaultOut2 <- self.swapWithPair(vaultIn: <- vaultOut1, exactAmountOut: exactAmountOut2, token0Key: tokenKeyPath[1], token1Key: tokenKeyPath[2])
        if tokenKeyPath.length == 3 {
            return <-vaultOut2
        }

        var exactAmountOut3: UFix64? = nil
        if exactAmounts != nil { exactAmountOut3 = exactAmounts![3] }
        let vaultOut3 <- self.swapWithPair(vaultIn: <- vaultOut2, exactAmountOut: exactAmountOut3, token0Key: tokenKeyPath[2], token1Key: tokenKeyPath[3])
        if tokenKeyPath.length == 4 {
            return <-vaultOut3
        }

        var exactAmountOut4: UFix64? = nil
        if exactAmounts != nil { exactAmountOut4 = exactAmounts![4] }
        let vaultOut4 <- self.swapWithPair(vaultIn: <- vaultOut3, exactAmountOut: exactAmountOut4, token0Key: tokenKeyPath[3], token1Key: tokenKeyPath[4])
        if tokenKeyPath.length == 5 {
            return <-vaultOut4
        }

        var index = 4
        var curVaultOut <- vaultOut4
        while(index < tokenKeyPath.length-1) {
            var in <- curVaultOut.withdraw(amount: curVaultOut.balance)
            
            var exactAmountOut: UFix64? = nil
            if exactAmounts != nil { exactAmountOut = exactAmounts![index+1] }
            var out <- self.swapWithPair(vaultIn: <- in, exactAmountOut: exactAmountOut, token0Key: tokenKeyPath[index], token1Key:tokenKeyPath[index+1])
            curVaultOut <-> out

            destroy out
            index = index + 1
        }
    
        // TODO event
        return <-curVaultOut
    }

    /// one to one
    pub fun swapWithPair(
        vaultIn: @FungibleToken.Vault,
        exactAmountOut: UFix64?,
        token0Key: String,
        token1Key: String
    ): @FungibleToken.Vault {
        let pairAddr = SwapFactory.getPairAddress(token0Key: token0Key, token1Key: token1Key)!
        let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!

        return <- pairPublicRef.swap(vaultIn: <- vaultIn, exactAmountOut: exactAmountOut)
    }

}