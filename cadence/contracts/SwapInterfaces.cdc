import FungibleToken from "./tokens/FungibleToken.cdc"

pub contract interface SwapInterfaces {
    // IdentityCertificate resource which is used to identify account address or perform caller authentication
    pub resource interface IdentityCertificate {}

    pub resource interface PairPublic {
        pub fun addLiquidity(tokenAVault: @FungibleToken.Vault, tokenBVault: @FungibleToken.Vault): @FungibleToken.Vault
        pub fun removeLiquidity(lpTokenVault: @FungibleToken.Vault) : @[FungibleToken.Vault]
        pub fun swap(inTokenAVault: @FungibleToken.Vault): @FungibleToken.Vault
        pub fun getAmountIn(amountOut: UFix64): UFix64
        pub fun getAmountOut(amountIn: UFix64): UFix64
    }
}