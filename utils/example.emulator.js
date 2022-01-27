var startTime = Date.now()

// Router API
const CORE = require("./router/core");
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


    // 1. 前端需要自己实现一个script获取该接口数据，该数据是链上所有Pair的Arr （临时使用） 如果pair数量几万，后面需要部分获取、或者分优先级。
    // 前端可以每隔2分钟重新获取一次
    // Input:
    //  @from: 获取pair数组的起始index
    //  @to: 获取pair数组的终止index，0代表获取所有
    // Output:
    //  返回pairInfo的数组，pairInfo里包含：[token0Key, token1Key, token0Balance, token1Balance, pairAddr]
    var pairInfos = await QueryPairArrayInfo(0, 0, network)
    
    // 2. 获取到pairInfos之后，需要创建tokenMap数据，该数据封装了pair-pair的连通图，只有core.js使用。
    // Input: 之前从链上获取到的[pairInfo]数据
    // Output:
    //  @tokenMap 记录了pair的连通图，保存下来，定期更新
    //  @pairAddrDict 记录了pair的合约地址
    var res = CADENCE.RecreateTokenMap(pairInfos)
    var tokenMap = res[0]
    var pairAddrDict = res[1]

    // 3. 当用户在查询框输入address后，发起该script，查询tokens
    // Output: ["FlowToken", "FUSD"]
    var tokenNames = await QueryTokenNames("0x01cf0e2f2f715450", network)

    // 4. 当用户选取两个tokenKey  [UI]
    var tokenInKey = "A.f8d6e0586b0a20c7.USDT"
    var tokenOutKey = "A.f8d6e0586b0a20c7.USDC"

    // 5. 计算tokenInKey 和 tokenOutKey之前的备选路径
    // Input:
    //  @tokenInKey tokenOutKey
    //  @tokenMap 之前保存的连通图
    //  @centerTokens 连通图的中心Node配置，会写成配置
    // Output:
    //  @可用的path数组，每个path是tokenKey的array，path: [tokenInKey, token1Key, token2Key, tokenOutKey]
    var pathArr = CORE.PathFinding(tokenInKey, tokenOutKey, tokenMap, routerConfig.CenterTokens[network])
    
    // 6. 根据pathArr获取当中涉及到的所有pair的address，需要定时更新这些pair的info
    // Input:
    //  @pathArr PathFinding的返回结果
    //  @pairAddrDict 
    // Output:
    //  [addr1, addr2, addr3]
    var innerPairAddrArr = CORE.GetInnerPairAddrs(pathArr, pairAddrDict)

    // 7. 定期拉去数据，重新计算
    {
        // 7.1 前端每5秒，发送该script，获取指定pair地址的info  [Script]
        var innerPairInfoArr = await QueryPairInfoByAddrs(innerPairAddrArr, network)

        // 7.2 更新tokenMap  [Router]
        // TODO，这里如果vue不方便做成object，可以返回一个新的tokenMap
        CADENCE.UpdateTokenMap(innerPairInfoArr, tokenMap)
        
        // 7.3 重新计算， 同 [9]
    }

    // 8. 当用户输入tokenIn的数量  [UI]
    var tokenInAmount = 100.0
    var tokenOutAmount = 0.0 // 只有一个大于0

    
    var paths = []
    var amountInputSplit = []
    var tokenMapEnv = {}
    // 9. 根据用户的输入tokenInAmount or tokneOutAmount，结合之前的pathArr，对交易结果做出估算
    // tokenInAmount tokneOutAmount
    // Input:
    //  @pathArr PathFinding返回结果
    // Output:
    //  0: tokenInAmount       如果EvaSwap输入的是tokenOutAmount
    //  1: tokenOutAmount      如果EvaSwap输入的是tokenInAmount
    //  2: 返回的交易path数组，是tokenKey的数组
    //  3: 每条path投入多少交易数量  
    //  比如:         [ [A,1,2,B], [A,1,3,B], [A,3,2,B], ]
    //  如果输入是100  [     20         40        40      ]
    //  4: 价格影响率
    var res = CORE.EvaSwap(pathArr, tokenInAmount, tokenOutAmount, tokenMap, tokenMapEnv)
    if (tokenInAmount > 0.0) {
        // Return
        tokenInAmount = res[0]
        tokenOutAmount = res[1]
        paths = res[2]
        amountInputSplit = res[3]
        // res[4]
    }

    

    // 10. 前端需要发送tx完成swap交易
    // Input:
    //  @paths: EvaSwap返回的二维数组（注意： 合约的接口需要将二维数组平铺到一维数组上，fcl没法传递二维数据）
    //  @amountInputSplit: 输入价格拆分的数组
    // TODO 这里还需要有滑点设置、过期时间等，先简单做。
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



