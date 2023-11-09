import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"
import SwapFactory from "../../contracts/SwapFactory.cdc"
import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"

/*
    E.g.: Flashloan request only $USDC from FUSD/USDC pool
*/
transaction(pairAddr: Address, requestedVaultType: Type, requestedAmount: UFix64) {
    prepare(signer: AuthAccount) {
        let pairRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()
            ?? panic("cannot borrow reference to PairPublic")

        // TODO: add additional args? and generalize this transaction
        let args: {String: AnyStruct} = {
            "profitReceiver": signer.address
        }
        let executorCap = signer.getCapability<&{SwapInterfaces.FlashLoanExecutor}>(/private/swap_flashloan_executor_path)
        pairRef.flashloan(executorCap: executorCap, requestedTokenVaultType: requestedVaultType, requestedAmount: requestedAmount, params: args)
    }
}