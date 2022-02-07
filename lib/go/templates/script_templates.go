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
)

func GenerateQueryPairAddr(pairAddress string) []byte {
	code := assets_script.MustAssetString(queryPairAddrFileName)
	return util.ReplaceImports([]byte(code), pairAddress, "")
}

func GenerateQueryPairBalance(pairAddress string, swapPairAddress string) []byte {
	code := assets_script.MustAssetString(queryPairBalanceFileName)
	return util.ReplaceImports([]byte(code), pairAddress, swapPairAddress)
}

func GenerateQueryPairArrayAddrScript(pairAddress string) []byte {
	code := assets_script.MustAssetString(queryPairArrayAddrFileName)
	return util.ReplaceImports([]byte(code), pairAddress, "")
}

func GenerateQueryPairArrayInfoScript(pairAddress string) []byte {
	code := assets_script.MustAssetString(queryPairArrayInfoFileName)
	return util.ReplaceImports([]byte(code), pairAddress, "")
}

func GenerateQueryPairInfoByAddrsScript(pairAddress string) []byte {
	code := assets_script.MustAssetString(queryPairInfoByAddrsFileName)
	return util.ReplaceImports([]byte(code), pairAddress, "")
}

func GenerateQueryTokenNamesScript(pairAddress string) []byte {
	code := assets_script.MustAssetString(queryTokenNamesFileName)
	return util.ReplaceImports([]byte(code), "", "")
}




