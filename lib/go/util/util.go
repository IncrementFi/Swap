package util
import (
	"regexp"
	"strings"
	"fmt"
)

var templateAddressMap map[string]string 
func InitAddressMap() {
	templateAddressMap = make(map[string]string)	
	templateAddressMap["FungibleToken"]= "0x0"
	templateAddressMap["FlowToken"]= "0x0"		
}
func UpdateAddressMap(key string, value string) {
	if _, ok := templateAddressMap[key]; ok {
		templateAddressMap[key] = value
	} else {
		fmt.Printf("Update address map with new key %s :%s\n", key, value)
		templateAddressMap[key] = value
	}
}
func ReplaceImports(code []byte, swapCoreAddress string, swapPairAddress string) []byte {
	if len(templateAddressMap) == 0 {
		InitAddressMap()
	}

	templateAddressMap["SwapPair"]= swapPairAddress		
	templateAddressMap["SwapInterfaces"]= swapCoreAddress
	templateAddressMap["SwapConfig"]= swapCoreAddress
	templateAddressMap["SwapError"]= swapCoreAddress
	templateAddressMap["SwapFactory"]= swapCoreAddress
	templateAddressMap["SwapRouter"]= swapCoreAddress
	re := regexp.MustCompile(`(\s*import\s*)([\w\d]+)(\s+from\s*)(\"?[\w\d.\\/]+\"?)`)		
	replacedCode := re.ReplaceAllFunc(code, func(b []byte) []byte {		
		imports := strings.Fields(string(b[:]))
		final := ""
		if v, ok := templateAddressMap[imports[1]]; ok {
			final = imports[0] + " " + imports[1] + " " + imports[2] + " " + v + "\n"
		} else {
			final = imports[0] + " " + imports[1] + " " + imports[2] + " " + imports[3] + "\n"
		}		
		return []byte(final)
	})
	return replacedCode
}