import FUSD from 0xe223d8a629e49c68

import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapRouter from "../../contracts/SwapRouter.cdc"

transaction(
    tokenKeyPath: [String],
    exactAmountIn: UFix64,
    amountOutMin: UFix64,
    deadline: UFix64
) {
    prepare(userAccount: AuthAccount) {
        let len = tokenKeyPath.length
        let tokenInKey = tokenKeyPath[0]
        let tokenOutKey = tokenKeyPath[len-1]

        let tokenInVaultPath = /storage/flowTokenVault

        let tokenOutVaultPath = /storage/fusdVault
        let tokenOutReceiverPath = /public/fusdReceiver
        let tokenOutBalancePath = /public/fusdBalance

        var tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
        if tokenOutReceiverRef == nil {
            userAccount.save(<- FUSD.createEmptyVault(), to: /storage/fusdVault)
            userAccount.link<&FUSD.Vault{FungibleToken.Receiver}>(tokenOutReceiverPath, target: tokenOutVaultPath)
            userAccount.link<&FUSD.Vault{FungibleToken.Balance}>(tokenOutBalancePath, target: tokenOutVaultPath)

            tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
        }

        let exactVaultIn <- userAccount.borrow<&FungibleToken.Vault>(from: tokenInVaultPath)!.withdraw(amount: exactAmountIn)
        /// 
        let vaultOut <- SwapRouter.swapExactTokensForTokens(
            exactVaultIn: <-exactVaultIn,
            amountOutMin: amountOutMin,
            tokenKeyPath: tokenKeyPath,
            deadline: deadline
        )

        tokenOutReceiverRef!.deposit(from: <-vaultOut)
    }
}