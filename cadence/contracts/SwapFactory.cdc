import FungibleToken from "./tokens/FungibleToken.cdc"
import SwapError from "./SwapError.cdc"
import SwapConfig from "./SwapConfig.cdc"


pub contract SwapFactory {
    // Account which has deployed pair template contract
    pub let pairContractTemplateAddress: Address

    access(self) let pairArr: [Address]
    // pairMap[token0Identifier][token1Identifier] == pairMap[token1Identifier][token0Identifier]
    access(self) let pairMap: { String: {String: Address} }


    pub event PairCreated(token0Key: String, token1Key: String, pairAddress: Address, numPairs: Int)


  ////// TODO:
//  pub fun feeTo(): Address?
//  pub fun feeToSetter(): Address?
//  pub fun setFeeTo(feeTo: Address)
//  pub fun setFeeToSetter(feeToSetter: Address)

    pub fun createPair(token0Vault: @FungibleToken.Vault, token1Vault: @FungibleToken.Vault): Address {
        // The tokenKey is the type identifier of the token, eg A.f8d6e0586b0a20c7.FlowToken
        let token0Key = SwapConfig.SliceTokenTypeIdentifierFromVaultType(vaultTypeIdentifier: token0Vault.getType().identifier)
        let token1Key = SwapConfig.SliceTokenTypeIdentifierFromVaultType(vaultTypeIdentifier: token1Vault.getType().identifier)
        assert(
            token0Key != token1Key, message:
                SwapError.ErrorEncode(
                    msg: "Identical FungibleTokens",
                    err: SwapError.ErrorCode.CANNOT_CREATE_PAIR_WITH_SAME_TOKENS
                )
        )
        assert(
            self.getPairAddress(token0Key: token0Key, token1Key: token1Key) == nil, message:
                SwapError.ErrorEncode(
                    msg: "Pair already exists",
                    err: SwapError.ErrorCode.ADD_PAIR_DUPLICATED
                )
        )

        let pairAccount = AuthAccount(payer: self.account)
        let pairAddress = pairAccount.address

        let pairTemplateContract = getAccount(self.pairContractTemplateAddress).contracts.get(name: "SwapPair")!
        // Deploy pair contract with initialized parameters
        pairAccount.contracts.add(
            name: "SwapPair",
            code: pairTemplateContract.code,
            token0Vault: <-token0Vault,
            token1Vault: <-token1Vault
        )
        destroy token0Vault
        destroy token1Vault
        
        // insert pair map
        if (self.pairMap.containsKey(token0Key) == false) {
            self.pairMap.insert(key: token0Key, {})
        }
        if (self.pairMap.containsKey(token1Key) == false) {
            self.pairMap.insert(key: token1Key, {})
        }
        self.pairMap[token0Key]!.insert(key: token1Key, pairAddress)
        self.pairMap[token1Key]!.insert(key: token0Key, pairAddress)

        self.pairArr.append(pairAddress)

        // event
        emit PairCreated(token0Key: token0Key, token1Key: token1Key, pairAddress: pairAddress, numPairs: self.pairArr.length)

        return pairAddress
    }

    pub fun getPairArrLength(): Int {
        return self.pairArr.length
    }
    // TODO slice array to get
    pub fun getAllPairArr(): [Address] {
        return self.pairArr
    }

    pub fun getPairAddress(token0Key: String, token1Key: String): Address? {
        let pairExist0To1 = self.pairMap.containsKey(token0Key) && self.pairMap[token0Key]!.containsKey(token1Key)
        let pairExist1To0 = self.pairMap.containsKey(token1Key) && self.pairMap[token1Key]!.containsKey(token0Key)
        if (pairExist0To1 && pairExist1To0) {
            return self.pairMap[token0Key]![token1Key]!
        } else {
            return nil
        }
    }

    init(pairTemplate: Address) {
        self.pairContractTemplateAddress = pairTemplate
        self.pairArr = []
        self.pairMap = {}
    }
}