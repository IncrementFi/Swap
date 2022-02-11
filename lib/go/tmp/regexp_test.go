package tmp
import (
	"fmt"
	"strings"
	"regexp"
	"testing"
)


func TestRegExp(t *testing.T) {
	templateAddressMap := map[string]string {
		"fungletoken": "0x2000000",
	}
	re := regexp.MustCompile(`(\s*import\s*)([\w\d]+)(\s+from\s*)(\"?[\w\d.\\/]+\"?)`)	
	test := []byte("  import fungletoken from \"../../contracts/SwapFactory.cdc\" aaaa")
	fmt.Printf("%s\n", re.ReplaceAllFunc(test, func(b []byte) []byte {		
		imports := strings.Fields(string(b[:]))
		final := ""
		if v, ok := templateAddressMap[imports[1]]; ok {
			final = imports[0] + " " + imports[1] + " " + imports[2] + " " + v
		} else {
			final = imports[0] + " " + imports[1] + " " + imports[2] + " " + imports[3]
		}
		fmt.Printf("- %s\n", final)
		return []byte(final)
	}))
}
