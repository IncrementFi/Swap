import Token1Name from Token1Addr
import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"
import SwapFactory from "../../contracts/SwapFactory.cdc"
import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"
import SwapError from "../../contracts/SwapError.cdc"
import SwapRouter from "../../contracts/SwapRouter.cdc"

transaction(
    token0Key: String,
    token1Key: String,
    token0In: UFix64,
    desiredZappedAmount: UFix64,
    slippageTolerance: UFix64,

    deadline: UFix64,
    token0VaultPath: StoragePath,
    token1VaultPath: StoragePath,
    token1ReceiverPath: PublicPath,
    token1BalancePath: PublicPath
) {
    prepare(userAccount: AuthAccount) {
        assert(deadline >= getCurrentBlock().timestamp, message:
            SwapError.ErrorEncode(
                msg: "AddLiquidityZapped: expired ".concat(deadline.toString()).concat(" < ").concat(getCurrentBlock().timestamp.toString()),
                err: SwapError.ErrorCode.EXPIRED
            )
        )
        let pairAddr = SwapFactory.getPairAddress(token0Key: token0Key, token1Key: token1Key)
            ?? panic("AddLiquidity: nonexistent pair ".concat(token0Key).concat(" <-> ").concat(token1Key).concat(", create pair first"))
        let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
        
        let pairInfo = pairPublicRef.getPairInfo()
        var token0Reserve = 0.0
        var token1Reserve = 0.0
        if token0Key == (pairInfo[0] as! String) {
            token0Reserve = (pairInfo[2] as! UFix64)
            token1Reserve = (pairInfo[3] as! UFix64)
        } else {
            token0Reserve = (pairInfo[3] as! UFix64)
            token1Reserve = (pairInfo[2] as! UFix64)
        }
        assert(token0Reserve != 0.0, message: "Cannot add liquidity zapped in a new pool.")

        // Cal optimized zapped amount through dex
        let r0Scaled = SwapConfig.UFix64ToScaledUInt256(token0Reserve)
        let kplus1SquareScaled = SwapConfig.UFix64ToScaledUInt256(1.997*1.997)
        let kScaled = SwapConfig.UFix64ToScaledUInt256(0.997)
        let kplus1Scaled = SwapConfig.UFix64ToScaledUInt256(1.997)
        let token0InScaled = SwapConfig.UFix64ToScaledUInt256(token0In)
        let qScaled = SwapConfig.sqrt(
            r0Scaled * r0Scaled / SwapConfig.scaleFactor * kplus1SquareScaled / SwapConfig.scaleFactor
            + 4 * kScaled * r0Scaled / SwapConfig.scaleFactor * token0InScaled / SwapConfig.scaleFactor)
        let zappedAmount = SwapConfig.ScaledUInt256ToUFix64(
            (qScaled - r0Scaled*kplus1Scaled/SwapConfig.scaleFactor)*SwapConfig.scaleFactor/(kScaled*2)
        )

        var slippage = 0.0
        if (desiredZappedAmount > zappedAmount) {
            slippage = (desiredZappedAmount - zappedAmount) / desiredZappedAmount * 100.0
        } else {
            slippage = (zappedAmount - desiredZappedAmount) / desiredZappedAmount * 100.0
        }
        assert(slippage <= slippageTolerance, message:
            SwapError.ErrorEncode(
                msg: "ZAPPED_ADD_LIQUIDITY_SLIPPAGE_OFFSET_TOO_LARGE",
                err: SwapError.ErrorCode.SLIPPAGE_OFFSET_TOO_LARGE
            )
        )

        var tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: token1VaultPath)
        if tokenOutReceiverRef == nil {
            userAccount.save(<- Token1Name.createEmptyVault(), to: token1VaultPath)
            userAccount.link<&Token1Name.Vault{FungibleToken.Receiver}>(token1ReceiverPath, target: token1VaultPath)
            userAccount.link<&Token1Name.Vault{FungibleToken.Balance}>(token1BalancePath, target: token1VaultPath)

            tokenOutReceiverRef = userAccount.borrow<&FungibleToken.Vault>(from: token1VaultPath)
        }

        // Swap
        let vaultInRef  = userAccount.borrow<&FungibleToken.Vault>(from: token0VaultPath)!
        let swapVaultIn <- vaultInRef.withdraw(amount: zappedAmount)
        let token0Vault <- vaultInRef.withdraw(amount: token0In - zappedAmount)
        let token1Vault <- SwapRouter.swapWithPath(vaultIn: <- swapVaultIn, tokenKeyPath: [token0Key, token1Key], exactAmounts: nil)
        
        // Add liquidity
        let lpTokenVault <- pairPublicRef.addLiquidity(
            tokenAVault: <- token0Vault,
            tokenBVault: <- token1Vault
        )
        
        let lpTokenCollectionStoragePath = SwapConfig.LpTokenCollectionStoragePath
        let lpTokenCollectionPublicPath = SwapConfig.LpTokenCollectionPublicPath
        var lpTokenCollectionRef = userAccount.borrow<&SwapFactory.LpTokenCollection>(from: lpTokenCollectionStoragePath)
        if lpTokenCollectionRef == nil {
            destroy <- userAccount.load<@AnyResource>(from: lpTokenCollectionStoragePath)
            userAccount.save(<-SwapFactory.createEmptyLpTokenCollection(), to: lpTokenCollectionStoragePath)
            userAccount.link<&{SwapInterfaces.LpTokenCollectionPublic}>(lpTokenCollectionPublicPath, target: lpTokenCollectionStoragePath)
            lpTokenCollectionRef = userAccount.borrow<&SwapFactory.LpTokenCollection>(from: lpTokenCollectionStoragePath)
        }
        lpTokenCollectionRef!.deposit(pairAddr: pairAddr, lpTokenVault: <- lpTokenVault)
    }
}
 