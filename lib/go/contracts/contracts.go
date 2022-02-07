package contracts

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../src/contracts -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../src/contracts/...

import (
	"github.com/IncrementFi/Swap-v2/lib/go/util"
	"github.com/IncrementFi/Swap-v2/lib/go/contracts/internal/assets"
	_ "github.com/kevinburke/go-bindata"
)

const (
	fungibleTokenFileName            = "tokens/FungibleToken.cdc"
	flowTokenFileName                = "tokens/FlowToken.cdc"
	fusdFileName	                 = "tokens/FUSD.cdc"	
	bltFileName		                 = "tokens/BLT.cdc"	
	busdFileName					 = "tokens/BUSD.cdc"
	fbtcFileName					 = "tokens/FBTC.cdc"
	usdcFileName					 = "tokens/USDC.cdc"
	usdtFileName					 = "tokens/USDT.cdc"
	wFlowFileName					 = "tokens/wFlow.cdc"
	testTokenAFileName				 = "tokens/TestTokenA.cdc"
	testTokenBFileName				 = "tokens/TestTokenB.cdc"
	testTokenCFileName				 = "tokens/TestTokenC.cdc"
	swapConfigFileName 				 = "SwapConfig.cdc"
	swapErrorFileName				 = "SwapError.cdc"
	swapFactoryFileName			     = "SwapFactory.cdc"
	swapInterfacesFileName			 = "SwapInterfaces.cdc"
	swapPairFileName				 = "SwapPair.cdc"
	swapRouterFileName				 = "SwapRouter.cdc"
)

// FungibleToken returns the FungibleToken contract interface.
func FungibleToken() []byte {
	code := assets.MustAsset(fungibleTokenFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// FlowToken returns the FlowToken contract interface.
func FlowToken() []byte {
	code := assets.MustAsset(flowTokenFileName)
	return util.ReplaceImports([]byte(code), "", "")
}


// FUSD returns the FUSD contract interface.
func FUSD() []byte {
	code := assets.MustAsset(fusdFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// BLT returns the BLT contract interface.
func BLT() []byte {
	code := assets.MustAsset(bltFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// FBTC returns the FBTC contract interface.
func FBTC() []byte {
	code := assets.MustAsset(fbtcFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// BUSD returns the BUSD contract interface.
func BUSD() []byte {
	code := assets.MustAsset(busdFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// USDC returns the USDC contract interface.
func USDC() []byte {
	code := assets.MustAsset(usdcFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// USDT returns the USDT contract interface.
func USDT() []byte {
	code := assets.MustAsset(usdtFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// wFlow returns the wFlow contract interface.
func WFlow() []byte {
	code := assets.MustAsset(wFlowFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// TestTokenA returns the TestTokenA contract interface.
func TestTokenA() []byte {
	code := assets.MustAsset(testTokenAFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// TestTokenB returns the TestTokenB contract interface.
func TestTokenB() []byte {
	code := assets.MustAsset(testTokenBFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// TestTokenC returns the TestTokenC contract interface.
func TestTokenC() []byte {
	code := assets.MustAsset(testTokenCFileName)
	return util.ReplaceImports([]byte(code), "", "")
}


// SwapConfig returns the SwapConfig contract interface.
func SwapConfig() []byte {
	code := assets.MustAsset(swapConfigFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// SwapError returns the SwapError contract interface.
func SwapError() []byte {
	code := assets.MustAsset(swapErrorFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// SwapFactory returns the SwapFactory contract interface.
func SwapFactory(swapAddress string) []byte {
	code := assets.MustAsset(swapFactoryFileName)
	return util.ReplaceImports([]byte(code), swapAddress, "")
}

// SwapInterfaces returns the SwapInterfaces contract interface.
func SwapInterfaces() []byte {
	code := assets.MustAsset(swapInterfacesFileName)
	return util.ReplaceImports([]byte(code), "", "")
}

// SwapPair returns the SwapPair contract interface.
func SwapPair(swapAddress string) []byte {
	code := assets.MustAsset(swapPairFileName)
	return util.ReplaceImports([]byte(code), swapAddress, "")
}

// SwapRouter returns the SwapRouter contract interface.
func SwapRouter(swapAddress string) []byte {
	code := assets.MustAsset(swapRouterFileName)
	return util.ReplaceImports([]byte(code), swapAddress, "")
}



