module github.com/IncrementFi/Swap-v2/lib/go/test

go 1.13

require (
	github.com/IncrementFi/Swap-v2/lib/go/contracts v0.0.0-00010101000000-000000000000
	github.com/IncrementFi/Swap-v2/lib/go/templates v0.0.0-00010101000000-000000000000
	github.com/IncrementFi/Swap-v2/lib/go/util v0.0.0-00010101000000-000000000000
	github.com/onflow/cadence v0.21.0
	github.com/onflow/flow-emulator v0.28.1
	github.com/onflow/flow-go-sdk v0.24.0
	github.com/stretchr/testify v1.7.0
)

replace github.com/IncrementFi/Swap-v2/lib/go/contracts => ../contracts

replace github.com/IncrementFi/Swap-v2/lib/go/templates => ../templates

replace github.com/IncrementFi/Swap-v2/lib/go/util => ../util
