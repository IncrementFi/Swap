import FUSD from 0xFUSD
import FBTC from 0xFBTC
import CoreInterfaces from 0xCOREINTERFACES
import FlowToken from 0xFLOWTOKEN
import SwapConfig from 0xSWAPCONFIG
import SwapError from 0xSWAPERROR
import RouterInterfaces from 0xROUTERINTERFACES

transaction() {
    let newAccount: AuthAccount    
    prepare(newAcct: AuthAccount, adminAcct: AuthAccount) {
        log("Transaction Start --------------- add liquidity to pair")
        
        log("newAcct address:".concat(newAcct.address.toString()))
        self.newAccount = newAcct  
        let routerCap = getAccount(self.newAccount.address).getCapability<&{RouterInterfaces.LiquidityPoolPublic}>(SwapConfig.RouterLiquidityPoolPublicPath)        
        log(routerCap.check())
        let routerPubInstance = routerCap.borrow()??panic("Cannot found router pub cap")
        log(routerPubInstance)
        
        
        let fusdTokenAdmin = adminAcct.borrow<&FUSD.Administrator>(from: /storage/fusdAdmin)
            ?? panic("Could not borrow a reference to fusd admin resource")

        // Create a new minter resource and a private link to a capability for it in the admin's storage.
        let fusdMinter <- fusdTokenAdmin.createNewMinter()
        let fusdVault <- fusdMinter.mintTokens(amount: 1000.0)


        let fbtcTokenAdmin = adminAcct.borrow<&FBTC.Administrator>(from: /storage/fBTCAdmin)
             ?? panic("Could not borrow a reference to btc admin resource")

        // Create a new minter resource and a private link to a capability for it in the admin's storage.
        let fbtcMinter <- fbtcTokenAdmin.createNewMinter()        
        let fbtcVault <- fbtcMinter.mintTokens(amount: 2000.0)

        let tokens <- routerPubInstance.addLiquidity(            
            token0: <- fbtcVault,
            token1: <- fusdVault,
            amount0Min: 100.0,
            amount1Min: 100.0
        )
        log("token0 : ".concat(tokens[0].getType().identifier).concat(" ").concat(tokens[0].balance.toString()))
        log("token1 : ".concat(tokens[1].getType().identifier).concat(" ").concat(tokens[1].balance.toString()))
        log("lptoken : ".concat(tokens[2].getType().identifier).concat(" ").concat(tokens[2].balance.toString()))
        
        let tokens2 <- routerPubInstance.addLiquidity(            
            token0: <- fbtcMinter.mintTokens(amount: 200.0),
            token1: <- fusdMinter.mintTokens(amount: 200.0),
            amount0Min: 100.0,
            amount1Min: 100.0
        )
        log("token0 : ".concat(tokens2[0].getType().identifier).concat(" ").concat(tokens2[0].balance.toString()))
        log("token1 : ".concat(tokens2[1].getType().identifier).concat(" ").concat(tokens2[1].balance.toString()))
        log("lptoken : ".concat(tokens2[2].getType().identifier).concat(" ").concat(tokens2[2].balance.toString()))

        //let lpToken <- tokens[2].withdraw(amount: tokens[2].balance - UFix64(10.0))
        /*
        let lpToken2 <- tokens2[2].withdraw(amount: tokens2[2].balance)
        
        let repayTokens <- routerPubInstance.removeLiquidity(
            token0Identifier: tokens[0].getType().identifier,
            token1Identifier: tokens[1].getType().identifier,
            lpToken: <- lpToken2,
            amount0Min: 10.0,
            amount1Min: 10.0   
        )
        log("repay token0 : ".concat(repayTokens[0].getType().identifier).concat(" ").concat(repayTokens[0].balance.toString()))
        log("repay token1 : ".concat(repayTokens[1].getType().identifier).concat(" ").concat(repayTokens[1].balance.toString()))

        destroy repayTokens        
        */
        destroy fusdMinter
        destroy fbtcMinter
        destroy tokens
        destroy tokens2

        log("End -----------------------------")
    }
}
