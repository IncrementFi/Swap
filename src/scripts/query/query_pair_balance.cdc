import FungibleToken from 0xFUNGIBLETOKENADDRESS
import SwapPair from 0xSWAPPAIR

pub fun main(account: Address, tokenBalancePath: PublicPath): UFix64 {
    let acct = getAccount(account)
    log(account)
    log(tokenBalancePath)
    
    let vaultRef = acct.getCapability<&SwapPair.Vault{FungibleToken.Balance}>(tokenBalancePath).borrow()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}