pub contract SwapConfig {
    pub var PairPublicPath: PublicPath
    pub var LpTokenCollectionStoragePath: StoragePath
    pub var LpTokenCollectionPublicPath: PublicPath

    // Scale factor applied to fixed point number calculation. For example: 1e18 means the actual baseRatePerBlock should
    // be baseRatePerBlock / 1e18. Note: The use of scale factor is due to fixed point number in cadence is only precise to 1e-8:
    // https://docs.onflow.org/cadence/language/values-and-types/#fixed-point-numbers
    // It'll be truncated and lose accuracy if not scaled up. e.g.: APR 20% (0.2) => 0.2 / 12614400 blocks => 1.5855e-8
    //  -> truncated as 1e-8.
    pub let scaleFactor: UInt256
    // 100_000_000.0, i.e. 1.0e8
    pub let ufixScale: UFix64
    // 0.00000001, i.e. 1e-8
    pub let ufix64NonZeroMin: UFix64
    /// Reserved parameter fields: {ParamName: Value}
    access(self) let _reservedFields: {String: AnyStruct}


    // Utility function to convert a UFix64 number to its scaled equivalent in UInt256 format
    // e.g. 184467440737.09551615 (UFix64.max) => 184467440737095516150000000000
    pub fun UFix64ToScaledUInt256(_ f: UFix64): UInt256 {
        let integral = UInt256(f)
        let fractional = f % 1.0
        let ufixScaledInteger =  integral * UInt256(self.ufixScale) + UInt256(fractional * self.ufixScale)
        return ufixScaledInteger * self.scaleFactor / UInt256(self.ufixScale)
    }
    // Utility function to convert a fixed point number in form of scaled UInt256 back to UFix64 format
    // e.g. 184467440737095516150000000000 => 184467440737.09551615
    pub fun ScaledUInt256ToUFix64(_ scaled: UInt256): UFix64 {
        let integral = scaled / self.scaleFactor
        let ufixScaledFractional = (scaled % self.scaleFactor) * UInt256(self.ufixScale) / self.scaleFactor
        return UFix64(integral) + (UFix64(ufixScaledFractional) / self.ufixScale)
    }

    pub fun UInt256ToUFix64(_ scaled: UInt256, _ scaleFactor: UInt256): UFix64 {
        let integral = scaled / scaleFactor
        let ufixScaledFractional = (scaled % scaleFactor) * UInt256(self.ufixScale) / scaleFactor
        return UFix64(integral) + (UFix64(ufixScaledFractional) / self.ufixScale)
    }
    
    pub fun UFix64ToUInt256(_ f: UFix64, _ scale: UFix64): UInt256 {
        let integral = UInt256(f)
        let fractional = f % 1.0
        return integral * UInt256(scale) + UInt256(fractional * scale)
    }

    /// SliceTokenTypeIdentifierFromVaultType
    ///
    /// @Param vaultTypeIdentifier - eg. A.f8d6e0586b0a20c7.FlowToken.Vault
    /// @Return tokenTypeIdentifier - eg. A.f8d6e0586b0a20c7.FlowToken
    ///
    pub fun SliceTokenTypeIdentifierFromVaultType(vaultTypeIdentifier: String): String {
        return vaultTypeIdentifier.slice(
            from: 0,
            upTo: vaultTypeIdentifier.length - 6
        )
    }

    // Helper function:
    // Compute √a using Newton's method. a ∈ [0.00000001, UFix64.max]
    pub fun sqrt(_ a: UFix64): UFix64 {
        var z = self.UFix64ToScaledUInt256(1.0)
        var one = z
        var y = self.UFix64ToScaledUInt256(a)        
        var min = self.UFix64ToScaledUInt256(self.ufix64NonZeroMin)
        if (y > one) {
            var x0 = y
            var b = ((a == UFix64.max) ? (self.UFix64ToScaledUInt256(a) / 2 + self.UFix64ToScaledUInt256(0.5)) : 
            ((self.UFix64ToScaledUInt256(a + 1.0)) / 2))
            while ((x0 > b + 1) || (b > x0 + 1)) {
                x0 = b
                b =  (x0 + y / x0) / 2
            }            
            z = b            
        } else if (y == one) {
            z = self.UFix64ToUInt256(1.0, 1_000_000_000.0)
        } else if (y > self.UFix64ToScaledUInt256(0.0)) {            
            z = self.UFix64ToUInt256(self.sqrt(a / self.ufix64NonZeroMin), 1_000_00.0)            
        } else {
            z = 0
        }        
        return self.UInt256ToUFix64(z+5, 1_000_000_000)
    }

    // Helper function:
    // Given pair reserves and the exact input amount of an asset, returns the maximum output amount of the other asset
    pub fun getAmountOut(amountIn: UFix64, reserveIn: UFix64, reserveOut: UFix64): UFix64 {
        pre {
            amountIn > 0.0: "SwapPair: insufficient input amount"
            reserveIn > 0.0 && reserveOut > 0.0: "SwapPair: insufficient liquidity"
        }
        let amountInScaled = SwapConfig.UFix64ToScaledUInt256(amountIn)
        let reserveInScaled = SwapConfig.UFix64ToScaledUInt256(reserveIn)
        let reserveOutScaled = SwapConfig.UFix64ToScaledUInt256(reserveOut)

        let amountInWithFeeScaled = SwapConfig.UFix64ToScaledUInt256(0.997) * amountInScaled / SwapConfig.scaleFactor

        let amountOutScaled = amountInWithFeeScaled * reserveOutScaled / (reserveInScaled + amountInWithFeeScaled)
        return SwapConfig.ScaledUInt256ToUFix64(amountOutScaled)
    }

    /// Helper function:
    /// Given pair reserves and the exact output amount of an asset wanted, returns the required (minimum) input amount of the other asset
    pub fun getAmountIn(amountOut: UFix64, reserveIn: UFix64, reserveOut: UFix64): UFix64 {
        pre {
            amountOut < reserveOut: "SwapPair: insufficient output amount"
            reserveIn > 0.0 && reserveOut > 0.0: "SwapPair: insufficient liquidity"
        }
        let amountOutScaled = SwapConfig.UFix64ToScaledUInt256(amountOut)
        let reserveInScaled = SwapConfig.UFix64ToScaledUInt256(reserveIn)
        let reserveOutScaled = SwapConfig.UFix64ToScaledUInt256(reserveOut)

        let amountInScaled = amountOutScaled * reserveInScaled / (reserveOutScaled - amountOutScaled) * SwapConfig.scaleFactor / SwapConfig.UFix64ToScaledUInt256(0.997)
        return SwapConfig.ScaledUInt256ToUFix64(amountInScaled) + SwapConfig.ufix64NonZeroMin
    }

    /// Helper function:
    /// Given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    pub fun quote(amountA: UFix64, reserveA: UFix64, reserveB: UFix64): UFix64 {
        pre {
            amountA > 0.0: "SwapPair: insufficient input amount"
            reserveB > 0.0 && reserveB > 0.0: "SwapPair: insufficient liquidity"
        }
        let amountAScaled = SwapConfig.UFix64ToScaledUInt256(amountA)
        let reserveAScaled = SwapConfig.UFix64ToScaledUInt256(reserveA)
        let reserveBScaled = SwapConfig.UFix64ToScaledUInt256(reserveB)

        var amountBScaled = amountAScaled * reserveBScaled / reserveAScaled
        return SwapConfig.ScaledUInt256ToUFix64(amountBScaled)
    }


    init() {
        self.PairPublicPath = /public/increment_swap_pair
        self.LpTokenCollectionStoragePath = /storage/increment_swap_lptoken_collection
        self.LpTokenCollectionPublicPath  = /public/increment_swap_lptoken_collection
        
        // 1e18
        self.scaleFactor = 1_000_000_000_000_000_000
        // 1.0e8
        self.ufixScale = 100_000_000.0

        self.ufix64NonZeroMin = 0.00000001

        self._reservedFields = {}
    }
}