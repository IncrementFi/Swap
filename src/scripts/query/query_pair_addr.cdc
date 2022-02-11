import SwapFactory from "../../contracts/SwapFactory.cdc"

pub fun main(token0Key: String, token1Key: String): Address?  {
    return SwapFactory.getPairAddress(token0Key: token0Key, token1Key: token1Key)
}