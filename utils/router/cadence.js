const CORE = require("./core")

function RecreateTokenMap(pairInfoArr) {
    var tokenMap = {}
    var pairAddrDict = {}
    for (let i = 0; i < pairInfoArr.length; ++i) {
        var info = pairInfoArr[i]
        var token0Key = info[0]
        var token1Key = info[1]
        var token0Balance = info[2]
        var token1Balance = info[3]
        var pairAddr = info[4]

        CORE.addLiquidity(token0Key, token1Key, token0Balance, token1Balance, tokenMap)

        if (!pairAddrDict.hasOwnProperty(token0Key)) pairAddrDict[token0Key] = {}
        if (!pairAddrDict.hasOwnProperty(token1Key)) pairAddrDict[token1Key] = {}
        pairAddrDict[token0Key][token1Key] = pairAddr
        pairAddrDict[token1Key][token0Key] = pairAddr
    }
    return [tokenMap, pairAddrDict]
}

function UpdateTokenMap(pairInfoArr, tokenMap) {
    for (let i = 0; i < pairInfoArr.length; ++i) {
        var info = pairInfoArr[i]
        var token0Key = info[0]
        var token1Key = info[1]
        var token0Balance = info[2]
        var token1Balance = info[3]
        var pairAddr = info[4]

        CORE.setLiquidity(token0Key, token1Key, token0Balance, token1Balance, tokenMap)
    }
    return tokenMap
}

module.exports = {
    RecreateTokenMap,
    UpdateTokenMap
}