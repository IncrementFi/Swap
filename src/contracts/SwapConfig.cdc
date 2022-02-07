pub contract SwapConfig {
    pub let PairPublicPath: PublicPath


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

    pub fun UFix64ToUInt256(_ f: UFix64, _ scale: UFix64): UInt256 {
        let integral = UInt256(f)
        let fractional = f % 1.0
        return integral * UInt256(scale) + UInt256(fractional * scale)
    }

    // Helper function:
    // Returns Types sorted by VaultType.identifier
    pub fun sortTokens(_ inTokenAVaultType: Type, _ inTokenBVaultType: Type): [Type; 2] {
        let tokenAString = inTokenAVaultType.identifier.slice(from: 2, upTo: inTokenAVaultType.identifier.length - 6)
        let tokenBString = inTokenBVaultType.identifier.slice(from: 2, upTo: inTokenBVaultType.identifier.length - 6)
        let tokenAUtf8 = tokenAString.utf8
        let tokenBUtf8 = tokenBString.utf8
        let len = tokenAUtf8.length < tokenBUtf8.length ? tokenAUtf8.length : tokenBUtf8.length
        var i = 0;
        while (i < len) {
            if (tokenAUtf8[i] == tokenBUtf8[i]) {
                i = i + 1
            } else if (tokenAUtf8[i] < tokenBUtf8[i]) {
                return [inTokenAVaultType, inTokenBVaultType]
            } else {
                return [inTokenBVaultType, inTokenAVaultType]
            }
        }
        if (i < tokenAUtf8.length) {
            return [inTokenBVaultType, inTokenAVaultType]
        } else if (i < tokenBUtf8.length) {
            return [inTokenAVaultType, inTokenBVaultType]
        } else {
            return [inTokenAVaultType, inTokenBVaultType]
        }
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
        if (a == 0.0 || a == 1.0) {
        return a
        }
        // scale up 1e8 for floating point number < 1.0 to get rid of precision issues
        if (a < 1.0) {
        return self.sqrt(a / self.ufix64NonZeroMin) / 10000.0
        }
        var x0 = a
        var x1 = (a == UFix64.max ? 0.5 * a + 0.5 : 0.5 * (a + 1.0))
        while ((x0 > x1 && x0 - x1 > self.ufix64NonZeroMin) || (x1 > x0 && x1 - x0 > self.ufix64NonZeroMin)) {
        x0 = x1
        x1 = 0.5 * x0 + 0.5 * a / x0
        }
        return x1
    }

    pub fun sqrt2(_ y: UFix64): UFix64 {
        var z = 1.0 as UFix64
        if (y > 3.0) {
            z = y
            var x = y / 2.0 + 1.0 as! UFix64
            while (x < z) {
                z = x
                x = (y / x + x) / 2.0 as! UFix64
            }
        } else if (y > 0.0) {
            z = 1.0 as! UFix64
        } else {
            z = 0.0 as! UFix64
        }
        return z
    }

    // Helper function:
    // Given pair reserves and the exact input amount of an asset, returns the maximum output amount of the other asset
    pub fun getAmountOut(amountIn: UFix64, reserveIn: UFix64, reserveOut: UFix64): UFix64 {
        pre {
            amountIn > 0.0: "SwapPair: insufficient input amount"
            reserveIn > 0.0 && reserveOut > 0.0: "SwapPair: insufficient liquidity"
        }
        let amountInWithFee = 0.997 * amountIn
        return amountInWithFee * reserveOut / (reserveIn + amountInWithFee)
    }

    // Helper function:
    // Given pair reserves and the exact output amount of an asset wanted, returns the required (minimum) input amount of the other asset
    pub fun getAmountIn(amountOut: UFix64, reserveIn: UFix64, reserveOut: UFix64): UFix64 {
        pre {
            amountOut < reserveOut: "SwapPair: insufficient output amount"
            reserveIn > 0.0 && reserveOut > 0.0: "SwapPair: insufficient liquidity"
        }
        return amountOut * reserveIn / (reserveOut - amountOut) / 0.997
    }


    init() {

        self.PairPublicPath = /public/increment_swap_pair

        
        // 1e18
        self.scaleFactor = 1_000_000_000_000_000_000
        // 1.0e8
        self.ufixScale = 100_000_000.0

        self.ufix64NonZeroMin = 0.00000001
    }
}