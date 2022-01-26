import SwapFactory from "../../contracts/SwapFactory.cdc"

pub fun main(from: UInt64, to: UInt64): [Address] {
    return SwapFactory.getPairArrAddr(from: from, to: to)
}