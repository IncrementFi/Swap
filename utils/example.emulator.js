var startTime = Date.now()

// Router API
const ROUTER = require("./router/router");

// Flow API
const {QueryAllPairInfos} = require("./js/QueryAllPairInfos")
const {QueryTokenNames} = require("./js/QueryTokenNames")
const {QueryPairInfoByAddrs} = require("./js/QueryPairInfoByAddrs")
const {AddLiquidity} = require("./js/AddLiquidity")
const {CreatePair} = require("./js/CreatePair")
const {SwapExactTokensForTokens} = require("./js/SwapExactTokensForTokens")
const {SwapTokensForExactTokens} = require("./js/SwapTokensForExactTokens")

const {QueryPairInfoByTokenKey} = require("./js/QueryPairInfoByTokenKey")
const {QueryTimestamp} = require("./js/QueryTimestamp")



// Config
const network = "emulator";
const DeployConfig = require( './js/' + "swap.deploy.config." + network + ".json" );
const CenterTokens = DeployConfig.Router.CenterTokens;

(async ()=> {
    // 0. mint所有相关的token: [Codes.Scripts.MintAllTokens]


    // 1. 前端需要自己实现一个script获取该接口数据，该数据是链上所有Pair的Arr （临时使用） 如果pair数量几万，后面需要部分获取、或者分优先级。
    // 前端可以每隔2分钟重新获取一次
    // Input:
    //  @from: 获取pair数组的起始index
    //  @to: 获取pair数组的终止index，0代表获取所有
    // Output:
    //  返回pairInfo的数组，pairInfo里包含：[token0Key, token1Key, token0Balance(UFix64), token1Balance, pairAddr]
    var pairInfos = await QueryAllPairInfos(network)
    
    // 2. 获取到pairInfos之后，初始化router
    // Input: 之前从链上获取到的[pairInfo]数据
    ROUTER.InitRouter(pairInfos)

    // 3. 当用户在查询框输入address后，发起该script，查询tokens
    // Output: ["FlowToken", "FUSD"]
    var tokenNames = await QueryTokenNames("0x01cf0e2f2f715450", network)

    // 4. 当用户选取两个tokenKey
    var tokenInKey = "A.f8d6e0586b0a20c7.USDT"
    var tokenOutKey = "A.f8d6e0586b0a20c7.USDC"

    // 5. 初始化寻路，每次用户修改输入的tokenKey之后需要重新初始化
    // Input:
    //  @tokenInKey tokenOutKey
    //  @centerTokens 连通图的中心Token配置
    // Output:
    //  需要定时更新的pair地址列表
    //  [pair1Addr, pair2Addr, pair3Addr]
    var innerPairAddrs = ROUTER.SelectStartEndToken(tokenInKey, tokenOutKey, CenterTokens)

    // 6. 定期去获取合约pair数据
    
        // 7.1 前端每5秒，发送该script，获取指定pair地址的info  [Script]
        var innerPairInfos = await QueryPairInfoByAddrs(innerPairAddrs, network)

        // 7.2 获取到一些pairInfos后，更新router
        ROUTER.UpdateRouter(innerPairInfos)
        
        // 7.3 重新计算 EvaSwap()

        // 7.4 获得链上时间戳，用于计算交易过期时间
        // 返回 UFix64 单位：秒，如果用户设置了交易超时为60秒，则直接+60作为 swap的输入参数
        // 接口: Code.QueryTimestamp()
        var curTimestamp = await QueryTimestamp(network)
        
    

    // 8. 当用户输入tokenIn的数量  [UI]
    var tokenInAmount = 0.0
    var tokenOutAmount = 1000.0 // 只有一个大于0


    var paths = []
    var amountInputSplit = []
    var tokenMapEnv = {}
    // 9. 根据用户的输入tokenInAmount or tokneOutAmount，对交易结果做出估算
    // 
    // Input:
    //  @tokenInAmount tokneOutAmount 其中一个大于零
    // Output: resJson
    var resJson = ROUTER.EvaSwap(tokenInKey, tokenOutKey, tokenInAmount, tokenOutAmount)
    /*
        resJson = {
            "tokenInKey": "A.1654653399040a61.FlowToken",
            "tokenOutKey": "A.1654653399040a61.FUSD",
            "tokenInAmount": 50,
            "tokenOutAmount": 90,
            "priceImpact": "0.1",
            "routes": [
                {
                    "routeAmountIn": 20,  // 40%的输入走这条路径
                    "routeAmountOut": 40,  // 该路径能兑换的结果
                    "route": [tokenInKey, tokenKey_a, tokenOutKey]
                },
                {
                    "routeAmountIn": 30,
                    "routeAmountOut": 50,
                    "route": [tokenInKey, tokenKey_b, tokenKey_c, tokenOutKey]
                },
                ...
            ]
        }
    */
    

    // 10. 前端需要发送tx完成swap交易
    
    // 10.1 用户的滑点设置
    var slippageRate = 0.1  // 10%

    // 10.2 用户的交易超时设置
    var expireDuration = 3000  // 120s
    
    // Input:
    //  @tokenKeyPathFlat: EvaSwap返回路径的一维数组平坦化 [tokenInKey, token1, tokenOutKey, tokenInKey, token2, tokenOutKey]
    //  @amountInSplit: 每条拆分路径输入价格的数组 [20, 30]
    //  @vaultInPath tokenInKey的vaultPath，在tokenlist里的token可以从配置里取
    //  @vaultOutPath等三个是 tokenOutKey的相关path
    var tokenKeyPathFlat = []
    var amountInSplit = []
    var amountOutSplit = []
    for (var i = 0; i < resJson.routes.length; ++i) {
        var routeJson = resJson.routes[i]
        tokenKeyPathFlat = tokenKeyPathFlat.concat(routeJson.route)
        amountInSplit.push(parseFloat(routeJson.routeAmountIn).toFixed(8))
        amountOutSplit.push(parseFloat(routeJson.routeAmountOut).toFixed(8))
    }
    // SwapExactTokensForTokens
    if (tokenInAmount > 0.0 && tokenOutAmount == 0.0) {
        var estimateOut = resJson.tokenOutAmount
        var amountOutMin = estimateOut * (1.0 - slippageRate)
        await SwapExactTokensForTokens(
            tokenKeyPathFlat,
            amountInSplit,
            amountOutMin,
            parseFloat(curTimestamp) + expireDuration,
            "vaultInPath", "vaultOutPath", "receiverOutPath", "balanceOutPath",
            network
        )
    } else if (tokenInAmount == 0.0 && tokenOutAmount > 0.0) {
        var estimateIn = resJson.tokenInAmount
        var amountInMax = estimateIn / (1.0 - slippageRate)

        await SwapTokensForExactTokens(
            tokenKeyPathFlat,
            amountOutSplit,
            amountInMax,
            parseFloat(curTimestamp) + expireDuration,
            "vaultInPath", "vaultOutPath", "receiverOutPath", "balanceOutPath",
            network
        )
    }


    // 11. Create Pair
    {
        // 用户选择了流动性的两个token
        var token0Key = "A.f8d6e0586b0a20c7.USDT"
        var token1Key = "A.f8d6e0586b0a20c7.USDC"

        // 获取该pair当前info，如果不存在则可以创建
        var pairInfo = await QueryPairInfoByTokenKey(token0Key, token1Key, network)
        if (pairInfo == null) {
            // pair不存在
        } else {
            /*
            pairInfo = [
                    'A.f8d6e0586b0a20c7.wFlow',  // 0: tokenInKey
                    'A.f8d6e0586b0a20c7.USDC',   // 1: tokenOutKey
                    '4000.00000000',             // 2: tokenInBalance
                    '10000.00000000',            // 3: tokenOutBalance
                    '0x120e725050340cab'         // 4: pairAddr
                ]
            */
        }

        // 创建pair [Transaction]
        // await CreatePair(token0Key, token1Key, network)

    }

    // 12. Add Liquidity
    {
        // 11.1 用户选择了流动性的两个token
        var token0Key = "A.f8d6e0586b0a20c7.USDT"
        var token1Key = "A.f8d6e0586b0a20c7.USDC"

        // 11.2 用户数据了amount
        var token0Amount = 100.0
        var token1Amount = 101.0

        // 11.3 估算需要的另外一个数量（如果是首次添加流动性，则两个都需要输入）
        // 通过 QueryPairInfoByTokenKey【同Create Pair】 查询这两个token的balance
        var token0Balance = 10000.0
        var token1Balance = 11000.0
        // 当用户输入了 token0Amount = 100
        // 则等比例显示 token1Amount = 110

        // 11.5 TODO 滑点

        // 11.4 [Transaction]
        await AddLiquidity(token0Key, token1Key, token0Amount, token1Amount, "vault0VaultPath", "vault1VaultPath", network)
    }

    

    console.log( Date.now() - startTime, 'ms' )
})();


