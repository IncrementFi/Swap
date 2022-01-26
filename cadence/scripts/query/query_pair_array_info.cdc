import SwapFactory from "../../contracts/SwapFactory.cdc"

pub fun main(from: UInt64, to: UInt64): [AnyStruct] {
    return SwapFactory.getPairArrInfo(from: from, to: to)
}