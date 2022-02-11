package tmp
import (
	"context"
	"fmt"
	"google.golang.org/grpc"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/client"
	"testing"
)

func checkError(errStrFmt string, err error, t *testing.T) {
	if err != nil {
		t.Errorf(errStrFmt, err)
	}
}

func handleError(errStr string, err error) {
	if err != nil {
		fmt.Println(errStr, err.Error())
		panic(err)
	}
}
func GetReferenceBlockId(flowClient *client.Client) flow.Identifier {
	block, err := flowClient.GetLatestBlock(context.Background(), true)
	handleError("GetReference block failed :%s", err)

	return block.ID
}
func TestTestNet(t *testing.T) {
	ctx := context.Background()
	testnet := "access.devnet.nodes.onflow.org:9000"	
	flowClient, err := client.New(testnet,grpc.WithInsecure())
	
	checkError("Failed to establish connection with the Access API %s", err, t)
	
	printTimestamp(flowClient)
	printLatestBlock(flowClient)

	testAddress := flow.HexToAddress("0xaafd78dcfb58b510")
	_, err1 := flowClient.GetAccount(ctx, testAddress)
	checkError("Get Account failed: %s", err1, t)

	transactionScript := []byte("transaction { execute { log(\"Hello\") } }")
	tx := flow.NewTransaction().
		SetScript(transactionScript).
		SetGasLimit(100).
		SetProposalKey(testAddress, 0, 0).
		SetPayer(testAddress).
		SetReferenceBlockID(GetReferenceBlockId(flowClient))

	transationError := flowClient.SendTransaction(ctx, *tx)
	checkError("Failed to send transaction: %s ", transationError, t)

	printTimestamp(flowClient)
	
	printLatestBlock(flowClient)
}

func printTimestamp(flowClient *client.Client) {
	timestampScript := []byte("pub fun main(): UFix64 { return getCurrentBlock().timestamp}")
	value, scriptErr := flowClient.ExecuteScriptAtLatestBlock(context.Background(), timestampScript, nil)
	handleError("Failed to execute script :", scriptErr)
	fmt.Println("time stamp", value)
}

func printLatestBlock(flowClient *client.Client) {    
	latestBlock, err := flowClient.GetLatestBlock(context.Background(), true)
	handleError("Get lastblock failed : %s", err)
	fmt.Printf("LatestBlock:\n")
    fmt.Printf("\nID: %s\n", latestBlock.ID)
    fmt.Printf("height: %d\n", latestBlock.Height)
    fmt.Printf("timestamp: %s\n\n", latestBlock.Timestamp)
}
