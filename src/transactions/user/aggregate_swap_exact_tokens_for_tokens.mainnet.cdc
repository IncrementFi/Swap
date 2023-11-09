import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import FlowToken from "../../contracts/tokens/FlowToken.cdc"
import TeleportedTetherToken from "../../contracts/tokens/TeleportedTetherToken.cdc"
import FiatToken from "../../contracts/tokens/FiatToken.cdc"
import FUSD from "../../contracts/tokens/FUSD.cdc"
import BloctoToken from "../../contracts/tokens/BloctoToken.cdc"
import StarlyToken from "../../contracts/tokens/StarlyToken.cdc"
import REVV from "../../contracts/tokens/REVV.cdc"

import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"
import SwapError from "../../contracts/SwapError.cdc"

import PierRouter from "../../contracts/env/PierRouter.cdc"

import FlowSwapPair from "../../contracts/env/FlowSwapPair.cdc"
import UsdcUsdtSwapPair from "../../contracts/env/UsdcUsdtSwapPair.cdc"
import FusdUsdtSwapPair from "../../contracts/env/FusdUsdtSwapPair.cdc"
import BltUsdtSwapPair from "../../contracts/env/BltUsdtSwapPair.cdc"
import StarlyUsdtSwapPair from "../../contracts/env/StarlyUsdtSwapPair.cdc"
import RevvFlowSwapPair from "../../contracts/env/RevvFlowSwapPair.cdc"

transaction(
    tokenKeyFlatSplitPath: [String],
    tokenAddressFlatSplitPath: [Address],
    tokenNameFlatSplitPath: [String],
    poolAddressesToPairs: [[[Address]]],
    poolKeysToPairs: [[[String]]],
    poolInRatiosToPairs: [[[UFix64]]],
    amountInSplit: [UFix64],
    amountOutMin: UFix64,
    deadline: UFix64,
    tokenInVaultPath: StoragePath,
    tokenOutVaultPath: StoragePath,
    tokenOutReceiverPath: PublicPath,
    tokenOutBalancePath: PublicPath,
) {
    prepare(userAccount: AuthAccount) {
        assert(deadline >= getCurrentBlock().timestamp, message:
            SwapError.ErrorEncode(
                msg: "EXPIRED",
                err: SwapError.ErrorCode.EXPIRED
            )
        )

        let len = tokenKeyFlatSplitPath.length
        let swapInKey = tokenKeyFlatSplitPath[0]
        let swapOutKey = tokenKeyFlatSplitPath[len-1]
        let swapOutTokenName = tokenNameFlatSplitPath[len-1]
        let swapOutTokenAddress = tokenAddressFlatSplitPath[len-1]

        var tokenOutAmountTotal = 0.0

        var tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
        if tokenOutReceiverRef == nil {
            userAccount.save(<-getAccount(swapOutTokenAddress).contracts.borrow<&FungibleToken>(name: swapOutTokenName)!.createEmptyVault(), to: tokenOutVaultPath)
            userAccount.link<&{FungibleToken.Receiver}>(tokenOutReceiverPath, target: tokenOutVaultPath)
            userAccount.link<&{FungibleToken.Balance}>(tokenOutBalancePath, target: tokenOutVaultPath)

            tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: tokenOutVaultPath)
        }

        var pathIndex = 0
        var i = 0
        var path: [String] = []
        var pathTokenAddress: [Address] = []
        var pathTokenName: [String] = []
        while(i < len) {
            var curTokenKey = tokenKeyFlatSplitPath[i]
            path.append(curTokenKey)
            pathTokenAddress.append(tokenAddressFlatSplitPath[i])
            pathTokenName.append(tokenNameFlatSplitPath[i])
            if (curTokenKey == swapOutKey) {
                let pathInAmount = amountInSplit[pathIndex]
                
                let pathLength = path.length
                var pathStep = 0

                var pairInVault <- userAccount.borrow<&FungibleToken.Vault>(from: tokenInVaultPath)!.withdraw(amount: pathInAmount)
                var totalPairInAmount = pathInAmount
                // swap in path
                while(pathStep < pathLength-1) {
                    let tokenInKey = path[pathStep]
                    let tokenOutKey = path[pathStep+1]
                    let tokenInAddress: Address = pathTokenAddress[pathStep]
                    let tokenOutAddress: Address = pathTokenAddress[pathStep+1]
                    let tokenInName: String = pathTokenName[pathStep]
                    let tokenOutName: String = pathTokenName[pathStep+1]
                    var poolIndex = 0;
                    let poolLength = poolAddressesToPairs[pathIndex][pathStep].length

                    var poolOutVault <- getAccount(tokenOutAddress).contracts.borrow<&FungibleToken>(name: tokenOutName)!.createEmptyVault()

                    // swap in pool
                    while(poolIndex < poolLength) {
                        let poolAddress = poolAddressesToPairs[pathIndex][pathStep][poolIndex]
                        let poolKey = poolKeysToPairs[pathIndex][pathStep][poolIndex]
                        let poolInRatio = poolInRatiosToPairs[pathIndex][pathStep][poolIndex]
                        
                        var poolInAmount = totalPairInAmount * poolInRatio
                        if (poolIndex == poolLength-1) {
                            poolInAmount = pairInVault.balance
                        }
                        
                        switch poolKey {
                            case "increment-v1":
                                let pool = getAccount(poolAddress).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
                                poolOutVault.deposit(from: <-pool.swap(vaultIn: <- pairInVault.withdraw(amount: poolInAmount), exactAmountOut: nil))
                            
                            case "increment-stable":
                                let pool = getAccount(poolAddress).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
                                poolOutVault.deposit(from: <-pool.swap(vaultIn: <- pairInVault.withdraw(amount: poolInAmount), exactAmountOut: nil))
                            
                            case "metapier":
                                PierRouter.swapExactTokensAForTokensB(
                                    fromVault: &pairInVault as &FungibleToken.Vault,
                                    toVault: &poolOutVault as &{FungibleToken.Receiver},
                                    amountIn: poolInAmount,
                                    amountOutMin: 0.0,
                                    path: [tokenInKey.concat(".Vault"), tokenOutKey.concat(".Vault")],
                                    deadline: deadline,
                                )
                            
                            case "blocto":
                                switch poolAddress {
                                    case 0xc6c77b9f5c7a378f:
                                        if tokenInKey == "A.1654653399040a61.FlowToken" {
                                            poolOutVault.deposit(from: <-FlowSwapPair.swapToken1ForToken2(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @FlowToken.Vault)))
                                        } else {
                                            poolOutVault.deposit(from: <-FlowSwapPair.swapToken2ForToken1(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @TeleportedTetherToken.Vault)))
                                        }
                                    case 0x9c6f94adf47904b5:
                                        if tokenInKey == "A.b19436aae4d94622.FiatToken" {
                                            poolOutVault.deposit(from: <-UsdcUsdtSwapPair.swapToken1ForToken2(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @FiatToken.Vault)))
                                        } else {
                                            poolOutVault.deposit(from: <-UsdcUsdtSwapPair.swapToken2ForToken1(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @TeleportedTetherToken.Vault)))
                                        }
                                    case 0x87f3f233f34b0733:
                                        if tokenInKey == "A.3c5959b568896393.FUSD" {
                                            poolOutVault.deposit(from: <-FusdUsdtSwapPair.swapToken1ForToken2(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @FUSD.Vault)))
                                        } else {
                                            poolOutVault.deposit(from: <-FusdUsdtSwapPair.swapToken2ForToken1(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @TeleportedTetherToken.Vault)))
                                        }
                                    case 0xfcb06a5ae5b21a2d:
                                        if tokenInKey == "A.0f9df91c9121c460.BloctoToken" {
                                            poolOutVault.deposit(from: <-BltUsdtSwapPair.swapToken1ForToken2(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @BloctoToken.Vault)))
                                        } else {
                                            poolOutVault.deposit(from: <-BltUsdtSwapPair.swapToken2ForToken1(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @TeleportedTetherToken.Vault)))
                                        }
                                    case 0x6efab66df92c37e4:
                                        if tokenInKey == "A.142fa6570b62fd97.StarlyToken" {
                                            poolOutVault.deposit(from: <-StarlyUsdtSwapPair.swapToken1ForToken2(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @StarlyToken.Vault)))
                                        } else {
                                            poolOutVault.deposit(from: <-StarlyUsdtSwapPair.swapToken2ForToken1(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @TeleportedTetherToken.Vault)))
                                        }
                                    case 0x5e284fb7cff23a3f:
                                        if tokenInKey == "A.d01e482eb680ec9f.REVV" {
                                            poolOutVault.deposit(from: <-RevvFlowSwapPair.swapToken1ForToken2(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @REVV.Vault)))
                                        } else {
                                            poolOutVault.deposit(from: <-RevvFlowSwapPair.swapToken2ForToken1(from: <-(pairInVault.withdraw(amount: poolInAmount) as! @FlowToken.Vault)))
                                        }

                                    default:
                                        assert(false, message: "invalid blocto pool address")
                                }
                            default:
                                assert(false, message: "invalid pool type")
                        }

                        poolIndex = poolIndex + 1
                    }
                    pairInVault <-> poolOutVault
                    destroy poolOutVault
                    totalPairInAmount = pairInVault.balance
                    pathStep = pathStep + 1
                }
                
                tokenOutAmountTotal = tokenOutAmountTotal + pairInVault.balance
                tokenOutReceiverRef!.deposit(from: <- pairInVault)

                path = []
                pathTokenAddress = []
                pathTokenName = []
        
                pathIndex = pathIndex + 1
            }
            i = i + 1
        }

        assert(tokenOutAmountTotal >= amountOutMin, message:
            SwapError.ErrorEncode(
                msg: "SLIPPAGE_OFFSET_TOO_LARGE expect min ".concat(amountOutMin.toString()).concat(" got ").concat(tokenOutAmountTotal.toString()),
                err: SwapError.ErrorCode.SLIPPAGE_OFFSET_TOO_LARGE
            )
        )
    }
}