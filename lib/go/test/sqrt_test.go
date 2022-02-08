package test
import (	
	"fmt"
	"testing"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	
	"github.com/onflow/flow-go-sdk/test"
	"github.com/onflow/flow-go-sdk"
	templates "github.com/IncrementFi/Swap-v2/lib/go/templates"
)
func TestSqrtContracts(t *testing.T) {
	b := newBlockchain()

	accountKeys := test.AccountKeyGenerator()
	newAccountKey, newAccountSigner := accountKeys.NewWithSigner()
	_, newAccountAddr, tokenAddr := DeployBaseContracts(b, t, []*flow.AccountKey{newAccountKey}, newAccountSigner)
	pairAddrStr := "0x" + newAccountAddr.String()
	tokenAddrStr := "0x" + tokenAddr.String()
	fmt.Printf("pair addr %s, token addr %s\n", pairAddrStr, tokenAddrStr)
	testScript := templates.GenerateTestSqrtScript(pairAddrStr)
		
	result := executeScriptAndCheck(t, b, 
		testScript,
		[][]byte{
			jsoncdc.MustEncode(CadenceUFix64("15.00")),
		},
	)	
	fmt.Println(fmt.Sprint(result))
}