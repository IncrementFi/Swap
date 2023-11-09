import StableSwapFactory from "../contracts/StableSwapFactory.cdc"
import SwapFactory from "../contracts/SwapFactory.cdc"
import SwapInterfaces from "../contracts/SwapInterfaces.cdc"
import SwapConfig from "../contracts/SwapConfig.cdc"

/// Fixed window oracle
///
/// Calculate the average price for the entire period based on the on-chain dex swap pair.
/// note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period
///
pub contract FixedWindowOracleExample {
    /// Window period of the average in seconds
    pub let PERIOD: UInt64
    /// A.contractAddr.contractName: A.11111111.FlowToken, A.2222222.FUSD
    pub let token0Key: String
    pub let token1Key: String
    pub let isStableswap: Bool
    /// pair address in dex
    pub let pairAddr: Address

    /// Average price for each PERIOD, updated once per PERIOD (updating interval could be longer than 1 PERIOD)
    pub var price0Average: UFix64
    pub var price1Average: UFix64

    /// Cumulative price/timestamp for the last update
    pub var price0CumulativeLastScaled: UInt256
    pub var price1CumulativeLastScaled: UInt256
    pub var blockTimestampLast: UFix64


    /// Update the accumulated price if it exceeds the period.
    pub fun update() {
        let now = getCurrentBlock().timestamp
        let timeElapsed = now - self.blockTimestampLast
        assert(timeElapsed >= UFix64(self.PERIOD), message: "PERIOD_NOT_ELAPSED ".concat(timeElapsed.toString().concat("s")))

        let res = SwapConfig.getCurrentCumulativePrices(pairAddr: self.pairAddr)
        let currentPrice0CumulativeScaled = res[0]
        let currentPrice1CumulativeScaled = res[1]
        let timeElapsedScaled = SwapConfig.UFix64ToScaledUInt256(timeElapsed)
        let price0AverageScaled = SwapConfig.underflowSubtractUInt256(currentPrice0CumulativeScaled, self.price0CumulativeLastScaled) * SwapConfig.scaleFactor / timeElapsedScaled
        let price1AverageScaled = SwapConfig.underflowSubtractUInt256(currentPrice1CumulativeScaled, self.price1CumulativeLastScaled) * SwapConfig.scaleFactor / timeElapsedScaled

        self.price0Average = SwapConfig.ScaledUInt256ToUFix64(price0AverageScaled)
        self.price1Average = SwapConfig.ScaledUInt256ToUFix64(price1AverageScaled)

        self.price0CumulativeLastScaled = currentPrice0CumulativeScaled
        self.price1CumulativeLastScaled = currentPrice1CumulativeScaled
        self.blockTimestampLast = now
    }

    /// Queries twap price data
    /// Returns 0.0 for data n/a or invalid input token
    pub fun twap(tokenKey: String): UFix64 {
        if (tokenKey == self.token0Key) {
            return self.price0Average
        } else if (tokenKey == self.token1Key) {
            return self.price1Average
        } else {
            return 0.0
        }
    }

    /// @Param - token{A|B}Key: e.g. A.f8d6e0586b0a20c7.FUSD
    /// @Param - isStableswap: whether the twap is for stableswap pair or not
    /// @Param - period: average period (in seconds)
    init(tokenAKey: String, tokenBKey: String, isStableswap: Bool, period: UInt64) {
        self.PERIOD = period
        self.isStableswap = isStableswap
        self.pairAddr = isStableswap ?
            StableSwapFactory.getPairAddress(token0Key: tokenAKey, token1Key: tokenBKey) ?? panic("non-existent stableswap-pair") :
            SwapFactory.getPairAddress(token0Key: tokenAKey, token1Key: tokenBKey) ?? panic("non-existent pair")

        let pairPublicRef = getAccount(self.pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()
            ?? panic("cannot borrow reference to PairPublic")
        let pairInfo = pairPublicRef.getPairInfo()
        self.token0Key = pairInfo[0] as! String
        self.token1Key = pairInfo[1] as! String
        let reserve0 = pairInfo[2] as! UFix64
        let reserve1 = pairInfo[3] as! UFix64
        assert(reserve0 * reserve1 != 0.0, message: "There's no liquidity in the pair")

        self.price0CumulativeLastScaled = pairPublicRef.getPrice0CumulativeLastScaled()
        self.price1CumulativeLastScaled = pairPublicRef.getPrice1CumulativeLastScaled()
        self.blockTimestampLast = pairPublicRef.getBlockTimestampLast()
        self.price0Average = 0.0
        self.price1Average = 0.0
    }
}