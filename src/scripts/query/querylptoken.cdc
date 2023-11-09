import SwapFactory from "../../contracts/SwapFactory.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"
import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"

pub fun main(userAddr: Address): {Address: UFix64} {
    var lpTokenCollectionPublicPath = SwapConfig.LpTokenCollectionPublicPath
    let lpTokenCollectionCap = getAccount(userAddr).getCapability<&{SwapInterfaces.LpTokenCollectionPublic}>(lpTokenCollectionPublicPath)
    if lpTokenCollectionCap.check() == false {
        return {}
    }
    let lpTokenCollectionRef = lpTokenCollectionCap.borrow()!
    let liquidityPairAddrs = lpTokenCollectionRef.getAllLPTokens()
    var res: {Address: UFix64} = {}
    for pairAddr in liquidityPairAddrs {
        var lpTokenAmount = lpTokenCollectionRef.getLpTokenBalance(pairAddr: pairAddr)
        res[pairAddr] = lpTokenAmount
    }
    return res
}