import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapRouter from "../../contracts/SwapRouter.cdc"

transaction(
    tokenKeyPath: [String],
    amountInMax: UFix64,
    exactAmountOut: UFix64,
    deadline: UFix64
) {
    prepare(userAccount: AuthAccount) {
        let tokenInVaultPath = /storage/flowTokenVault
        let tokenOutVaultPath = /storage/fusdVault
        
        var tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
        
        let vaultInRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenInVaultPath)
        let vaultInMax <- vaultInRef!.withdraw(amount: amountInMax)

        let swapResVault <- SwapRouter.swapTokensForExactTokens(
            vaultInMax: <-vaultInMax,
            exactAmountOut: exactAmountOut,
            tokenKeyPath: tokenKeyPath,
            deadline: deadline
        )
        let vaultOut <- swapResVault.removeFirst()
        let vaultInLeft <- swapResVault.removeLast()
        destroy swapResVault

        tokenOutReceiverRef!.deposit(from: <-vaultOut)
        vaultInRef!.deposit(from: <-vaultInLeft)
    }
}