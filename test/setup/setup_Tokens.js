import fs from "fs";
import path from "path";

import { deployContract, deployContractByName, getAccountAddress, executeScript, mintFlow, sendTransaction, getTemplate, getScriptCode } from "flow-js-testing"
import {
    getSwapConfigDeployerAddress,
    getSwapFactoryDeployerAddress,
    getSwapPairTemplateDeployerAddress,
    getTestTokenDeployerAddress,
    toUFix64
} from "./setup_Common"

export const getTestTokenAddress = async () => { return await getTestTokenDeployerAddress() }


export const deployTokenByName = async (tokenName) => {
    const cadenceRootPath = "../../src";
    const basePath = path.resolve(__dirname, cadenceRootPath);

    const testTokenAddr = await getTestTokenAddress()

    var contractCode = fs.readFileSync(basePath+"/contracts/tokens/FUSD.cdc", "utf-8");
    contractCode = contractCode.replaceAll("FUSD", tokenName);
    contractCode = contractCode.replaceAll("fusd", tokenName);
    
    return await deployContract({ to: testTokenAddr, code: contractCode });
}

export const mintTokenByName = async (tokenName, userAddr, mintAmount) => {
    const testTokenAddr = await getTestTokenAddress()
    let code = `
        import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
        import FUSD from 0xTokenAddr
        transaction(mintAmount: UFix64) {
            prepare(signer: AuthAccount) {
                let vaultStoragePath = /storage/fusdVault
                let vaultReceiverPath = /public/fusdReceiver
                let vaultBalancePath = /public/fusdBalance
                var fusdVaultRef = signer.borrow<&FUSD.Vault>(from: vaultStoragePath)
                if fusdVaultRef == nil {
                    destroy <- signer.load<@AnyResource>(from: vaultStoragePath)

                    signer.save(<-FUSD.createEmptyVault(), to: vaultStoragePath)
                    signer.link<&FUSD.Vault{FungibleToken.Receiver}>(vaultReceiverPath, target: vaultStoragePath)
                    signer.link<&FUSD.Vault{FungibleToken.Balance}>(vaultBalancePath, target: vaultStoragePath)
                }
                fusdVaultRef = signer.borrow<&FUSD.Vault>(from: vaultStoragePath)
                fusdVaultRef!.deposit(from: <-FUSD.test_minter.mintTokens(amount: mintAmount))

            }
        }
    `
    code = code.replaceAll("0xTokenAddr", testTokenAddr)
    code = code.replaceAll("FUSD", tokenName)
    code = code.replaceAll("fusd", tokenName)
    const signers = [userAddr]
    const args = [mintAmount]
    return sendTransaction({ code, args, signers })
}

export const getBalanceByName = async (tokenName, userAddr) => {
    let code = `
        import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"

        pub fun main(userAddr: Address): UFix64 {
            let vaultBalance = getAccount(userAddr).getCapability<&{FungibleToken.Balance}>(vaultPath)
            if vaultBalance.check() == false || vaultBalance.borrow() == nil {
                return 0.0
            }
            return vaultBalance.borrow()!.balance
        }
    `
    code = code.replaceAll("vaultPath", "/public/"+tokenName+"Balance")
    
    const args = [userAddr]
    return executeScript({ code, args });
}

export const getTokenKeyByName = async (tokenName) => {
    let testTokenAddr = await getTestTokenDeployerAddress()
    let flowTokenAddr = "0x0ae53cb6e3f42a79"
    
    let tokenAddr = testTokenAddr
    if (tokenName == "FlowToken") tokenAddr = flowTokenAddr

    tokenAddr = tokenAddr.slice(2)
    let tokenKay = "A." + tokenAddr + "." + tokenName
    return tokenKay
}

export const getTokenPathPrefixByName = async (tokenName) => {
    if (tokenName == "FlowToken") return "flowTokenVault"
    return tokenName
}