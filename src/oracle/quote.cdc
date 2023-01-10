import FixedWindowOracleExample from "./FixedWindowOracleExample.cdc"

pub fun main(): [UFix64] {
    return [
        FixedWindowOracleExample.quote(tokenKey: "A.f8d6e0586b0a20c7.FUSD"),
        FixedWindowOracleExample.quote(tokenKey: "A.f8d6e0586b0a20c7.USDC")
    ]
}