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
        for i in tokenKeyPath {
            amounts.append(0.0)
        }
        amounts[0] = amountIn

        var i: Int = 0
        while (i < tokenKeyPath.length-1) {
            // TODO nil check
            let pairAddr = SwapFactory.getPairAddress(token0Key: tokenKeyPath[0], token1Key: tokenKeyPath[1])!
            
            // TODO nil check
            let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!

            amounts[i+1] = pairPublicRef.getAmountOut(amountIn: amounts[i])

            i = i + 1
        }
        
        return amounts
    }

    pub fun getAmountsIn(amountOut: UFix64, tokenKeyPath: [String]): [UFix64] {
        pre {
            tokenKeyPath.length >= 2: "Invalid path."
        }
        var amounts: [UFix64] = []
        for i in tokenKeyPath {
            amounts.append(0.0)
        }
        amounts[amounts.length-1] = amountOut

        var i: Int = tokenKeyPath.length-1
        while (i > 0) {
            // TODO nil check
            let pairAddr = SwapFactory.getPairAddress(token0Key: tokenKeyPath[0], token1Key: tokenKeyPath[1])!
            
            // TODO nil check
            let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!

            amounts[i-1] = pairPublicRef.getAmountIn(amountOut: amounts[i])

            i = i + 1
        }
        
        return amounts
    }

    pub fun swapLimited(
        vaultIn: @FungibleToken.Vault,
        tokenKeyPath: [String],
        amountOutMin: UFix64,
        deadlineTimeStamp: UFix64
    ) : @FungibleToken.Vault {
        let vaultOut <- self.swap(vaultIn: <-vaultIn, tokenKeyPath: tokenKeyPath)

        assert(vaultOut.balance > amountOutMin, message:
            SwapError.ErrorEncode(
                msg: "INSUFFICIENT_OUTPUT_AMOUNT",
                err: SwapError.ErrorCode.SLIPPAGE_OFFSET_TOO_LARGE
            )
        )
        // TODO timestamp check

        return <- vaultOut
    }

    /// swapExtactTokenForToken = swapTokenForExtactToken
    pub fun swap(
        vaultIn: @FungibleToken.Vault,
        tokenKeyPath: [String]
    ): @FungibleToken.Vault {
        pre {
            tokenKeyPath.length >= 2: "Invalid path."
        }
        // TODO if recursive's gas cost is high
        if tokenKeyPath.length > 5 {
            return <- self.swapRecursively(vaultIn: <-vaultIn, tokenKeyPath: tokenKeyPath, index: 0)
        }
        
        let vaultOut1 <- self.swapWithOnePair(vaultIn: <- vaultIn, token0Key: tokenKeyPath[0], token1Key: tokenKeyPath[1])
        if tokenKeyPath.length == 2 {
            return <- vaultOut1
        }

        let vaultOut2 <- self.swapWithOnePair(vaultIn: <- vaultOut1, token0Key: tokenKeyPath[1], token1Key: tokenKeyPath[2])
        if tokenKeyPath.length == 3 {
            return <- vaultOut2
        }

        let vaultOut3 <- self.swapWithOnePair(vaultIn: <- vaultOut2, token0Key: tokenKeyPath[2], token1Key: tokenKeyPath[3])
        if tokenKeyPath.length == 4 {
            return <- vaultOut3
        }

        let vaultOut4 <- self.swapWithOnePair(vaultIn: <- vaultOut3, token0Key: tokenKeyPath[3], token1Key: tokenKeyPath[4])
        return <- vaultOut4
    
        // TODO event
    }

    /// one to one
    pub fun swapWithOnePair(
        vaultIn: @FungibleToken.Vault,
        token0Key: String,
        token1Key: String
    ): @FungibleToken.Vault {
        let pairAddr = SwapFactory.getPairAddress(token0Key: token0Key, token1Key: token1Key)!
        let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
        
        return <- pairPublicRef.swap(inTokenAVault: <- vaultIn)
    }
    
    access(self) fun swapRecursively(
        vaultIn: @FungibleToken.Vault,
        tokenKeyPath: [String],
        index: Int
    ): @FungibleToken.Vault {
        
        let pairAddr = SwapFactory.getPairAddress(token0Key: tokenKeyPath[index], token1Key: tokenKeyPath[index+1])!

        // TODO nil check
        let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!

        var vaultOut <- pairPublicRef.swap(inTokenAVault: <- vaultIn)

        if index >= tokenKeyPath.length - 2 {
            return <- vaultOut
        } else {
            // recersive to avoid wrong cadence resource check
            return <- self.swapRecursively(vaultIn: <-vaultOut, tokenKeyPath: tokenKeyPath, index: index+1)
        }
    }

    /*
    TODO  test resource move in for / while
    pub fun swapExactTokensForTokens(
        vaultIn: @FungibleToken.Vault,
        tokenKeyPath: [String],
        amountOutMin: UFix64,
        deadlineTimeStamp: UFix64
    ) {
        //TODO timestamp check
        var amounts: [UFix64] = []
        for i in tokenKeyPath {
            amounts.append(0.0)
        }
        
        var i: Int = 0

        var vaultInCur: @FungibleToken.Vault <- vaultIn
        var vaultOut: @FungibleToken.Vault? <- nil
        
        while (i < tokenKeyPath.length-1) {
            // TODO nil check
            let pairAddr = SwapFactory.getPairAddress(token0Key: tokenKeyPath[i], token1Key: tokenKeyPath[i+1])!
            
            // TODO nil check
            let pairPublicRef: &{SwapInterfaces.PairPublic} = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!

            //vaultInCur <- pairPublicRef.swap(inTokenAVault: <- vaultInCur)
            vaultOut <- pairPublicRef.swap(inTokenAVault: <- vaultInCur)
            vaultInCur <-! vaultOut!

            i = i + 1
        }
        
        destroy vaultInCur
        return
    }
    */

    // TODO limited check
    /*
    pub fun addLiquidityLimited(
        tokenAVault: @FungibleToken.Vault,
        tokenBVault: @FungibleToken.Vault,
        amountADesired: UFix64,
        amountBDesired: UFix64,
        amountAMin: UFix64,
        amountBMin: UFix64,
        deadlineTimeStamp: UFix64
    ): @FungibleToken.Vault {
        
        return <- lpTokenVault
    }
    */


    pub fun addLiquidity(
        tokenAVault: @FungibleToken.Vault,
        tokenBVault: @FungibleToken.Vault
    ): @FungibleToken.Vault {
        let tokenAKey: String = SwapConfig.SliceTokenTypeIdentifierFromVaultType(vaultTypeIdentifier: tokenAVault.getType().identifier)
        let tokenBKey: String = SwapConfig.SliceTokenTypeIdentifierFromVaultType(vaultTypeIdentifier: tokenBVault.getType().identifier)
        // TODO nil check
        let pairAddr = SwapFactory.getPairAddress(token0Key: tokenAKey, token1Key: tokenBKey)!
        let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
        
        let lpTokenVault <- pairPublicRef.addLiquidity(tokenAVault: <-tokenAVault, tokenBVault: <-tokenBVault)

        return <- lpTokenVault
    }

    // TODO limited check
    /*
    pub fun removeLiquidity(
        lpTokenVault: @FungibleToken.Vault,
        pairAddr: Address,
        amountAMin: UFix64,
        amountBMin: UFix64,
        deadlineTimeStamp: UFix64
    ) : @[FungibleToken.Vault] {

    }
    */

    pub fun removeLiquidity(
        lpTokenVault: @FungibleToken.Vault,
        pairAddr: Address
    ) : @[FungibleToken.Vault] {
        
        // TODO nil check
        let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
        
        return <- pairPublicRef.removeLiquidity(lpTokenVault: <-lpTokenVault)
    }


}