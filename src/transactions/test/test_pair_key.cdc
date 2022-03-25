import SwapPair from 0xe2f72218abeec2b9

transaction() {
    prepare(pairAccount: AuthAccount) {
        let pairPublicRef = pairAccount.borrow<&SwapPair.PairPublic>(from: /storage/pair_public)!
        destroy <-pairAccount.load<@AnyResource>(from: /storage/pair_public)
    }
    execute {
    }
}