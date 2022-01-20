import FungibleToken from "./tokens/FungibleToken.cdc"
import SwapInterfaces from "./SwapInterfaces.cdc"
import SwapConfig from "./SwapConfig.cdc"


///// TODO: reentrant-attack check
pub contract SwapPair: FungibleToken {
    // Total supply of pair lpTokens in existence
    pub var totalSupply: UFix64
    
    pub let token0VaultType: Type
    pub let token1VaultType: Type
    access(self) var token0Vault: @FungibleToken.Vault
    access(self) var token1Vault: @FungibleToken.Vault

    // Event that is emitted when the contract is created
    pub event TokensInitialized(initialSupply: UFix64)
    // Event that is emitted when tokens are withdrawn from a Vault
    pub event TokensWithdrawn(amount: UFix64, from: Address?)
    // Event that is emitted when tokens are deposited to a Vault
    pub event TokensDeposited(amount: UFix64, to: Address?)
    // Event that is emitted when new tokens are minted
    pub event TokensMinted(amount: UFix64)
    // Event that is emitted when tokens are destroyed
    pub event TokensBurned(amount: UFix64)
    // Event that is emitted when a swap trade happenes to this trading pair
    // direction: 0 - in self.token0 swapped to out self.token1
    //            1 - in self.token1 swapped to out self.token0
    pub event Swap(inTokenAmount: UFix64, outTokenAmount: UFix64, direction: UInt8)

    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {
        // holds the balance of a users tokens
        pub var balance: UFix64

        // initialize the balance at resource creation time
        init(balance: UFix64) {
            self.balance = balance
        }

        // withdraw
        //
        // Function that takes an integer amount as an argument
        // and withdraws that amount from the Vault.
        // It creates a new temporary Vault that is used to hold
        // the money that is being transferred. It returns the newly
        // created Vault to the context that called so it can be deposited
        // elsewhere.
        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <-create Vault(balance: amount)
        }

        // deposit
        //
        // Function that takes a Vault object as an argument and adds
        // its balance to the balance of the owners Vault.
        // It is allowed to destroy the sent Vault because the Vault
        // was a temporary holder of the tokens. The Vault's balance has
        // been consumed and therefore can be destroyed.
        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @SwapPair.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        destroy() {
            SwapPair.totalSupply = SwapPair.totalSupply - self.balance
        }
    }

    // createEmptyVault
    //
    // Function that creates a new Vault with a balance of zero
    // and returns it to the calling context. A user must call this function
    // and store the returned Vault in their storage in order to allow their
    // account to be able to receive deposits of this token type.
    pub fun createEmptyVault(): @FungibleToken.Vault {
        return <-create Vault(balance: 0.0)
    }
    
    access(self) fun donateInitialMinimumLpToken() {
        self.totalSupply = self.totalSupply + SwapConfig.ufix64NonZeroMin
        emit TokensMinted(amount: SwapConfig.ufix64NonZeroMin)
    }
    access(self) fun mintLpToken(amount: UFix64): @SwapPair.Vault {
        self.totalSupply = self.totalSupply + amount
        emit TokensMinted(amount: amount)
        return <- create Vault(balance: amount)
    } 
    access(self) fun burnLpToken(from: @SwapPair.Vault) {
        let amount = from.balance
        destroy from
        emit TokensBurned(amount: amount)
    }

    pub fun addLiquidity(tokenAVault: @FungibleToken.Vault, tokenBVault: @FungibleToken.Vault): @FungibleToken.Vault {
        pre {
            tokenAVault.balance > 0.0 && tokenBVault.balance > 0.0 : "SwapPair: added zero liquidity"
            (tokenAVault.isInstance(self.token0VaultType) && tokenBVault.isInstance(self.token1VaultType)) || 
            (tokenBVault.isInstance(self.token0VaultType) && tokenAVault.isInstance(self.token1VaultType))
                : "SwapPair: added incompatible liquidity pair vaults"
        }
        
        // Add initial liquidity
        if (self.totalSupply == 0.0) {
            if (tokenAVault.isInstance(self.token0VaultType)) {
                self.token0Vault.deposit(from: <-tokenAVault)
                self.token1Vault.deposit(from: <-tokenBVault)
            } else {
                self.token0Vault.deposit(from: <-tokenBVault)
                self.token1Vault.deposit(from: <-tokenAVault)
            }
            // mint initial liquidity token and donate 1e-8 initial minimum liquidity token
            let initialLpAmount = SwapConfig.sqrt(self.token0Vault.balance) * SwapConfig.sqrt(self.token1Vault.balance)
            self.donateInitialMinimumLpToken()
            return <-self.mintLpToken(amount: initialLpAmount - SwapConfig.ufix64NonZeroMin)
        } else {
            var percent0 = 0.0
            var percent1 = 0.0
            if (tokenAVault.isInstance(self.token0VaultType)) {
                percent0 = tokenAVault.balance / self.token0Vault.balance
                percent1 = tokenBVault.balance / self.token1Vault.balance
                self.token0Vault.deposit(from: <-tokenAVault)
                self.token1Vault.deposit(from: <-tokenBVault)
            } else {
                percent0 = tokenBVault.balance / self.token0Vault.balance
                percent1 = tokenAVault.balance / self.token1Vault.balance
                self.token0Vault.deposit(from: <-tokenBVault)
                self.token1Vault.deposit(from: <-tokenAVault)
            }
            // Note: User should add proportional liquidity as any extra is added into pool.
            let liquidityPercent = percent0 < percent1 ? percent0 : percent1
            // mint liquidity token pro rata
            //////// TODO: percent multiply here might have truncation / precision issues...
            return <-self.mintLpToken(amount: liquidityPercent * self.totalSupply)
        }
    }

    // Return @[FungibleToken.Vault; 2]
    pub fun removeLiquidity(lpTokenVault: @FungibleToken.Vault) : @[FungibleToken.Vault] {
        pre {
            lpTokenVault.balance > 0.0 : "SwapPair: removed zero liquidity"
            lpTokenVault.isInstance(SwapPair.Vault.getType()): "SwapPair: input lpTokenVault type mismatch"
        }
        //////// TODO: use UFIx64ToUInt256 in division & multiply, or there's precision issues?
        let token0Amount = lpTokenVault.balance / self.totalSupply * self.token0Vault.balance
        let token1Amount = lpTokenVault.balance / self.totalSupply * self.token1Vault.balance
        let withdrawnToken0 <- self.token0Vault.withdraw(amount: token0Amount)
        let withdrawnToken1 <- self.token1Vault.withdraw(amount: token1Amount)

        self.burnLpToken(from: <- (lpTokenVault as! @SwapPair.Vault))
        return <- [<-withdrawnToken0, <-withdrawnToken1]
    }

    pub fun swap(inTokenAVault: @FungibleToken.Vault): @FungibleToken.Vault {
        pre {
            inTokenAVault.balance > 0.0: "SwapPair: zero in balance"
            inTokenAVault.isInstance(self.token0VaultType) || inTokenAVault.isInstance(self.token1VaultType): "SwapPair: incompatible in token vault"
        }
        var amountOut = 0.0
        if (inTokenAVault.isInstance(self.token0VaultType)) {
            amountOut = SwapConfig.getAmountOut(amountIn: inTokenAVault.balance, reserveIn: self.token0Vault.balance, reserveOut: self.token1Vault.balance)
        } else {
            amountOut = SwapConfig.getAmountOut(amountIn: inTokenAVault.balance, reserveIn: self.token1Vault.balance, reserveOut: self.token0Vault.balance)
        }

        if (inTokenAVault.isInstance(self.token0VaultType)) {
            emit Swap(inTokenAmount: inTokenAVault.balance, outTokenAmount: amountOut, direction: 0)
            self.token0Vault.deposit(from: <-inTokenAVault)
            return <- self.token1Vault.withdraw(amount: amountOut)
        } else {
            emit Swap(inTokenAmount: inTokenAVault.balance, outTokenAmount: amountOut, direction: 1)
            self.token1Vault.deposit(from: <-inTokenAVault)
            return <- self.token0Vault.withdraw(amount: amountOut)
        }
    }

    pub resource PairPublic: SwapInterfaces.PairPublic {
        pub fun swap(inTokenAVault: @FungibleToken.Vault): @FungibleToken.Vault {
            return <- SwapPair.swap(inTokenAVault: <-inTokenAVault)
        }

        pub fun removeLiquidity(lpTokenVault: @FungibleToken.Vault) : @[FungibleToken.Vault] {
            return <- SwapPair.removeLiquidity(lpTokenVault: <- lpTokenVault)
        }

        pub fun addLiquidity(tokenAVault: @FungibleToken.Vault, tokenBVault: @FungibleToken.Vault): @FungibleToken.Vault {
            return <- SwapPair.addLiquidity(tokenAVault: <- tokenAVault, tokenBVault: <- tokenBVault)
        }

        pub fun getAmountIn(amountOut: UFix64): UFix64 {
            return SwapConfig.getAmountIn(amountOut: amountOut, reserveIn: SwapPair.token0Vault.balance, reserveOut: SwapPair.token1Vault.balance)
        }
        pub fun getAmountOut(amountIn: UFix64): UFix64 {
            return SwapConfig.getAmountOut(amountIn: amountIn, reserveIn: SwapPair.token0Vault.balance, reserveOut: SwapPair.token1Vault.balance)
        }
    }

    init(token0Vault: @FungibleToken.Vault, token1Vault: @FungibleToken.Vault) {
        
        self.totalSupply = 0.0

        // TODO need sort??
        //let sortedTypes = SwapPair.sortTokens(inTokenAVaultType, inTokenBVaultType)
        self.token0VaultType = token0Vault.getType()
        self.token1VaultType = token1Vault.getType()
        self.token0Vault <- token0Vault
        self.token1Vault <- token1Vault


        // Open public interface capability
        destroy <-self.account.load<@AnyResource>(from: /storage/pair_public)
        self.account.save(<-create PairPublic(), to: /storage/pair_public)
        // Pair interface public path: SwapConfig.PairPublicPath
        self.account.link<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath, target: /storage/pair_public)                

        emit TokensInitialized(initialSupply: self.totalSupply)
    }
}