import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapFactory from "../../contracts/SwapFactory.cdc"
import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"
import SwapError from "../../contracts/SwapError.cdc"
import SwapRouter from "../../contracts/SwapRouter.cdc"
pub fun main(): AnyStruct {
    let token0Key = "A.1654653399040a61.FlowToken"
    let token1Key = "A.b19436aae4d94622.FiatToken"
    let token0In = 100.0
    let pairAddr = SwapFactory.getPairAddress(token0Key: token0Key, token1Key: token1Key)
        ?? panic("AddLiquidity: nonexistent pair ".concat(token0Key).concat(" <-> ").concat(token1Key).concat(", create pair first"))
    let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
    let pairInfo = pairPublicRef.getPairInfo()
    var token0Reserve = 0.0
    var token1Reserve = 0.0
    if token0Key == (pairInfo[0] as! String) {
        token0Reserve = (pairInfo[2] as! UFix64)
        token1Reserve = (pairInfo[3] as! UFix64)
    } else {
        token0Reserve = (pairInfo[3] as! UFix64)
        token1Reserve = (pairInfo[2] as! UFix64)
    }
    assert(token0Reserve != 0.0, message: "Cannot add liquidity zapped in a new pool.")
    let r0Scaled = SwapConfig.UFix64ToScaledUInt256(token0Reserve)
    let kplus1SquareScaled = SwapConfig.UFix64ToScaledUInt256(1.997*1.997)
    let kScaled = SwapConfig.UFix64ToScaledUInt256(0.997)
    let token0InScaled = SwapConfig.UFix64ToScaledUInt256(token0In)
    let q = SwapConfig.ScaledUInt256ToUFix64(SwapConfig.sqrt(
        r0Scaled * r0Scaled / SwapConfig.scaleFactor * kplus1SquareScaled / SwapConfig.scaleFactor
        + 4 * kScaled * r0Scaled / SwapConfig.scaleFactor * token0InScaled / SwapConfig.scaleFactor))
    let zappedAmount = (q - token0Reserve*1.997)/0.997/2.0
    let desireZappedAmount = 50.0
    var slippage = 0.0
    if (desireZappedAmount > zappedAmount) {
        slippage = (desireZappedAmount - zappedAmount) / desireZappedAmount * 100.0
    } else {
        slippage = (zappedAmount - desireZappedAmount) / desireZappedAmount * 100.0
    }
    return [zappedAmount, slippage]
}