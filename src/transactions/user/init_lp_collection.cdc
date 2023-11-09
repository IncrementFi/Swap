import SwapFactory from "../../contracts/SwapFactory.cdc"
import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
import SwapConfig from "../../contracts/SwapConfig.cdc"

transaction() {
    prepare(userAccount: AuthAccount) {
        let lpTokenCollectionStoragePath = SwapConfig.LpTokenCollectionStoragePath
        let lpTokenCollectionPublicPath = SwapConfig.LpTokenCollectionPublicPath
        var lpTokenCollectionRef = userAccount.borrow<&SwapFactory.LpTokenCollection>(from: lpTokenCollectionStoragePath)
        if lpTokenCollectionRef == nil {
            destroy <- userAccount.load<@AnyResource>(from: lpTokenCollectionStoragePath)
            userAccount.save(<-SwapFactory.createEmptyLpTokenCollection(), to: lpTokenCollectionStoragePath)
            userAccount.link<&{SwapInterfaces.LpTokenCollectionPublic}>(lpTokenCollectionPublicPath, target: lpTokenCollectionStoragePath)
            lpTokenCollectionRef = userAccount.borrow<&SwapFactory.LpTokenCollection>(from: lpTokenCollectionStoragePath)
        }
    }
}