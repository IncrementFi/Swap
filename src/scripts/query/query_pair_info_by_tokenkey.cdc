import SwapFactory from "../../contracts/SwapFactory.cdc"
import StableSwapFactory from "../../contracts/StableSwapFactory.cdc"

pub fun main(token0Key: String ,token1Key: String, stableMode: Bool): AnyStruct? {
    if stableMode {
        return StableSwapFactory.getPairInfo(token0Key: token0Key, token1Key: token1Key)
    } else {
        return SwapFactory.getPairInfo(token0Key: token0Key, token1Key: token1Key)
    }
}