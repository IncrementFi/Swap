import SwapFactory from "../contracts/SwapFactory.cdc"
import SwapInterfaces from "../contracts/SwapInterfaces.cdc"
import SwapConfig from "../contracts/SwapConfig.cdc"

/// Sliding window oracle
///
///
pub contract SlidingWindowOracleExample {
    struct Observation {
        pub var timestamp: UFix64
        pub var price0CumulativeScaled: UInt256
        pub var price1CumulativeScaled: UInt256
        init() {
            self.timestamp = 0.0
            self.price0CumulativeScaled = 0
            self.price1CumulativeScaled = 0
        }
    }

    pub var windowSize: Int

    pub var granularity: Int

    pub var periodSize: Int

    access(contract) let pairObservations: {Address: [Observation]}



    /// Window period of the average
    pub var PERIOD: UFix64
    /// Average price
    pub var price0Average: UFix64
    pub var price1Average: UFix64

    /// A.contractAddr.contractName: A.11111111.FlowToken, A.2222222.FUSD
    pub var token0Key: String
    pub var token1Key: String
    /// pair address in dex
    pub var pairAddr: Address

    /// Cumulative price/timestamp for the last update
    pub var price0CumulativeLastScaled: UInt256
    pub var price1CumulativeLastScaled: UInt256
    pub var blockTimestampLast: UFix64

    /// Init the price feed and the average period
    ///
    /// @Param - 
    /// @Param - 
    ///
    pub fun initPrice(windowSize: Int, granularity: Int) {
        pre {
            granularity > 1: "granularity is at least 1",
        }
        self.windowSize = windowSize
        self.granularity = granularity
        self.periodSize = windowSize / granularity
        self.pairObservations = {}
        


        self.PERIOD = period
        /// Get the pair address through PairFactory
        self.pairAddr = SwapFactory.getPairAddress(token0Key: tokenAKey, token1Key: tokenBKey)!
        
        let pairPublicRef = getAccount(self.pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!

        let pairInfo = pairPublicRef.getPairInfo()
        self.token0Key = pairInfo[0] as! String
        self.token1Key = pairInfo[1] as! String
        let reserve0 = pairInfo[2] as! UFix64
        let reserve1 = pairInfo[3] as! UFix64
        assert(reserve0*reserve1 != 0.0, message: "There's no liquidity in the pair")

        self.price0CumulativeLastScaled = pairPublicRef.getPrice0CumulativeLastScaled()
        self.price1CumulativeLastScaled = pairPublicRef.getPrice1CumulativeLastScaled()
        self.blockTimestampLast = pairPublicRef.getBlockTimestampLast()
        self.price0Average = 0.0
        self.price1Average = 0.0
    }

    /// Calculate the latest cumulative price based on the last cumulative record and the current price.
    ///
    /// @Return [
    ///            0 UInt256: current cumulative price0 scaled as 1e18
    ///            1 UInt256: current cumulative price1 scaled as 1e18
    ///            2  UFix64: current block timestamp
    ///         ]
    ///
    pub fun getCurrentCumulativePrices(): [AnyStruct; 3] {
        let pairPublicRef = getAccount(self.pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
        let currentBlockTimestamp = getCurrentBlock().timestamp
        var price0CumulativeLastScaled = pairPublicRef.getPrice0CumulativeLastScaled()
        var price1CumulativeLastScaled = pairPublicRef.getPrice1CumulativeLastScaled()
        let blockTimestampLast = pairPublicRef.getBlockTimestampLast()
        let pairInfo = pairPublicRef.getPairInfo()
        let reserve0 = pairInfo[2] as! UFix64
        let reserve1 = pairInfo[3] as! UFix64
        let reserve0Scaled = SwapConfig.UFix64ToScaledUInt256(reserve0)
        let reserve1Scaled = SwapConfig.UFix64ToScaledUInt256(reserve1)

        let currentPrice0CumulativeScaled: UInt256 = price0CumulativeLastScaled
        let currentPrice1CumulativeScaled: UInt256 = price1CumulativeLastScaled
        if (blockTimestampLast != currentBlockTimestamp) {
            let timeElapsed = currentBlockTimestamp - blockTimestampLast
            let timeElapsedScaled = SwapConfig.UFix64ToScaledUInt256(timeElapsed)
            currentPrice0CumulativeScaled = SwapConfig.overflowAddUInt256(currentPrice0CumulativeScaled, reserve1Scaled * timeElapsedScaled / reserve0Scaled)
            currentPrice1CumulativeScaled = SwapConfig.overflowAddUInt256(currentPrice1CumulativeScaled, reserve0Scaled * timeElapsedScaled / reserve1Scaled)
        }

        return [currentPrice0CumulativeScaled, currentPrice1CumulativeScaled, currentBlockTimestamp]
    }

    pub fun observationIndexOf(timestamp: UFix64): Int {

        return 0
    }

    /// Update the accumulated price if it exceeds the period.
    ///
    pub fun updatePrice(tokenAKey: String, tokenBKey: String) {
        let pairAddr = SwapFactory.getPairAddress(token0Key: tokenAKey, token1Key: tokenBKey)!
        if self.pairObservations.containsKey(pairAddr) == false {
            self.pairObservations[pairAddr] = []
            var index = 0
            while(index < self.granularity) {
                self.pairObservations[pairAddr].append(Observation())
                index = index + 1
            }

            let observationIndex = observationIndexOf(getCurrentBlock().timestamp)
            let ob: &Observation = self.pairObservations[pairAddr][observationIndex]
            
            let timeElapsed = getCurrentBlock().timestamp - ob.timestamp

            if (timeElapsed > )
        }

        let res = self.getCurrentCumulativePrices()
        let currentPrice0CumulativeScaled = res[0] as! UInt256
        let currentPrice1CumulativeScaled = res[1] as! UInt256
        let currentBlockTimestamp = res[2] as! UFix64

        let timeElapsed = currentBlockTimestamp - self.blockTimestampLast
        assert(timeElapsed >= self.PERIOD, message: "PERIOD_NOT_ELAPSED ".concat(timeElapsed.toString().concat("s")))
        let timeElapsedScaled = SwapConfig.UFix64ToScaledUInt256(timeElapsed)

        let price0AverageScaled = SwapConfig.underflowSubtractUInt256(currentPrice0CumulativeScaled, self.price0CumulativeLastScaled) * SwapConfig.scaleFactor / timeElapsedScaled
        let price1AverageScaled = SwapConfig.underflowSubtractUInt256(currentPrice1CumulativeScaled, self.price1CumulativeLastScaled) * SwapConfig.scaleFactor / timeElapsedScaled

        self.price0Average = SwapConfig.ScaledUInt256ToUFix64(price0AverageScaled)
        self.price1Average = SwapConfig.ScaledUInt256ToUFix64(price1AverageScaled)

        self.price0CumulativeLastScaled = currentPrice0CumulativeScaled
        self.price1CumulativeLastScaled = currentPrice1CumulativeScaled
        self.blockTimestampLast = currentBlockTimestamp
    }

    pub fun quote(tokenKey: String): UFix64 {
        if tokenKey == self.token0Key {
            return self.price0Average
        } else {
            return self.price1Average
        }
    }

    init() {
        self.windowSize = 0
        self.pairObservations = {}
        
        self.PERIOD = 60.0 // 1min
        self.token0Key = ""
        self.token1Key = ""
        self.price0CumulativeLastScaled = 0
        self.price1CumulativeLastScaled = 0
        self.blockTimestampLast = 0.0
        self.pairAddr = 0x00
        self.price0Average = 0.0
        self.price1Average = 0.0
    }
}
