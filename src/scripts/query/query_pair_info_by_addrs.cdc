import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"

pub fun main(pairAddrs: [Address]): [AnyStruct] {
    var res: [AnyStruct] = []
    var i = 0
    var len = pairAddrs.length
    while(i < len) {
        res.append(
            getAccount(pairAddrs[i]).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!.getPairInfo()
        )
        i = i + 1
    }
    return res
}
 