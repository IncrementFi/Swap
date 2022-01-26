var startTime = Date.now()

// Router API
const CORE = require("./router/core")
const CADENCE = require("./router/cadence");

// Flow API
const {QueryPairArrayInfo} = require("./js/QueryPairArrayInfo")
const {QueryTokenNames} = require("./js/QueryTokenNames")
const {QueryPairInfoByAddrs} = require("./js/QueryPairInfoByAddrs")
const {AddLiquidity} = require("./js/AddLiquidity")
const {CreatePair} = require("./js/CreatePair")
const {SwapWithPaths} = require("./js/SwapWithPaths")


// Config
const routerConfig = require("./router/router.config.json")
const network = "emulator";

(async ()=> {
    // 0. mint所有相关的token: [Codes.Scripts.MintAllTokens]

    // 1. 获取链上PairArr数据 （临时） [Transaction]
    var pairInfos = await QueryPairArrayInfo(0, 0, network)
    
    // 2. 创建tokenMap  [Router]
    var res = CADENCE.RecreateTokenMap(pairInfos)
    // Return
    var tokenMap = res[0]
    var pairAddrDict = res[1]

    // 3. 用户输入address查询token  [Script]
    var tokenNames = await QueryTokenNames("0x01cf0e2f2f715450", network)

    // 4. 当用户选取两个token  [UI]
    var tokenInKey = "A.f8d6e0586b0a20c7.USDT"
    var tokenOutKey = "A.f8d6e0586b0a20c7.USDC"

    // 5. path finding  [Router]
    var pathArr = CORE.PathFinding(tokenInKey, tokenOutKey, tokenMap, routerConfig.CenterTokens[network])
    
    // 6. 获取需要关注的pair地址列表  [Router]
    var innerPairAddrArr = CORE.GetInnerPairAddrs(pathArr, pairAddrDict)

    // 7. 用户输入tokenIn的数量： 100  [UI]
    var tokenInAmount = 100.0
    var tokenOutAmount = 0.0 // 只有一个大于0

    // 8. 估算tokenOutAmount  [Router]
    var paths = []
    var amountInputSplit = []
    var tokenMapEnv = {}
    var res = CORE.EvaSwap(pathArr, tokenInAmount, tokenOutAmount, tokenMap, tokenMapEnv)
    if (tokenInAmount > 0.0) {
        // Return
        tokenOutAmount = res[0]
        paths = res[1]
        amountInputSplit = res[2]
    }

    // 9. 定期拉去数据，重新计算
    {
        // 9.1 定期获取指定pair数组的info  [Script]
        var innerPairInfoArr = await QueryPairInfoByAddrs(innerPairAddrArr, network)

        // 9.2 更新tokenMap  [Router]
        CADENCE.UpdateTokenMap(innerPairInfoArr, tokenMap)
        
        // 9.3 重新计算， 同 [8]
    }

    // 10. Swap  [Transaction]
    await SwapWithPaths(paths, amountInputSplit, "如果在tokenList里传空path即可", "", "", "", network)

    // 11. Add Liquidity
    {
        // 11.1 用户选择了流动性的两个token
        var token0Key = "A.f8d6e0586b0a20c7.USDT"
        var token1Key = "A.f8d6e0586b0a20c7.USDC"

        // 11.2 用户数据了amount
        var token0Amount = 100.0
        var token1Amount = 101.0

        // 11.3 估算需要的另外一个数量（如果是首次添加流动性，则两个都需要输入）
        // TODO

        // 11.4 [Transaction]
        await AddLiquidity(token0Key, token1Key, token0Amount, token1Amount, "如果在tokenList里传空path即可", "vaultOutPath", network)
    }

    // 12. Create Pair
    {
        // 用户选择了流动性的两个token
        var token0Key = "A.f8d6e0586b0a20c7.USDT"
        var token1Key = "A.01cf0e2f2f715450.TestTokenA"

        // 获取该pair当前info，如果不存在则可以创建
        // TODO

        // 创建
        // await CreatePair(token0Key, token1Key, network)

    }


    
    console.log( Date.now() - startTime, 'ms' )
})();



