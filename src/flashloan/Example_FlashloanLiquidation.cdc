import FungibleToken from "../contracts/tokens/FungibleToken.cdc"
import SwapConfig from "../contracts/SwapConfig.cdc"
import SwapFactory from "../contracts/SwapFactory.cdc"
import SwapInterfaces from "../contracts/SwapInterfaces.cdc"

pub contract Example_FlashloanLiquidation {
    // Specific address to receive flashloan-liquidation profits, used as auth purposes
    pub let profitReceiver: Address

    pub resource FlashloanExecutor: SwapInterfaces.FlashLoanExecutor {
        pub fun executeAndRepay(loanedToken: @FungibleToken.Vault, params: {String: AnyStruct}): @FungibleToken.Vault {
            pre {
                params.containsKey("profitReceiver") && ((params["profitReceiver"]! as! Address) == Example_FlashloanLiquidation.profitReceiver): "not-authorized caller"
            }

            /* 
                Do magic - custom logic goes here. E.g.:
                 - 0. Flashloan request $USDC from FUSD/USDC pool (in `do_flashloan.transaction.cdc`)
                 - 1. Liquidate underwater borrower by repaying borrowed $USDC and grab borrower's collateralized $Flow
                 - 2. Swap $Flow -> $USDC through IncrementSwap (cannot use flashloan-ed pool then) or BloctoSwap
                 - 3. Repay {flashloan-ed $USDC + fees} back to FUSD/USDC pool and keep remaining $USDC as profit
            */

            // TODO: implement example
            let amountIn = loanedToken.balance

            // TODO: implement example
            // amountOut = amountIn x (1 + fee%)
            let amountOut = amountIn * (1.0 + UFix64(SwapFactory.getFlashloanRateBps()) / 10000.0) + SwapConfig.ufix64NonZeroMin

            // TODO: implement example
            return <-loanedToken
        }
    }

    init(profitReceiver: Address) {
        self.profitReceiver = profitReceiver

        // Set up FlashLoanExecutor resource
        let pathStr = "swap_flashloan_executor_path"
        let executorPrivatePath = PrivatePath(identifier: pathStr)!
        let executorStoragePath = StoragePath(identifier: pathStr)!
        destroy <-self.account.load<@AnyResource>(from: executorStoragePath)
        self.account.save(<- create FlashloanExecutor(), to: executorStoragePath)
        self.account.link<&{SwapInterfaces.FlashLoanExecutor}>(executorPrivatePath, target: executorStoragePath)
    }
}