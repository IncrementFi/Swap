package test

import (
	"testing"	
	"fmt"	

	emulator "github.com/onflow/flow-emulator"
	sdktemplates "github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"

	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/onflow/flow-go-sdk"

	"github.com/stretchr/testify/assert"


	"github.com/IncrementFi/Swap-v2/lib/go/contracts"
	templates "github.com/IncrementFi/Swap-v2/lib/go/templates"
	"github.com/IncrementFi/Swap-v2/lib/go/util"
)

const (
	emulatorFTAddress        = "0xee82856bf20e2aa6"
	emulatorFlowTokenAddress = "0x0ae53cb6e3f42a79"
)

func checkError(errStrFmt string, err error, t *testing.T) {
	if err != nil {
		t.Errorf(errStrFmt, err)		
	}
	assert.NoError(t, err)
}


func DeployBaseContracts(b *emulator.Blockchain, t *testing.T, key []*flow.AccountKey, signer crypto.Signer) (fungleTokenAddr flow.Address, newAccountAddr flow.Address, tokenAddr flow.Address){
	var err error
	// var tx *flow.Transaction
	var fungibleTokenAddr flow.Address
	var flowTokenAddr flow.Address
	// Should be able to deploy a contract as a new account with no keys.
	fungibleTokenCode := contracts.FungibleToken()
	fungibleTokenAddr, err = b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "FungibleToken",
				Source: string(fungibleTokenCode),
			},
		},
	)
	assert.NoError(t, err)

	_, err = b.CommitBlock()
	assert.NoError(t, err)

	// fungibleTokenAddr = flow.HexToAddress(emulatorFTAddress)
	flowTokenAddr = flow.HexToAddress(emulatorFlowTokenAddress)
	
	util.UpdateAddressMap("FungibleToken", "0x" + fungibleTokenAddr.String())	
	util.UpdateAddressMap("FlowToken", "0x" + flowTokenAddr.String())
	
	fmt.Println("FungibleToken " + fungibleTokenAddr.String())
	fmt.Println("FlowToken " + flowTokenAddr.String())

	fusdCode := contracts.FUSD()	
	bltCode := contracts.BLT()	
	busdCode := contracts.BUSD()	
	fbtcCode := contracts.FBTC()
	usdcCode := contracts.USDC()
	usdtCode := contracts.USDT()
	wFlowCode := contracts.WFlow()
	testTokenACode := contracts.TestTokenA()
	testTokenBCode := contracts.TestTokenB()
	testTokenCCode := contracts.TestTokenC()
	
	swapConfigCode := contracts.SwapConfig()
	swapErrorCode := contracts.SwapError()
	swapInterfacesCode := contracts.SwapInterfaces()
	newAccountAddr, err = b.CreateAccount(key, []sdktemplates.Contract {
		{
			Name: "SwapConfig",
			Source: string(swapConfigCode),
		},
		{
			Name: "SwapError",
			Source: string(swapErrorCode),
		},
		{
			Name: "SwapInterfaces",
			Source: string(swapInterfacesCode),
		},
	})

	tokenAddr, err = b.CreateAccount(key, []sdktemplates.Contract {		
		{
			Name: "FUSD",
			Source: string(fusdCode),
		},
		{
			Name: "BLT",
			Source: string(bltCode),
		},
		{
			Name: "BUSD",
			Source: string(busdCode),
		},
		{
			Name: "FBTC",
			Source: string(fbtcCode),
		},
		{
			Name: "USDC",
			Source: string(usdcCode),
		},
		{
			Name: "USDT",
			Source: string(usdtCode),
		},
		{
			Name: "wFlow",
			Source: string(wFlowCode),
		},
		{
			Name: "TestTokenA",
			Source: string(testTokenACode),
		},
		{
			Name: "TestTokenB",
			Source: string(testTokenBCode),
		},
		{
			Name: "TestTokenC",
			Source: string(testTokenCCode),
		},
		
	})
	fmt.Println("Service addr " + b.ServiceKey().Address.String())
	fmt.Println("NewAccount Addr " + newAccountAddr.String())
	fmt.Println("Token Addr " + tokenAddr.String())
	util.UpdateAddressMap("SwapConfig", "0x" + newAccountAddr.String())
	util.UpdateAddressMap("SwapError", "0x" + newAccountAddr.String())
	util.UpdateAddressMap("SwapInterfaces", "0x" + newAccountAddr.String())
	util.UpdateAddressMap("FUSD", "0x" + tokenAddr.String())
	util.UpdateAddressMap("BLT", "0x" + tokenAddr.String())
	util.UpdateAddressMap("FBTC", "0x" + tokenAddr.String())
	util.UpdateAddressMap("BUSD", "0x" + tokenAddr.String())
	util.UpdateAddressMap("USDC", "0x" + tokenAddr.String())
	util.UpdateAddressMap("USDT", "0x" + tokenAddr.String())
	util.UpdateAddressMap("wFlow", "0x" + tokenAddr.String())	
	util.UpdateAddressMap("TestTokenA", "0x" + tokenAddr.String())
	util.UpdateAddressMap("TestTokenB", "0x" + tokenAddr.String())
	util.UpdateAddressMap("TestTokenC", "0x" + tokenAddr.String())
	
	checkError("Deploy swap config failed:", err, t)

	// deploy factory and pair interfaces to newAccount addr

	swapFactoryCode := contracts.SwapFactory("0x" + newAccountAddr.String())
	
	createSwapFactoryScript := `
	transaction(name: String, code: String, addr: Address) {
		prepare(signer: AuthAccount) {
			signer.contracts.add(name: name, code: code.decodeHex(), pairTemplate: addr)
		}
	}
	`
	swapFactoryContract := sdktemplates.Contract {
		Name: "SwapFactory",
		Source: string(swapFactoryCode),
	}
	tx := createTxWithTemplateAndAuthorizer(b, []byte(createSwapFactoryScript), newAccountAddr)
	tx.AddRawArgument(jsoncdc.MustEncode(cadence.String(swapFactoryContract.Name))).
	AddRawArgument(jsoncdc.MustEncode(cadence.String(swapFactoryContract.SourceHex()))).
	AddRawArgument(jsoncdc.MustEncode(cadence.Address(newAccountAddr)))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{
			b.ServiceKey().Address,
			newAccountAddr,
		},
		[]crypto.Signer{
			b.ServiceKey().Signer(),
			signer,
		},
		false,
	)

	return fungibleTokenAddr, newAccountAddr, tokenAddr
}

func TestSwapPairContracts(t *testing.T) {
	b := newBlockchain()

	accountKeys := test.AccountKeyGenerator()
	newAccountKey, newAccountSigner := accountKeys.NewWithSigner()
	_, newAccountAddr, tokenAddr := DeployBaseContracts(b, t, []*flow.AccountKey{newAccountKey}, newAccountSigner)
	pairAddrStr := "0x" + newAccountAddr.String()
	tokenAddrStr := "0x" + tokenAddr.String()
	fmt.Printf("pair addr %s, token addr %s\n", pairAddrStr, tokenAddrStr)
	deployPairScript := templates.GenerateDeployPairScript(pairAddrStr)
	
	tx := createTxWithTemplateAndAuthorizer(b, deployPairScript, newAccountAddr)
	swapPairCode := contracts.SwapPair(pairAddrStr)
	tx.AddRawArgument(jsoncdc.MustEncode(cadence.String(swapPairCode)))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{
			b.ServiceKey().Address,
			newAccountAddr,
		},
		[]crypto.Signer{
			b.ServiceKey().Signer(),
			newAccountSigner,
		},
		false,
	)	

	// Mint all test tokens
	mintAllTokenScript := templates.GenerateMintTokensScript(pairAddrStr)
	
	tx = createTxWithTemplateAndAuthorizer(b, mintAllTokenScript, newAccountAddr)
	tx.AddRawArgument(jsoncdc.MustEncode(CadenceUFix64("1000.0")))
	signAndSubmit(
		t, b, tx,
		[]flow.Address{
			b.ServiceKey().Address,
			newAccountAddr,
		},
		[]crypto.Signer{
			b.ServiceKey().Signer(),
			newAccountSigner,
		},
		false,
	)		

	t.Run("Should be able to create swap pair(TestTokenA,TestTokenB)", func(t *testing.T) {
		tokenAIdentifier := "A." + tokenAddr.String() + ".TestTokenA"
		tokenBIdentifier := "A." + tokenAddr.String() + ".TestTokenB"
		createPairScript := templates.GenerateCreatePairScript(pairAddrStr, "TestTokenA", "TestTokenB", tokenAddrStr, tokenAddrStr)
		tx = createTxWithTemplateAndAuthorizer(b, createPairScript, newAccountAddr)	
		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				newAccountAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				newAccountSigner,
			},
			false,
		)

		queryPairAddrScript := templates.GenerateQueryPairAddr(pairAddrStr)
		result := executeScriptAndCheck(t, b, 
			queryPairAddrScript,
			[][]byte{
				jsoncdc.MustEncode(cadence.String(tokenAIdentifier)),
				jsoncdc.MustEncode(cadence.String(tokenBIdentifier)),
			},
		)
		assert.NotNil(t, result)
	})

	t.Run("Should be able to add liquidity to swap pair(TestTokenA,TestTokenB)", func(t *testing.T) {
		tokenAIdentifier := "A." + tokenAddr.String() + ".TestTokenA"
		tokenBIdentifier := "A." + tokenAddr.String() + ".TestTokenB"

		queryPairAddrScript := templates.GenerateQueryPairAddr(pairAddrStr)
		result := executeScriptAndCheck(t, b, 
			queryPairAddrScript,
			[][]byte{
				jsoncdc.MustEncode(cadence.String(tokenAIdentifier)),
				jsoncdc.MustEncode(cadence.String(tokenBIdentifier)),
			},
		)
		assert.NotNil(t, result)
		newPairAddrStr := fmt.Sprint(result)		
		fmt.Println("new pair address : " + newPairAddrStr)
		addLiquidityScript := templates.GenerateAddLiquidityScript(pairAddrStr, newPairAddrStr)
		tx = createTxWithTemplateAndAuthorizer(b, addLiquidityScript, newAccountAddr)
		tx.AddRawArgument(jsoncdc.MustEncode(cadence.String(tokenAIdentifier)))
		tx.AddRawArgument(jsoncdc.MustEncode(cadence.String(tokenBIdentifier)))
		tx.AddRawArgument(jsoncdc.MustEncode(CadenceUFix64("100.0")))
		tx.AddRawArgument(jsoncdc.MustEncode(CadenceUFix64("100.0")))
		tx.AddRawArgument(jsoncdc.MustEncode(cadence.Path{Domain: "storage", Identifier: "testTokenAVault"}))
		tx.AddRawArgument(jsoncdc.MustEncode(cadence.Path{Domain: "storage", Identifier: "testTokenBVault"}))
		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				newAccountAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				newAccountSigner,
			},
			false,
		)

		queryPairInfoScript := templates.GenerateQueryPairInfoByAddrsScript(pairAddrStr)
		addrArray := make([]cadence.Value, 1)
		addrArray[0] = cadence.Address(flow.HexToAddress(newPairAddrStr))
		result = executeScriptAndCheck(t, b, 
			queryPairInfoScript,
			[][]byte{
				jsoncdc.MustEncode(cadence.NewArray(addrArray)),
			},
		)
		assert.NotNil(t, result)
		pairArrayStr := fmt.Sprint(result)
		fmt.Println(pairArrayStr)

		// Query LPToken balance
		queryPairBalanceScript := templates.GenerateQueryPairBalance(pairAddrStr, newPairAddrStr)
		fmt.Println(string(queryPairBalanceScript))
		result = executeScriptAndCheck(t, b, 
			queryPairBalanceScript,
			[][]byte{
				jsoncdc.MustEncode(cadence.Address(flow.HexToAddress(pairAddrStr))),
				jsoncdc.MustEncode(cadence.Path{Domain: "public", Identifier: "concattokentestBalance"}), // TODO: auto change identifier
			},
		)
		assertEqual(t, CadenceUFix64("99.99999979"), result)
	})
}