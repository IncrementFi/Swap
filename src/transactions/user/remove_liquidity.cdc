import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapFactory from "../../contracts/SwapFactory.cdc"
import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"
import SwapError from "../../contracts/SwapError.cdc"

transaction(
    token0Key: String,
    token1Key: String,
    lpTokenAmount: UFix64,
    token0OutMin: UFix64,
    token1OutMin: UFix64,
    deadline: UFix64,

    token0VaultPath: StoragePath,
    token1VaultPath: StoragePath,
) {
    prepare(userAccount: AuthAccount) {
        assert( deadline >= getCurrentBlock().timestamp, message:
            SwapError.ErrorEncode(
                msg: "EXPIRED ".concat(deadline.toString()).concat(" < ").concat(getCurrentBlock().timestamp.toString()),
                err: SwapError.ErrorCode.EXPIRED
            )
        )
        let pairAddr = SwapFactory.getPairAddress(token0Key: token0Key, token1Key: token1Key)!

        var lpTokenCollectionStoragePath = SwapConfig.LpTokenCollectionStoragePath
        var lpTokenCollectionRef = userAccount.borrow<&SwapFactory.LpTokenCollection>(from: lpTokenCollectionStoragePath)

        var lpTokenRemove <- lpTokenCollectionRef!.withdraw(pairAddr: pairAddr, amount: lpTokenAmount)
        let tokens <- getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!.removeLiquidity(lpTokenVault: <-lpTokenRemove)
        let token0Vault <- tokens[0].withdraw(amount: tokens[0].balance)
        let token1Vault <- tokens[1].withdraw(amount: tokens[1].balance)
        destroy tokens

        assert(token0Vault.balance >= token0OutMin && token1Vault.balance >= token1OutMin, message:
            SwapError.ErrorEncode(
                msg: "INSUFFICIENT_REMOVE_LIQUIDITY_OUT_AMOUNT", 
                err: SwapError.ErrorCode.SLIPPAGE_OFFSET_TOO_LARGE
            )
        )
        
        log("=====> remove liquidity: ".concat(token0Key).concat(token1Key))
        log("return tokens amounts:".concat(token0Vault.balance.toString()).concat(", ").concat(token1Vault.balance.toString()))
        /// Here does not detect whether the local receiver vault exsit.
        userAccount.borrow<&FungibleToken.Vault>(from: token0VaultPath)!.deposit(from: <-token0Vault)
        userAccount.borrow<&FungibleToken.Vault>(from: token1VaultPath)!.deposit(from: <-token1Vault)
    }
}