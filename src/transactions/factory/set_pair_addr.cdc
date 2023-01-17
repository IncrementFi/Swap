import SwapFactory from "../../contracts/SwapFactory.cdc"

transaction() {
    prepare(userAccount: AuthAccount) {
        let factoryAdminRef = userAccount.borrow<&SwapFactory.Admin>(from: /storage/swapFactoryAdmin)!
        factoryAdminRef.setPairContractTemplateAddress(newAddr: 0xc20df20fabe06457)
    }
    execute {
    }
}
