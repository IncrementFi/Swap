import FungibleToken from "./tokens/FungibleToken.cdc"
import SwapError from "./SwapError.cdc"
import SwapConfig from "./SwapConfig.cdc"
import SwapInterfaces from "./SwapInterfaces.cdc"


pub contract SwapFactory {
    // Account which has deployed pair template contract
    pub let pairContractTemplateAddress: Address

    access(self) let pairArr: [Address]
    // pairMap[token0Identifier][token1Identifier] == pairMap[token1Identifier][token0Identifier]
    access(self) let pairMap: { String: {String: Address} }

    /// Events
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
    
    ///
    pub fun createEmptyLpTokenCollection(): @LpTokenCollection {
        return <-create LpTokenCollection()
    }

    ///
    pub resource LpTokenCollection: SwapInterfaces.LpTokenCollectionPublic {
        access(self) var lpTokenVaults: @{Address: FungibleToken.Vault}

        init() {
            self.lpTokenVaults <- {}
        }

        destroy() {
            destroy self.lpTokenVaults
        }

        pub fun deposit(pairAddr: Address, lpTokenVault: @FungibleToken.Vault) {
            let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
            assert(
                lpTokenVault.getType() == pairPublicRef.getLpTokenVaultType(), message:
                SwapError.ErrorEncode(
                    msg: "Mis match lptoken vault in deposit",
                    err: SwapError.ErrorCode.MISMATCH_LPTOKEN_VAULT
                )
            )

            if self.lpTokenVaults.containsKey(pairAddr) {
                let vaultRef = &self.lpTokenVaults[pairAddr] as! &FungibleToken.Vault
                vaultRef.deposit(from: <- lpTokenVault)
            } else {
                self.lpTokenVaults[pairAddr] <-! lpTokenVault
            }
        }

        pub fun withdraw(pairAddr: Address, amount: UFix64): @FungibleToken.Vault {
            pre {
                self.lpTokenVaults.containsKey(pairAddr):
                    SwapError.ErrorEncode(
                        msg: "There is no liquidity in pair ".concat(pairAddr.toString()),
                        err: SwapError.ErrorCode.INVALID_PARAMETERS
                    )
            }

            let vaultRef = &self.lpTokenVaults[pairAddr] as! &FungibleToken.Vault
            let withdrawVault <- vaultRef.withdraw(amount: amount)
            if vaultRef.balance == 0.0 {
                let deletedVault <- self.lpTokenVaults[pairAddr] <- nil
                destroy deletedVault
            }
            return <- withdrawVault
        }

        pub fun getCollectionLength(): Int {
            return self.lpTokenVaults.keys.length
        }

        pub fun getLpTokenBalance(pairAddr: Address): UFix64 {
            if self.lpTokenVaults.containsKey(pairAddr) {
                let vaultRef = &self.lpTokenVaults[pairAddr] as! &FungibleToken.Vault
                return vaultRef.balance
            }
            return 0.0
        }

        pub fun getAllLiquidityPairAddrs(): [Address] {
            return self.lpTokenVaults.keys
        }

        pub fun getLiquidityPairAddrsSliced(from: UInt64, to: UInt64): [Address] {
            pre {
                from <= to && from < UInt64(self.getCollectionLength()):
                    SwapError.ErrorEncode(
                        msg: "Index out of range",
                        err: SwapError.ErrorCode.INVALID_PARAMETERS
                    )
            }
            let pairLen = UInt64(self.getCollectionLength())
            var curIndex = from
            var endIndex = to
            if endIndex == 0 || endIndex == UInt64.max {
                endIndex = pairLen - 1
            }

            // Array.slice function does not sopported now
            let list: [Address] = []
            let lpTokenVaultsKeys = self.lpTokenVaults.keys
            while curIndex <= endIndex && curIndex < pairLen {
                list.append(lpTokenVaultsKeys[curIndex])
                curIndex = curIndex + 1
            }
            return list
        }
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

    pub fun getPairInfo(token0Key: String, token1Key: String): AnyStruct? {
        var pairAddr = self.getPairAddress(token0Key: token0Key, token1Key: token1Key)
        if pairAddr == nil {
            return nil
        }
        return getAccount(pairAddr!).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!.getPairInfo()
    }

    pub fun getPairArrLength(): Int {
        return self.pairArr.length
    }

    /// @Param to - 0 or UInt64.max
    pub fun getPairArrAddr(from: UInt64, to: UInt64): [Address] {
        pre {
            from <= to && from < UInt64(self.pairArr.length):
                SwapError.ErrorEncode(
                    msg: "Index out of range",
                    err: SwapError.ErrorCode.INVALID_PARAMETERS
                )
        }
        let pairLen = UInt64(self.pairArr.length)
        var curIndex = from
        var endIndex = to
        if endIndex == 0 || endIndex == UInt64.max {
            endIndex = pairLen-1
        }

        // Array.slice function does not sopported now
        let list: [Address] = []
        while curIndex <= endIndex && curIndex < pairLen {
            list.append(self.pairArr[curIndex])
            curIndex = curIndex + 1
        }
        return list
    }

    pub fun getPairArrInfo(from: UInt64, to: UInt64): [AnyStruct] {
        let pairAddrs: [Address] = self.getPairArrAddr(from: from, to: to)
        let len = pairAddrs.length
        var i = 0
        var res: [AnyStruct] = []
        while(i < len) {
            res.append(
                getAccount(pairAddrs[i]).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!.getPairInfo()
            )
            i = i + 1
        }

        return res
    }



    init(pairTemplate: Address) {
        self.pairContractTemplateAddress = pairTemplate
        self.pairArr = []
        self.pairMap = {}
    }
}