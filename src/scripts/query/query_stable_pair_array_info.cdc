import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapFactory from "../../contracts/SwapFactory.cdc"
import StableSwapFactory from "../../contracts/StableSwapFactory.cdc"

/**
    [
        [
            token0Key,            // 0
            token1Key,
            token0Vault.balance,
            token1Vault.balance,
            SwapPair.address,
            totalSupply,          // 5
            liquiditySource,
            ammAlgo,
            swapFeeBps,
            stableCurveP
        ]
    ]
*/
pub fun main(from: UInt64, to: UInt64): [AnyStruct] {
    let poolInfos: [AnyStruct] = [];
    // increment-stable
    let increment_stable: [AnyStruct] = StableSwapFactory.getSlicedPairInfos(from: from, to: to)
    for element in increment_stable {
        let poolInfo = element as! [AnyStruct]
        poolInfos.append([poolInfo[0], poolInfo[1], poolInfo[2], poolInfo[3], poolInfo[4], poolInfo[5], "increment-stable", "solidly", poolInfo[6], poolInfo[8]])
    }
    return poolInfos
}