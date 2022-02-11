package contracts_test

import (
	"testing"
	"github.com/stretchr/testify/assert"
	"github.com/IncrementFi/Swap-v2/lib/go/contracts"
)

const (
	addrA = "0x0A"
	addrB = "0x0B"
)

func TestFungibleTokenContract(t *testing.T) {
	contract := contracts.FungibleToken()
	assert.NotNil(t, contract)
}

func TestFlowTokenContract(t *testing.T) {
	contract := contracts.FlowToken()
	assert.NotNil(t, contract)
}

func TestWFlowContract(t *testing.T) {
	contract := contracts.WFlow()
	assert.NotNil(t, contract)
}

func TestSwapConfig(t *testing.T) {
	contract := contracts.SwapConfig()
	assert.NotNil(t, contract)
}

func TestSwapError(t *testing.T) {
	contract := contracts.SwapError()
	assert.NotNil(t, contract)
}

func TestSwapFactory(t *testing.T) {
	contract := contracts.SwapFactory(addrA)
	assert.NotNil(t, contract)
	assert.Contains(t, string(contract), addrA)
}

func TestSwapInterfaces(t *testing.T) {
	contract := contracts.SwapInterfaces()
	assert.NotNil(t, contract)	
}

func TestSwapPair(t *testing.T) {
	contract := contracts.SwapPair(addrA)
	assert.NotNil(t, contract)
	assert.Contains(t, string(contract), addrA)
}

func TestSwapRouter(t *testing.T) {
	contract := contracts.SwapRouter(addrA)
	assert.NotNil(t, contract)
	assert.Contains(t, string(contract), addrA)
}
