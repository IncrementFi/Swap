// Code generated by go-bindata. DO NOT EDIT.
// sources:
// ../../../cadence/scripts/query/query_pair_addr.cdc (206B)
// ../../../cadence/scripts/query/query_pair_array_addr.cdc (170B)
// ../../../cadence/scripts/query/query_pair_array_info.cdc (172B)
// ../../../cadence/scripts/query/query_pair_balance.cdc (439B)
// ../../../cadence/scripts/query/query_pair_info_by_addrs.cdc (469B)
// ../../../cadence/scripts/query/query_token_names.cdc (1.699kB)

package assets_script

import (
	"bytes"
	"compress/gzip"
	"crypto/sha256"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func bindataRead(data, name string) ([]byte, error) {
	gz, err := gzip.NewReader(strings.NewReader(data))
	if err != nil {
		return nil, fmt.Errorf("read %q: %w", name, err)
	}

	var buf bytes.Buffer
	_, err = io.Copy(&buf, gz)

	if err != nil {
		return nil, fmt.Errorf("read %q: %w", name, err)
	}

	clErr := gz.Close()
	if clErr != nil {
		return nil, clErr
	}

	return buf.Bytes(), nil
}

type asset struct {
	bytes  []byte
	info   os.FileInfo
	digest [sha256.Size]byte
}

type bindataFileInfo struct {
	name    string
	size    int64
	mode    os.FileMode
	modTime time.Time
}

func (fi bindataFileInfo) Name() string {
	return fi.name
}
func (fi bindataFileInfo) Size() int64 {
	return fi.size
}
func (fi bindataFileInfo) Mode() os.FileMode {
	return fi.mode
}
func (fi bindataFileInfo) ModTime() time.Time {
	return fi.modTime
}
func (fi bindataFileInfo) IsDir() bool {
	return false
}
func (fi bindataFileInfo) Sys() interface{} {
	return nil
}

var _queryQuery_pair_addrCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x54\x8d\xb1\x0a\xc2\x30\x14\x45\xf7\x7c\xc5\xa5\x93\x05\x79\xd5\xb5\x8b\xb8\xb8\xb8\x08\xfd\x82\x98\xa6\x25\x48\x5f\xc2\xcb\x0b\x52\xc4\x7f\x17\x44\x4a\xdc\x2e\x87\xc3\xb9\x61\x49\x51\x14\xc3\xd3\xa6\x8b\x75\x1a\x65\xc5\x24\x71\x41\x43\xd4\x11\x75\x2e\xb2\x8a\x75\x9a\xbb\xca\x20\x37\xba\xc6\x98\x54\xee\x98\x0a\x63\xb1\x81\x77\x1a\x1f\x9e\x0f\x57\xbf\xf6\x18\x54\x02\xcf\x7b\x7c\xd1\xb1\x42\x6d\x8f\xf3\x38\x8a\xcf\xf9\x04\xbc\x0c\x00\x88\xd7\x22\x5c\xdf\xd3\xec\xf5\x66\x83\xfc\xcc\x3a\xbc\xcd\xbf\xf6\x36\x5b\xf3\xfe\x04\x00\x00\xff\xff\x01\x29\xdf\x1c\xce\x00\x00\x00"

func queryQuery_pair_addrCdcBytes() ([]byte, error) {
	return bindataRead(
		_queryQuery_pair_addrCdc,
		"query/query_pair_addr.cdc",
	)
}

func queryQuery_pair_addrCdc() (*asset, error) {
	bytes, err := queryQuery_pair_addrCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "query/query_pair_addr.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0xaa, 0x76, 0xe0, 0x70, 0xdd, 0xf4, 0xea, 0x9a, 0x7f, 0x37, 0x93, 0x4a, 0xb4, 0x47, 0x28, 0xb4, 0xe6, 0xa5, 0x70, 0xc3, 0xf2, 0x34, 0xe8, 0xd2, 0x24, 0x2e, 0x43, 0x0, 0x4a, 0x9a, 0xe5, 0xa2}}
	return a, nil
}

var _queryQuery_pair_array_addrCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x4c\x8d\xb1\xca\x02\x31\x10\x84\xfb\x3c\xc5\x70\xd5\x7f\xf0\xb3\xd7\x88\xc5\x75\xd7\x08\x76\x82\x58\x89\x45\xcc\xe5\x24\x45\xb2\x61\xb3\x41\x44\x7c\x77\x09\x2a\x5c\x33\x4c\xf1\xcd\x37\x21\x66\x16\xc5\xf1\x6e\xf3\xce\x3a\x65\x79\x60\x11\x8e\xe8\x88\x06\xa2\xc1\x71\x52\xb1\x4e\xcb\xb0\x22\xc8\xcd\xae\x33\x26\xd7\x2b\x96\x9a\x10\x6d\x48\x7f\x6d\x34\xe2\xb4\x4f\xba\xdd\xfc\x43\xf9\xd7\xfb\x11\xe7\x69\x9e\xc5\x97\x72\xc1\xd3\x00\x80\x78\xad\x92\xd6\x97\x74\xf3\x7a\xb0\x41\x26\x91\xc6\x7e\x65\x2d\x3f\x2a\xe5\xde\xbc\xde\x01\x00\x00\xff\xff\x6c\x5f\x87\xf7\xaa\x00\x00\x00"

func queryQuery_pair_array_addrCdcBytes() ([]byte, error) {
	return bindataRead(
		_queryQuery_pair_array_addrCdc,
		"query/query_pair_array_addr.cdc",
	)
}

func queryQuery_pair_array_addrCdc() (*asset, error) {
	bytes, err := queryQuery_pair_array_addrCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "query/query_pair_array_addr.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x6, 0xc0, 0x82, 0x78, 0x35, 0xde, 0x95, 0xa9, 0xaf, 0xac, 0x45, 0x1c, 0xb7, 0x8, 0x7b, 0x2c, 0xfa, 0xa0, 0xb2, 0xa2, 0xa6, 0x55, 0xfd, 0xd0, 0xc5, 0xa7, 0x3f, 0x20, 0x60, 0x49, 0x56, 0xcc}}
	return a, nil
}

var _queryQuery_pair_array_infoCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x4c\x8d\xb1\x0a\xc2\x40\x10\x44\xfb\xfb\x8a\x21\x95\x01\xd9\x34\x62\x91\x2e\x8d\x90\x4e\x08\x56\x62\x71\xae\x89\xa4\xc8\xee\xb1\xee\x21\x41\xfc\x77\x09\x2a\xa4\x19\xa6\x98\x79\x6f\x9c\x92\x9a\xa3\x7b\xc6\x74\x88\xec\x6a\x33\x06\xd3\x09\x05\x51\x45\x54\xb1\x8a\x5b\x64\x7f\x54\xab\x05\xf1\x8d\x8b\x10\x52\xbe\x62\xc8\x82\x29\x8e\xb2\x59\x4e\x35\x4e\xad\xf8\x7e\xb7\x85\xeb\xbf\x97\x35\xce\x8d\xcc\x9d\x5b\x66\xbf\xe0\x15\x00\xc0\x7a\xcf\x26\x6b\x29\xdd\x7b\x3f\xc6\xd1\x1a\xb3\x56\x06\xfd\xe1\x96\xfc\xc2\x5c\xcb\xf0\xfe\x04\x00\x00\xff\xff\xa2\xcb\x4b\x74\xac\x00\x00\x00"

func queryQuery_pair_array_infoCdcBytes() ([]byte, error) {
	return bindataRead(
		_queryQuery_pair_array_infoCdc,
		"query/query_pair_array_info.cdc",
	)
}

func queryQuery_pair_array_infoCdc() (*asset, error) {
	bytes, err := queryQuery_pair_array_infoCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "query/query_pair_array_info.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x0, 0x75, 0x28, 0xba, 0xc3, 0x64, 0x22, 0xa6, 0xf7, 0x34, 0x4e, 0x8c, 0x74, 0x2, 0xc8, 0xe8, 0xbf, 0x81, 0x42, 0x7c, 0x49, 0xe0, 0x46, 0xe6, 0x77, 0xd7, 0x33, 0x24, 0xd8, 0xb1, 0x27, 0x70}}
	return a, nil
}

var _queryQuery_pair_balanceCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x64\x90\x4d\x6b\x32\x31\x14\x85\xf7\xf3\x2b\x0e\x2e\x5e\x14\x5e\x86\x2e\x4a\x17\x52\x2b\xe3\x57\x91\x16\x3b\x38\xda\xae\xef\xc4\x3b\x63\x68\x4c\x86\x78\x53\x2d\xe2\x7f\x2f\xe3\xa8\xd0\x9a\xd5\x25\x39\xe7\x79\x92\xe8\x4d\xe5\xbc\x60\x12\x6c\xa9\x73\xc3\x0b\xf7\xc9\x16\x85\x77\x1b\xdc\xed\x27\xcb\xd9\xf3\x74\xf0\x3a\x5e\xbc\xbd\x8c\x67\xc9\x68\x34\x1f\x67\x59\x74\x2e\x64\x3b\xaa\x52\xd2\xfe\x92\xcd\x3e\x92\x34\x4d\xa6\xf3\x28\xaa\x42\x8e\x22\x58\x6c\x48\xdb\x36\x29\xe5\x82\x95\x2e\x92\xd5\xca\xf3\x76\xfb\x1f\x52\x1b\x06\x64\xc8\x2a\x4e\x49\xd6\x5d\xa4\x21\x37\x5a\xd5\x73\xa7\x8b\xe5\x44\xef\x1f\xee\x71\x88\x00\xc0\xb0\x80\x94\x12\xf4\x50\xb2\x24\x0d\xeb\xc2\xec\x34\x11\x57\xde\x6e\xfc\x75\x34\x27\x57\xe4\x17\x05\x23\x73\x2e\xd0\x3b\xd1\xe3\x92\x65\x48\x15\xe5\xda\x68\xf9\x7e\xfc\x77\x79\x5a\xfc\x5e\xe7\x0e\xbf\xbe\x26\x3e\x53\x8f\x4f\xb7\x92\x38\x77\xde\xbb\x5d\xbb\xb1\xd5\xab\xdf\x47\x45\x56\xab\x76\x6b\xe8\x82\x59\xc1\x3a\x41\x13\xc2\xb9\x08\xcf\x05\x7b\xae\x27\x71\x90\x35\xe3\x24\x6d\x75\xa2\x13\xc4\xb3\x04\x6f\xaf\x17\x8e\xf3\xa6\x15\x1d\x7f\x02\x00\x00\xff\xff\x58\xd8\x20\x0c\xb7\x01\x00\x00"

func queryQuery_pair_balanceCdcBytes() ([]byte, error) {
	return bindataRead(
		_queryQuery_pair_balanceCdc,
		"query/query_pair_balance.cdc",
	)
}

func queryQuery_pair_balanceCdc() (*asset, error) {
	bytes, err := queryQuery_pair_balanceCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "query/query_pair_balance.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x2b, 0x2, 0xc3, 0x88, 0xf6, 0x95, 0x1c, 0xfc, 0xcd, 0x37, 0x7d, 0xd8, 0xc2, 0x8e, 0x9b, 0xe9, 0xd3, 0xb0, 0x33, 0x93, 0xdf, 0xef, 0xbc, 0xe4, 0x19, 0x39, 0x4d, 0xe0, 0x3f, 0xbf, 0x94, 0xbf}}
	return a, nil
}

var _queryQuery_pair_info_by_addrsCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x7c\x50\xcd\x6a\x02\x31\x10\xbe\xef\x53\x4c\x3d\x94\x84\x42\x6c\xaf\x45\x0b\xe2\xc9\x9b\xe0\x51\xf6\x90\xcd\x66\xd7\x81\x75\x12\x26\x93\x8a\x88\xef\x5e\xa2\x65\x57\x7b\xe8\x5c\x76\xf6\xfb\xe3\xcb\xe0\x31\x06\x16\xd8\x9d\x6c\xdc\x90\x78\xee\xac\xf3\x09\x3a\x0e\x47\x98\x19\x33\x37\x66\xee\x02\x09\x5b\x27\x69\xfe\x2c\x32\xae\x75\xb3\xea\xc1\xbf\x0e\xd4\x61\xff\x8f\xf7\x2e\xb8\xfb\xaa\x98\x1b\xe8\x32\xc1\xd1\x22\xa9\x68\x91\x57\x6d\xcb\xe9\x13\xf6\xe5\xeb\x53\xaa\x75\xd9\xe9\xbc\x13\xce\x4e\x6a\xb8\x54\x00\x00\xdf\x96\x81\x7d\x7a\xa6\x96\xb0\xaf\x47\x16\x61\x09\xef\xe3\xdf\xe0\x09\x96\x30\xc6\x9b\xc1\x53\x2f\x87\x1b\x7d\x3a\xe0\xe0\x15\xc2\xa2\x88\xf4\x6f\x7e\x19\xf6\xc9\xd8\x18\x3d\xb5\x6a\xc4\xca\xf4\x5e\x56\xce\x85\x4c\x32\xf5\xdd\x63\xad\x4d\xef\x65\x6d\xa3\x6d\x70\x40\x39\x2f\x5e\x2f\x7f\xee\xb4\xb5\xc8\xdb\xdc\x0c\xe8\xae\x5f\xea\xe1\x0e\x13\xbe\xb5\x72\xd0\xa6\x09\xcc\xe1\xa4\xf4\x4b\x09\x2c\xe4\x86\xba\xa0\xf4\xd8\x61\xda\xca\x1b\x11\xde\xe0\xe3\x86\x5c\xab\x7b\x6b\xc9\x4c\xa5\x7c\x75\xfd\x09\x00\x00\xff\xff\x77\x3b\x25\xcd\xd5\x01\x00\x00"

func queryQuery_pair_info_by_addrsCdcBytes() ([]byte, error) {
	return bindataRead(
		_queryQuery_pair_info_by_addrsCdc,
		"query/query_pair_info_by_addrs.cdc",
	)
}

func queryQuery_pair_info_by_addrsCdc() (*asset, error) {
	bytes, err := queryQuery_pair_info_by_addrsCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "query/query_pair_info_by_addrs.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0xc9, 0xf5, 0xca, 0xec, 0xc, 0x2a, 0x36, 0xb4, 0x28, 0x41, 0xb4, 0x24, 0x57, 0x77, 0x56, 0x14, 0xbf, 0x3d, 0xe5, 0xe9, 0xa4, 0xe5, 0x3e, 0xe8, 0xc1, 0x64, 0xd6, 0x1e, 0xc5, 0x2, 0xbf, 0x61}}
	return a, nil
}

var _queryQuery_token_namesCdc = "\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\xff\x8c\x54\x4d\x6f\xda\x40\x10\xbd\xfb\x57\xbc\x72\x40\xb8\xa1\x04\x87\x46\x50\x2b\x3e\xe4\x52\x29\x52\xd5\x4b\x5b\x09\x89\x72\x30\xf6\xd8\x2c\x98\x35\x5d\xaf\x5b\x45\x09\xff\xbd\x9a\x35\xd8\xf8\x83\x84\x3d\xac\xbc\xf3\xf1\xe6\xed\x9b\x59\x5b\xfb\x7c\x85\x28\x97\xd8\xf9\x42\x0e\xfe\xe4\xa4\x9e\x1f\xc3\x50\xb9\xe0\x9d\xb2\xcc\x76\xb1\xf8\xa1\x95\x90\xf1\x12\x2f\x16\x00\x24\xa4\x21\xfd\x1d\x65\xf0\x10\x93\x7e\x0c\x82\x34\x97\xba\x4a\xb5\x47\x41\x2a\xb5\xf2\x03\x9d\x8d\x4c\x9c\x55\xa6\xe9\x74\x4b\xf2\x3b\xdb\xce\x50\x3d\x2c\x96\x55\x48\x90\x26\xa9\x74\xf1\xeb\x49\xea\x19\x3c\xdc\xcf\x4a\x4f\xb6\xf7\x03\xaa\x3c\x93\xbb\xd2\xb3\x52\x35\x8f\x73\x37\x31\xae\xdb\x5b\xe4\x3a\x9a\x21\x48\x43\x42\x1a\xa1\xf7\x35\x97\xb1\x58\x25\xf4\x93\x69\xf4\xea\xac\x9e\x64\x48\x52\x8b\x48\x90\x72\xb1\x30\x50\x86\xda\x74\x3c\x84\xe3\x4c\x79\xe3\xaf\xf1\x84\xb7\xfb\x21\xbe\xcc\xf8\xc3\x6c\xce\x10\xb3\xcf\x1c\xe0\xf0\x69\x7a\x34\x39\xce\x78\x89\xb2\x86\xa8\xe0\xbf\x91\x8c\xf5\x1a\x5e\xab\xee\x28\x31\x9e\x42\x8b\x28\x55\x46\x65\x08\x79\x54\xbb\x50\xbf\xd2\x29\xa4\x2b\x1a\x10\x93\x1e\x70\xba\x6b\x40\xec\x0f\x23\xce\x6b\x01\x95\x94\xf8\x70\xa2\xc1\x01\x56\x19\xfa\xd7\x57\x10\x99\x51\x0e\x1e\x22\x3f\xc9\xa8\xe1\x64\xe5\x27\xa5\xe9\xdf\x5a\x24\x34\x10\x78\x38\x2b\xf0\xc9\xb1\xcf\x6e\x71\x6c\x51\x2a\x93\x67\x04\x6b\x0a\xb6\xd0\x6b\xc2\x8a\x62\x29\x85\x8c\xb9\x61\x7c\xe6\xec\x21\x34\xa9\x9d\x90\xbe\x26\xf8\x1a\xbd\x97\x5e\x0d\x44\x44\x26\x6a\x21\x96\xf0\xbc\x62\x18\x1a\x65\x78\xad\x14\xf9\xdb\x9a\xf5\xd0\xa4\x92\x91\xaf\x82\xb5\x01\x73\xd1\xe3\x87\x71\x12\x12\xf3\xf9\xdc\x1d\xfc\xce\x3e\xda\xb5\x19\xc2\x9b\x4c\xcc\x28\xa3\xdf\x3f\xda\x6e\x1c\x63\x35\x63\xdc\xc1\x8f\xf5\x13\xb8\x81\xd3\xf2\x14\x52\x9e\x01\x17\x10\xfd\x3e\xea\xf2\x36\xc5\x7d\x1f\xf9\xd0\xb2\x70\x27\x37\xf0\x30\xbe\xc0\x62\x83\x87\x8e\x59\xbe\x9e\x4a\x4d\xa0\xe6\x03\x58\x6c\x96\x17\xf2\xde\xbe\xc6\x69\x31\xf1\xcd\xc5\x88\x03\x28\xc9\xba\x94\x3f\xad\xf6\x84\x94\xa9\x57\x28\x27\x22\xae\xef\x75\xab\x73\xea\x9e\xe7\x15\xbd\x7b\x7d\x45\x69\x31\x03\x7b\x51\xb0\xf2\xc9\x69\x95\x53\x67\x48\x37\xed\x83\x65\x5d\x75\xf9\x6e\x55\xeb\xd7\xb3\xda\x66\x11\x95\xd4\xea\x98\xd5\x2f\x7e\xe4\xef\xf7\x24\x43\xf3\xfb\xb1\x1b\x10\xc5\x9e\xa4\xf1\xa0\x8a\x2f\x62\x14\xe9\x5c\xc9\x33\x18\xeb\xf0\x3f\x00\x00\xff\xff\x05\xca\xb4\x7f\xa3\x06\x00\x00"

func queryQuery_token_namesCdcBytes() ([]byte, error) {
	return bindataRead(
		_queryQuery_token_namesCdc,
		"query/query_token_names.cdc",
	)
}

func queryQuery_token_namesCdc() (*asset, error) {
	bytes, err := queryQuery_token_namesCdcBytes()
	if err != nil {
		return nil, err
	}

	info := bindataFileInfo{name: "query/query_token_names.cdc", size: 0, mode: os.FileMode(0), modTime: time.Unix(0, 0)}
	a := &asset{bytes: bytes, info: info, digest: [32]uint8{0x9, 0xab, 0x91, 0x37, 0xa5, 0x98, 0x1, 0xc8, 0x57, 0xdb, 0xe, 0x68, 0xf5, 0xeb, 0x14, 0xea, 0x24, 0xa3, 0xc8, 0x64, 0xd6, 0xf2, 0xb0, 0xec, 0x94, 0xea, 0xd7, 0x31, 0x6, 0xc0, 0x86, 0xc3}}
	return a, nil
}

// Asset loads and returns the asset for the given name.
// It returns an error if the asset could not be found or
// could not be loaded.
func Asset(name string) ([]byte, error) {
	canonicalName := strings.Replace(name, "\\", "/", -1)
	if f, ok := _bindata[canonicalName]; ok {
		a, err := f()
		if err != nil {
			return nil, fmt.Errorf("Asset %s can't read by error: %v", name, err)
		}
		return a.bytes, nil
	}
	return nil, fmt.Errorf("Asset %s not found", name)
}

// AssetString returns the asset contents as a string (instead of a []byte).
func AssetString(name string) (string, error) {
	data, err := Asset(name)
	return string(data), err
}

// MustAsset is like Asset but panics when Asset would return an error.
// It simplifies safe initialization of global variables.
func MustAsset(name string) []byte {
	a, err := Asset(name)
	if err != nil {
		panic("asset: Asset(" + name + "): " + err.Error())
	}

	return a
}

// MustAssetString is like AssetString but panics when Asset would return an
// error. It simplifies safe initialization of global variables.
func MustAssetString(name string) string {
	return string(MustAsset(name))
}

// AssetInfo loads and returns the asset info for the given name.
// It returns an error if the asset could not be found or
// could not be loaded.
func AssetInfo(name string) (os.FileInfo, error) {
	canonicalName := strings.Replace(name, "\\", "/", -1)
	if f, ok := _bindata[canonicalName]; ok {
		a, err := f()
		if err != nil {
			return nil, fmt.Errorf("AssetInfo %s can't read by error: %v", name, err)
		}
		return a.info, nil
	}
	return nil, fmt.Errorf("AssetInfo %s not found", name)
}

// AssetDigest returns the digest of the file with the given name. It returns an
// error if the asset could not be found or the digest could not be loaded.
func AssetDigest(name string) ([sha256.Size]byte, error) {
	canonicalName := strings.Replace(name, "\\", "/", -1)
	if f, ok := _bindata[canonicalName]; ok {
		a, err := f()
		if err != nil {
			return [sha256.Size]byte{}, fmt.Errorf("AssetDigest %s can't read by error: %v", name, err)
		}
		return a.digest, nil
	}
	return [sha256.Size]byte{}, fmt.Errorf("AssetDigest %s not found", name)
}

// Digests returns a map of all known files and their checksums.
func Digests() (map[string][sha256.Size]byte, error) {
	mp := make(map[string][sha256.Size]byte, len(_bindata))
	for name := range _bindata {
		a, err := _bindata[name]()
		if err != nil {
			return nil, err
		}
		mp[name] = a.digest
	}
	return mp, nil
}

// AssetNames returns the names of the assets.
func AssetNames() []string {
	names := make([]string, 0, len(_bindata))
	for name := range _bindata {
		names = append(names, name)
	}
	return names
}

// _bindata is a table, holding each asset generator, mapped to its name.
var _bindata = map[string]func() (*asset, error){
	"query/query_pair_addr.cdc":          queryQuery_pair_addrCdc,
	"query/query_pair_array_addr.cdc":    queryQuery_pair_array_addrCdc,
	"query/query_pair_array_info.cdc":    queryQuery_pair_array_infoCdc,
	"query/query_pair_balance.cdc":       queryQuery_pair_balanceCdc,
	"query/query_pair_info_by_addrs.cdc": queryQuery_pair_info_by_addrsCdc,
	"query/query_token_names.cdc":        queryQuery_token_namesCdc,
}

// AssetDebug is true if the assets were built with the debug flag enabled.
const AssetDebug = false

// AssetDir returns the file names below a certain
// directory embedded in the file by go-bindata.
// For example if you run go-bindata on data/... and data contains the
// following hierarchy:
//     data/
//       foo.txt
//       img/
//         a.png
//         b.png
// then AssetDir("data") would return []string{"foo.txt", "img"},
// AssetDir("data/img") would return []string{"a.png", "b.png"},
// AssetDir("foo.txt") and AssetDir("notexist") would return an error, and
// AssetDir("") will return []string{"data"}.
func AssetDir(name string) ([]string, error) {
	node := _bintree
	if len(name) != 0 {
		canonicalName := strings.Replace(name, "\\", "/", -1)
		pathList := strings.Split(canonicalName, "/")
		for _, p := range pathList {
			node = node.Children[p]
			if node == nil {
				return nil, fmt.Errorf("Asset %s not found", name)
			}
		}
	}
	if node.Func != nil {
		return nil, fmt.Errorf("Asset %s not found", name)
	}
	rv := make([]string, 0, len(node.Children))
	for childName := range node.Children {
		rv = append(rv, childName)
	}
	return rv, nil
}

type bintree struct {
	Func     func() (*asset, error)
	Children map[string]*bintree
}

var _bintree = &bintree{nil, map[string]*bintree{
	"query": {nil, map[string]*bintree{
		"query_pair_addr.cdc": {queryQuery_pair_addrCdc, map[string]*bintree{}},
		"query_pair_array_addr.cdc": {queryQuery_pair_array_addrCdc, map[string]*bintree{}},
		"query_pair_array_info.cdc": {queryQuery_pair_array_infoCdc, map[string]*bintree{}},
		"query_pair_balance.cdc": {queryQuery_pair_balanceCdc, map[string]*bintree{}},
		"query_pair_info_by_addrs.cdc": {queryQuery_pair_info_by_addrsCdc, map[string]*bintree{}},
		"query_token_names.cdc": {queryQuery_token_namesCdc, map[string]*bintree{}},
	}},
}}

// RestoreAsset restores an asset under the given directory.
func RestoreAsset(dir, name string) error {
	data, err := Asset(name)
	if err != nil {
		return err
	}
	info, err := AssetInfo(name)
	if err != nil {
		return err
	}
	err = os.MkdirAll(_filePath(dir, filepath.Dir(name)), os.FileMode(0755))
	if err != nil {
		return err
	}
	err = ioutil.WriteFile(_filePath(dir, name), data, info.Mode())
	if err != nil {
		return err
	}
	return os.Chtimes(_filePath(dir, name), info.ModTime(), info.ModTime())
}

// RestoreAssets restores an asset under the given directory recursively.
func RestoreAssets(dir, name string) error {
	children, err := AssetDir(name)
	// File
	if err != nil {
		return RestoreAsset(dir, name)
	}
	// Dir
	for _, child := range children {
		err = RestoreAssets(dir, filepath.Join(name, child))
		if err != nil {
			return err
		}
	}
	return nil
}

func _filePath(dir, name string) string {
	canonicalName := strings.Replace(name, "\\", "/", -1)
	return filepath.Join(append([]string{dir}, strings.Split(canonicalName, "/")...)...)
}