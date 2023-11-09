import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapFactory from "../../contracts/SwapFactory.cdc"
import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"

transaction(
    pairAddr: Address,
    lpTokenAmount: UFix64,
    toAddr: Address
) {
    prepare(userAccount: AuthAccount) {
        let lpTokenCollectionFrom = userAccount.borrow<&SwapFactory.LpTokenCollection>(from: SwapConfig.LpTokenCollectionStoragePath)
            ?? panic("Cannot borrow reference to LpTokenCollection")
        let lpTokenCollectionTo = getAccount(toAddr).getCapability<&{SwapInterfaces.LpTokenCollectionPublic}>(SwapConfig.LpTokenCollectionPublicPath).borrow()
            ?? panic("Cannot borrow reference to tansfer target user's LpTokenCollection")

        let lpTokenTransfer <- lpTokenCollectionFrom.withdraw(pairAddr: pairAddr, amount: lpTokenAmount)
        lpTokenCollectionTo.deposit(pairAddr: pairAddr, lpTokenVault: <- lpTokenTransfer)
    }
}