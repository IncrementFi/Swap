package templates

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../src/transactions -o internal/trans/assets.go -pkg assets_trans -nometadata -nomemcopy ../../../src/transactions/...

import (		
	"strings"	
	_ "github.com/kevinburke/go-bindata"
	"github.com/IncrementFi/Swap-v2/lib/go/util"
	"github.com/IncrementFi/Swap-v2/lib/go/templates/internal/trans"
)

const (
	createPairFileName = "factory/create_pair.template"
	deployPairFileName = "factory/deploy_pair_template.cdc"
	mintTokensFileName = "test/mint_all_tokens.cdc"
	addLiquidityFileName = "user/add_liquidity.cdc"
	removeLiquidityFileName = "user/remove_liquidity.cdc"	
)


func GenerateCreatePairScript(swapCoreAddr string, token0Name string, token1Name string, token0Addr string, token1Addr string) []byte {
	code := assets_trans.MustAssetString(createPairFileName)
	code = string(util.ReplaceImports([]byte(code), swapCoreAddr, ""))
	replacer := strings.NewReplacer("Token0Name", token0Name, "Token1Name", token1Name, 
									"Token0Addr", token0Addr, "Token1Addr", token1Addr)
	code = replacer.Replace(code)	
	return []byte(code)
}

func GenerateDeployPairScript(swapCoreAddr string) []byte {
	code := assets_trans.MustAsset(deployPairFileName)
	return util.ReplaceImports(code, swapCoreAddr, "")
}

func GenerateMintTokensScript(swapCoreAddr string) []byte {
	code := assets_trans.MustAsset(mintTokensFileName)
	return util.ReplaceImports(code, swapCoreAddr, "")
}

func GenerateAddLiquidityScript(swapCoreAddr string, swapPairAddr string) []byte {
	code := assets_trans.MustAsset(addLiquidityFileName)
	return util.ReplaceImports(code, swapCoreAddr, swapPairAddr)
}

func GenerateRemoveLiquidityScript(swapCoreAddr string, swapPairAddr string) []byte {
	code := assets_trans.MustAsset(removeLiquidityFileName)
	return util.ReplaceImports(code, swapCoreAddr, swapPairAddr)
}