import FungibleToken from "./tokens/FungibleToken.cdc"

pub contract interface SwapInterfaces {
    // IdentityCertificate resource which is used to identify account address or perform caller authentication
    pub resource interface IdentityCertificate {}

    pub resource interface PairPublic {
        pub fun addLiquidity(tokenAVault: @FungibleToken.Vault, tokenBVault: @FungibleToken.Vault): @FungibleToken.Vault
        pub fun removeLiquidity(lpTokenVault: @FungibleToken.Vault) : @[FungibleToken.Vault]
        pub fun swap(vaultIn: @FungibleToken.Vault, exactAmountOut: UFix64?): @FungibleToken.Vault
        pub fun getAmountIn(amountOut: UFix64, tokenOutKey: String): UFix64
        pub fun getAmountOut(amountIn: UFix64, tokenInKey: String): UFix64
        pub fun getPairInfo(): [AnyStruct]
        pub fun getLpTokenVaultType(): Type
    }

    pub resource interface LpTokenCollectionPublic {
        pub fun deposit(pairAddr: Address, lpTokenVault: @FungibleToken.Vault)
        pub fun getCollectionLength(): Int
        pub fun getLpTokenBalance(pairAddr: Address): UFix64
        pub fun getAllLiquidityPairAddrs(): [Address]
        pub fun getLiquidityPairAddrsSliced(from: UInt64, to: UInt64): [Address]
    }
}