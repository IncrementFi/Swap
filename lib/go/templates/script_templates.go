package templates
//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../src/scripts -o internal/script/assets.go -pkg assets_script -nometadata -nomemcopy ../../../src/scripts/...
import (
	"github.com/IncrementFi/Swap-v2/lib/go/templates/internal/script"
	"github.com/IncrementFi/Swap-v2/lib/go/util"	
)

const (
	queryPairAddrFileName	        	= "query/query_pair_addr.cdc"
	queryPairBalanceFileName	        = "query/query_pair_balance.cdc"
	queryPairArrayAddrFileName        	= "query/query_pair_array_addr.cdc"
	queryPairArrayInfoFileName 			= "query/query_pair_array_info.cdc"
	queryPairInfoByAddrsFileName 		= "query/query_pair_info_by_addrs.cdc"
	queryTokenNamesFileName				= "qeury/query_token_names.cdc"
	testSqrtFileName 					= "test/sqrt_test.cdc"
)

func GenerateQueryPairAddr(swapCoreAddr string) []byte {
	code := assets_script.MustAssetString(queryPairAddrFileName)
	return util.ReplaceImports([]byte(code), swapCoreAddr, "")
}

func GenerateQueryPairBalance(swapCoreAddr string, swapPairAddress string) []byte {
	code := assets_script.MustAssetString(queryPairBalanceFileName)
	return util.ReplaceImports([]byte(code), swapCoreAddr, swapPairAddress)
}

func GenerateQueryPairArrayAddrScript(swapCoreAddr string) []byte {
	code := assets_script.MustAssetString(queryPairArrayAddrFileName)
	return util.ReplaceImports([]byte(code), swapCoreAddr, "")
}

func GenerateQueryPairArrayInfoScript(swapCoreAddr string) []byte {
	code := assets_script.MustAssetString(queryPairArrayInfoFileName)
	return util.ReplaceImports([]byte(code), swapCoreAddr, "")
}

func GenerateQueryPairInfoByAddrsScript(swapCoreAddr string) []byte {
	code := assets_script.MustAssetString(queryPairInfoByAddrsFileName)
	return util.ReplaceImports([]byte(code), swapCoreAddr, "")
}

func GenerateQueryTokenNamesScript(swapCoreAddr string) []byte {
	code := assets_script.MustAssetString(queryTokenNamesFileName)
	return util.ReplaceImports([]byte(code), "", "")
}


func GenerateTestSqrtScript(swapCoreAddr string) []byte {
	code := assets_script.MustAsset(testSqrtFileName)
	return util.ReplaceImports(code, swapCoreAddr, "")
}


