import SwapConfig from "../../contracts/SwapConfig.cdc"

pub fun main(input: UFix64): UFix64  {
    return SwapConfig.sqrt(input)
}