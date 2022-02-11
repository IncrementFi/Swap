import BLT from "../../contracts/tokens/BLT.cdc"
import FUSD from "../../contracts/tokens/FUSD.cdc"

// deploy code copied by a deployed contract
transaction(pairTemplateCode: String) {
    prepare(deployAccount: AuthAccount) {
        let token0Vault <- BLT.createEmptyVault()
        let token1Vault <- FUSD.createEmptyVault()
        deployAccount.contracts.add(name: "SwapPair", code: pairTemplateCode.utf8, token0Vault:token0Vault, token1Vault:token1Vault)
        destroy token0Vault
        destroy token1Vault

        log("=====> Pair template deploy succ")
    }
}