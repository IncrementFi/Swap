import FUSD from 0xFUSD
import FBTC from 0xFBTC
import CoreInterfaces from 0xCOREINTERFACES
import FlowToken from 0xFLOWTOKEN
import SwapConfig from 0xSWAPCONFIG
import SwapError from 0xSWAPERROR

transaction(factoryAddress: Address) {
    
    prepare(newAcct: AuthAccount) {
        log("Transaction Start --------------- check pair")
        
        let factoryCap = getAccount(factoryAddress).getCapability<&{CoreInterfaces.PairFactoryPublic}>(SwapConfig.PairFactoryPublicPath)
        log(factoryCap)
        let pairFactoryInstance = factoryCap.borrow() ?? panic("Cannot found pair factory public cap")
        let ft <- FlowToken.createEmptyVault()
        let btc <- FBTC.createEmptyVault()
        let pairAddress = pairFactoryInstance.getPair(
                                                token0Identifier:ft.getType().identifier,
                                                token1Identifier:btc.getType().identifier
                                            ) ?? panic("Cannot found pair address")
        destroy ft
        destroy btc
        log("newAcct address:".concat(pairAddress.toString()))
         
        let pairPubCap = getAccount(pairAddress).getCapability<&{CoreInterfaces.PairPublic}>(SwapConfig.PairPublicPath)
        log(pairPubCap)
        log(pairPubCap.check())
        let pairPubInstance = pairPubCap.borrow()??panic("Cannot found pair pub cap")
        log(pairPubInstance)
        log(pairPubInstance.getReserves())
        log(pairPubInstance.getFactory())
        
        log("End -----------------------------")
    }
}
