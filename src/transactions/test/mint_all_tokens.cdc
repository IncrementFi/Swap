import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"

import BUSD from "../../contracts/tokens/BUSD.cdc"
import FUSD from "../../contracts/tokens/FUSD.cdc"
import USDC from "../../contracts/tokens/USDC.cdc"
import USDT from "../../contracts/tokens/USDT.cdc"
import wFlow from "../../contracts/tokens/wFlow.cdc"
import BLT from "../../contracts/tokens/BLT.cdc"

import TestTokenA from "../../contracts/tokens/TestTokenA.cdc"
import TestTokenB from "../../contracts/tokens/TestTokenB.cdc"
import TestTokenC from "../../contracts/tokens/TestTokenC.cdc"

transaction(mintAmount: UFix64) {

    prepare(signer: AuthAccount) {
        log("Transaction Start --------------- mint all tokens")
        
        var vaultStoragePath = /storage/test_busdVault
        var vaultReceiverPath = /public/test_busdReceiver
        var vaultBalancePath = /public/test_busdBalance
        var busdVaultRef = signer.borrow<&BUSD.Vault>(from: vaultStoragePath)
        if busdVaultRef == nil {
            destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

            signer.save(<-BUSD.createEmptyVault(), to: vaultStoragePath)
            signer.link<&BUSD.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
            signer.link<&BUSD.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
        }
        busdVaultRef = signer.borrow<&BUSD.Vault>(from: vaultStoragePath)
        busdVaultRef!.deposit(from: <-BUSD.test_minter.mintTokens(amount: mintAmount))
        log("mint ".concat(busdVaultRef!.balance.toString()))
        /////////////////
        vaultStoragePath = /storage/test_fusdVault
        vaultReceiverPath = /public/test_fusdReceiver
        vaultBalancePath = /public/test_fusdBalance
        var fusdVaultRef = signer.borrow<&FUSD.Vault>(from: vaultStoragePath)
        if fusdVaultRef == nil {
            destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

            signer.save(<-FUSD.createEmptyVault(), to: vaultStoragePath)
            signer.link<&FUSD.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
            signer.link<&FUSD.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
        }
        fusdVaultRef = signer.borrow<&FUSD.Vault>(from: vaultStoragePath)
        fusdVaultRef!.deposit(from: <-FUSD.test_minter.mintTokens(amount: mintAmount))
        log("mint ".concat(fusdVaultRef!.balance.toString()))
        /////////////////
        vaultStoragePath = /storage/test_usdcVault
        vaultReceiverPath = /public/test_usdcReceiver
        vaultBalancePath = /public/test_usdcBalance
        var usdcVaultRef = signer.borrow<&USDC.Vault>(from: vaultStoragePath)
        if usdcVaultRef == nil {
            destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

            signer.save(<-USDC.createEmptyVault(), to: vaultStoragePath)
            signer.link<&USDC.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
            signer.link<&USDC.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
        }
        usdcVaultRef = signer.borrow<&USDC.Vault>(from: vaultStoragePath)
        usdcVaultRef!.deposit(from: <-USDC.test_minter.mintTokens(amount: mintAmount))
        log("mint ".concat(usdcVaultRef!.balance.toString()))
        /////////////////
        vaultStoragePath = /storage/test_usdtVault
        vaultReceiverPath = /public/test_usdtReceiver
        vaultBalancePath = /public/test_usdtBalance
        var usdtVaultRef = signer.borrow<&USDT.Vault>(from: vaultStoragePath)
        if usdtVaultRef == nil {
            destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

            signer.save(<-USDT.createEmptyVault(), to: vaultStoragePath)
            signer.link<&USDT.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
            signer.link<&USDT.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
        }
        usdtVaultRef = signer.borrow<&USDT.Vault>(from: vaultStoragePath)
        usdtVaultRef!.deposit(from: <-USDT.test_minter.mintTokens(amount: mintAmount))
        log("mint ".concat(usdtVaultRef!.balance.toString()))
        /////////////////
        vaultStoragePath = /storage/test_wflowVault
        vaultReceiverPath = /public/test_wflowReceiver
        vaultBalancePath = /public/test_wflowBalance
        var wflowVaultRef = signer.borrow<&wFlow.Vault>(from: vaultStoragePath)
        if wflowVaultRef == nil {
            destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

            signer.save(<-wFlow.createEmptyVault(), to: vaultStoragePath)
            signer.link<&wFlow.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
            signer.link<&wFlow.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
        }
        wflowVaultRef = signer.borrow<&wFlow.Vault>(from: vaultStoragePath)
        wflowVaultRef!.deposit(from: <-wFlow.test_minter.mintTokens(amount: mintAmount))
        log("mint ".concat(wflowVaultRef!.balance.toString()))
        /////////////////
        vaultStoragePath = /storage/test_bltVault
        vaultReceiverPath = /public/test_bltReceiver
        vaultBalancePath = /public/test_bltBalance
        var bLTVaultRef = signer.borrow<&BLT.Vault>(from: vaultStoragePath)
        if bLTVaultRef == nil {
            destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

            signer.save(<-BLT.createEmptyVault(), to: vaultStoragePath)
            signer.link<&BLT.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
            signer.link<&BLT.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
        }
        bLTVaultRef = signer.borrow<&BLT.Vault>(from: vaultStoragePath)
        bLTVaultRef!.deposit(from: <-BLT.test_minter.mintTokens(amount: mintAmount))
        log("mint ".concat(bLTVaultRef!.balance.toString()))
        /////////////////
        vaultStoragePath = /storage/testTokenAVault
        vaultReceiverPath = /public/testTokenAReceiver
        vaultBalancePath = /public/testTokenABalance
        var testTokenAVaultRef = signer.borrow<&TestTokenA.Vault>(from: vaultStoragePath)
        if testTokenAVaultRef == nil {
            destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

            signer.save(<-TestTokenA.createEmptyVault(), to: vaultStoragePath)
            signer.link<&TestTokenA.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
            signer.link<&TestTokenA.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
        }
        testTokenAVaultRef = signer.borrow<&TestTokenA.Vault>(from: vaultStoragePath)
        testTokenAVaultRef!.deposit(from: <-TestTokenA.test_minter.mintTokens(amount: mintAmount))
        log("mint ".concat(testTokenAVaultRef!.balance.toString()))
        /////////////////
        vaultStoragePath = /storage/testTokenBVault
        vaultReceiverPath = /public/testTokenBReceiver
        vaultBalancePath = /public/testTokenBBalance
        var testTokenBVaultRef = signer.borrow<&TestTokenB.Vault>(from: vaultStoragePath)
        if testTokenBVaultRef == nil {
            destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

            signer.save(<-TestTokenB.createEmptyVault(), to: vaultStoragePath)
            signer.link<&TestTokenB.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
            signer.link<&TestTokenB.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
        }
        testTokenBVaultRef = signer.borrow<&TestTokenB.Vault>(from: vaultStoragePath)
        testTokenBVaultRef!.deposit(from: <-TestTokenB.test_minter.mintTokens(amount: mintAmount))
        log("mint ".concat(testTokenBVaultRef!.balance.toString()))
        /////////////////
        vaultStoragePath = /storage/testTokenCVault
        vaultReceiverPath = /public/testTokenCReceiver
        vaultBalancePath = /public/testTokenCBalance
        var testTokenCVaultRef = signer.borrow<&TestTokenC.Vault>(from: vaultStoragePath)
        if testTokenCVaultRef == nil {
            destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

            signer.save(<-TestTokenC.createEmptyVault(), to: vaultStoragePath)
            signer.link<&TestTokenC.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
            signer.link<&TestTokenC.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
        }
        testTokenCVaultRef = signer.borrow<&TestTokenC.Vault>(from: vaultStoragePath)
        testTokenCVaultRef!.deposit(from: <-TestTokenC.test_minter.mintTokens(amount: mintAmount))
        log("mint ".concat(testTokenCVaultRef!.balance.toString()))
        log("End -----------------------------")
    }
}
