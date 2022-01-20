import FUSD from 0xFUSD
import FBTC from 0xFBTC
import CoreInterfaces from 0xCOREINTERFACES
import FlowToken from 0xFLOWTOKEN
import SwapConfig from 0xSWAPCONFIG
import SwapError from 0xSWAPERROR

transaction(factoryAddress: Address, pairCode: String) {
    let newAccount: AuthAccount
    prepare(newAcct: AuthAccount) {
        log("Transaction Start --------------- create pair")
        
        log("newAcct address:".concat(newAcct.address.toString()))
        self.newAccount = newAcct
        log("factoryAcct address:".concat(factoryAddress.toString()))    
        let factoryCap = getAccount(factoryAddress).getCapability<&{CoreInterfaces.PairFactoryPublic}>(SwapConfig.PairFactoryPublicPath)
        log(factoryCap)
        let pairFactoryInstance = factoryCap.borrow() ?? panic("Cannot found pair factory public cap")
        var newPairAddress: Address = 0x0
        if (factoryAddress == newAcct.address) {
            newPairAddress = pairFactoryInstance.createPair(
                auth: self.newAccount, 
                pairCode: pairCode,
                token0Vault: <- FlowToken.createEmptyVault(), 
                token1Vault: <- FBTC.createEmptyVault()
            )
        } else {
            newPairAddress = pairFactoryInstance.createPair(
                auth: self.newAccount, 
                pairCode: pairCode,
                token0Vault: <- FBTC.createEmptyVault(), 
                token1Vault: <- FUSD.createEmptyVault()
            )
        }
        
        log("End -----------------------------")
    }
}
