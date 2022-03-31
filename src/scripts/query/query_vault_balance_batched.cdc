import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"

pub fun main(userAddr: Address, vaultPaths: [PublicPath]): [UFix64] {
    var balances: [UFix64] = []
    for vaultPath in vaultPaths {
        let vaultBalance = getAccount(userAddr).getCapability<&{FungibleToken.Balance}>(vaultPath)
        if vaultBalance.check() == false || vaultBalance.borrow() == nil {
            balances.append(0.0)
        } else {
            balances.append(vaultBalance.borrow()!.balance)
        }
    }
    return balances
}