import FixedWindowOracleExample from "./FixedWindowOracleExample.cdc"
transaction() {
    prepare(userAccount: AuthAccount) {
        FixedWindowOracleExample.initPrice(tokenAKey: "A.f8d6e0586b0a20c7.FUSD", tokenBKey: "A.f8d6e0586b0a20c7.USDC", period: 60.0)
    }
}
