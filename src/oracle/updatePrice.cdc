import FixedWindowOracleExample from "./FixedWindowOracleExample.cdc"


transaction() {
    prepare(userAccount: AuthAccount) {
        FixedWindowOracleExample.updatePrice()
    }
}
 