package test
import (	
	"fmt"	
	"math"
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/onflow/cadence"
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
		
	var result cadence.Value
	for i := 0.0; i < 2.0; i+=0.1 {
		result = executeScriptAndCheck(t, b, 
			testScript,
			[][]byte{
				jsoncdc.MustEncode(CadenceUFix64(fmt.Sprintf("%.6f", float64(i)))),
			},
		)	
		var log = fmt.Sprintf("%.6f", float64(i)) + ": " + fmt.Sprint(result) + " gt:"+ fmt.Sprintf("%.9f", math.Sqrt(float64(i)))
		assert.Equal(t, fmt.Sprintf("%.8f", math.Sqrt(float64(i))), fmt.Sprint(result), log)
	}
	for i := 1; i < 121; i++ {
		result = executeScriptAndCheck(t, b, 
			testScript,
			[][]byte{
				jsoncdc.MustEncode(CadenceUFix64(fmt.Sprintf("%.6f", float64(i)))),
			},
		)	
		var log = fmt.Sprintf("%.6f", float64(i)) + ": " + fmt.Sprint(result) + " gt:"+ fmt.Sprintf("%.8f", math.Sqrt(float64(i)))
		assert.Equal(t, fmt.Sprintf("%.8f", math.Sqrt(float64(i))), fmt.Sprint(result), log)
	}

}