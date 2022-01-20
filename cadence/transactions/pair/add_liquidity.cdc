import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapFactory from "../../contracts/SwapFactory.cdc"
import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"

// deploy code copied by a deployed contract
transaction(
    token0Key: String,
    token1Key: String,
    token0In: UFix64,
    token1In: UFix64,
    token0VaultPath: StoragePath,
    token1VaultPath: StoragePath,
) {
    prepare(userAccount: AuthAccount) {
        // TODO nil check
        let pairAddr = SwapFactory.getPairAddress(token0Key: token0Key, token1Key: token1Key)!

        // TODO nil check
        let token0Vault <- userAccount.borrow<&FungibleToken.Vault>(from: token0VaultPath)!.withdraw(amount: token0In)
        let token1Vault <- userAccount.borrow<&FungibleToken.Vault>(from: token1VaultPath)!.withdraw(amount: token0In)

        // TODO nil check
        let lpToken <- getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!.addLiquidity(
            tokenAVault: <- token0Vault,
            tokenBVault: <- token1Vault
        )

        log("=====> add liquidity: ".concat(token0Key).concat(token1Key).concat("mint lp:").concat(lpToken.balance.toString()))
        destroy lpToken
    }
}