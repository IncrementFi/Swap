import FungibleToken from "./tokens/FungibleToken.cdc"
import SwapFactory from "./SwapFactory.cdc"
import SwapConfig from "./SwapConfig.cdc"
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
            let pairAddr = SwapFactory.getPairAddress(token0Key: tokenKeyPath[0], token1Key: tokenKeyPath[1])!
            
            // TODO nil check
            let pairPublicRef: &{SwapInterfaces.PairPublic} = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!

            //vaultInCur <- pairPublicRef.swap(inTokenAVault: <- vaultInCur)
            vaultOut <-! pairPublicRef.swap(inTokenAVault: <- vaultInCur)
            vaultInCur <-! vaultOut

            i = i + 1
        }
        
        destroy vaultInCur
        return
    }

}