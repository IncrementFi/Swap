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
        log("Transaction Start --------------- swap pair test")
        
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

        let factoryCap = getAccount(adminAcct.address).getCapability<&{CoreInterfaces.PairFactoryPublic}>(SwapConfig.PairFactoryPublicPath)
        log(factoryCap)
        let pairFactoryInstance = factoryCap.borrow() ?? panic("Cannot found pair factory public cap")
        
        let pairAddress = pairFactoryInstance.getPair(
                                                token0Identifier:fusdVault.getType().identifier,
                                                token1Identifier:fbtcVault.getType().identifier
                                            ) ?? panic("Cannot found pair address")
       
        let pairPubCap = getAccount(pairAddress).getCapability<&{CoreInterfaces.PairPublic}>(SwapConfig.PairPublicPath)
        log(pairPubCap)
        log(pairPubCap.check())
        let pairPubInstance = pairPubCap.borrow()??panic("Cannot found pair pub cap")
        var reserves = pairPubInstance.getReserves()
        var testAmount: UFix64 = 20.0        
        var amountOut = routerPubInstance.getAmountOut(
            amountIn: testAmount,
            reserveIn: reserves[0] as! UFix64,
            reserveOut: reserves[1] as! UFix64
        )
        log("Get Amount out(in:"
            .concat(testAmount.toString()).concat("):")
            .concat(amountOut.toString())
        )

        var amountIn = routerPubInstance.getAmountIn(
            amountOut: testAmount,
            reserveIn: reserves[0] as! UFix64,
            reserveOut: reserves[1] as! UFix64
        )
        log("Get Amount in(out:"
            .concat(testAmount.toString()).concat("):")
            .concat(amountIn.toString())
        )
        var identifiers: [String] = [fbtcVault.getType().identifier, fusdVault.getType().identifier]
        var amounts = routerPubInstance.getAmountsOut(
            amountIn: testAmount,
            identifiers: identifiers
        )
        log("amounts:".concat(amounts.length.toString()))
        for amount in amounts {
            log(amount.toString())
        }
        
        let outToken <- routerPubInstance.swapExactTokensForTokens(
            vaultIn: <- fbtcMinter.mintTokens(amount: testAmount),
            amountOutMin: 1.0,
            identifiers: identifiers
        )

        log("outToken : ".concat(outToken.getType().identifier).concat(" ").concat(outToken.balance.toString()))
        destroy outToken
        
        destroy fusdMinter
        destroy fbtcMinter
        destroy fbtcVault
        destroy fusdVault        

        log("End -----------------------------")
    }
}
