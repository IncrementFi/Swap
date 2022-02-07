import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapFactory from "../../contracts/SwapFactory.cdc"
import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"
import SwapPair from "../../contracts/SwapPair.cdc"

transaction(
    lpTokenAmount: UFix64,
    token0Key: String,
    token1Key: String,
    token0VaultPath: StoragePath,
    token1VaultPath: StoragePath,
) {
    prepare(userAccount: AuthAccount) {
        // TODO nil check
        let pairAddr = SwapFactory.getPairAddress(token0Key: token0Key, token1Key: token1Key)!
        
        var vaultStoragePath: StoragePath = /storage/concattokentest
        var lpTokenVaultRef = userAccount.borrow<&SwapPair.Vault>(from: vaultStoragePath)
        var lpTokenVault <- lpTokenVaultRef!.withdraw(amount: lpTokenAmount)        
        // TODO nil check
        let tokens <- getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
            .removeLiquidity(lpTokenVault: <-lpTokenVault)
        let token0Vault <- tokens[0].withdraw(amount: tokens[0].balance)
        let token1Vault <- tokens[1].withdraw(amount: tokens[1].balance)
        destroy tokens
        log("=====> remove liquidity: ".concat(token0Key).concat(token1Key))
        log("return tokens amounts:".concat(token0Vault.balance.toString()).concat(", ").concat(token1Vault.balance.toString()))
        // TODO nil check
        userAccount.borrow<&FungibleToken.Vault>(from: token0VaultPath)!.deposit(from: <-token0Vault)
        userAccount.borrow<&FungibleToken.Vault>(from: token1VaultPath)!.deposit(from: <-token1Vault)

    }
}