const FCL = require('@onflow/fcl');
const T = require('@onflow/types');
const FLOW = require('./Flow')

const path = require('path');
const dotenv = require('dotenv')
dotenv.config({path:path.resolve(__dirname, '../.env')})
const PROCESS = require('process');

// Input Args
const network = PROCESS.argv[2]

const tokenInAmount = PROCESS.argv[3]
var tokenInVaultPath = PROCESS.argv[4]
var tokenOutVaultPath = PROCESS.argv[5]
var tokenOutReceiverPath = PROCESS.argv[6]
var tokenOutBalancePath = PROCESS.argv[7]

const tokenInKey = PROCESS.argv[8]
var tokenOutKey = ""
var tokenKeyPath = [tokenInKey]

for (let i = 9; i < 999; ++i) {
    var tokenKey = PROCESS.argv[i]
    if (tokenKey == null) {
        break
    }
    tokenOutKey = tokenKey
    tokenKeyPath.push(tokenKey)
}


//
const keyConfig = {
    account: "0xf8d6e0586b0a20c7",
    keyIndex: 0,
    privateKey: "da193159f79102065ceb0c7cfef38910525e10a6a0c8c5109f645cb47f792a47",
    SequenceNumber: 0,
    signature: "p256"
};

/*
    [
        [A, 1, 2, B],
        [A, 1, 4, B],
        [A, 2, 4, B]
    ]

    [A, 1, 2, B, A, 1, 4, B, A, 2, 4, B]
*/

async function SwapWithPaths(pathFlat, amountInSplit, tokenInVaultPath, tokenOutVaultPath, tokenOutReceiverPath, tokenOutBalancePath, network) {
    const DeployConfig = require('./' + "swap.deploy.config." + network + ".json")
    const TokenListAll = require('./' + "tokenlist.all." + network + ".json")

    var CODE = DeployConfig.Codes.Transactions.SwapWithPaths
    
    var pathLen = pathFlat.length
    var tokenInKey = pathFlat[0]
    var tokenOutKey = pathFlat[pathLen-1]
    
    // 替换合约代码
    const tokenOutName = tokenOutKey.split('.')[2]
    const tokenOutAddr = "0x"+tokenOutKey.split('.')[1]
    CODE = CODE.replaceAll('Token1Name', tokenOutName)
    CODE = CODE.replaceAll('Token1Addr', tokenOutAddr)
    
    // 输入的float -> string
    var amountInSplitString = []
    for (let i = 0; i < amountInSplit.length; ++i) {
        amountInSplitString.push( parseFloat(amountInSplit[i]).toFixed(8) )
    }

    // 如果token在tokenList里从配置里读取4个path
    if (tokenInKey in TokenListAll) tokenInVaultPath = TokenListAll[tokenInKey].vaultPath;
    if (tokenOutKey in TokenListAll) {
        tokenOutVaultPath = TokenListAll[tokenOutKey].vaultPath;
        tokenOutReceiverPath = TokenListAll[tokenOutKey].vaultBalancePath;
        tokenOutBalancePath = TokenListAll[tokenOutKey].vaultReceiverPath;
    }

    const vaultInPath = { "domain": "storage", "identifier": tokenInVaultPath };
    const vaultOutPath = { "domain": "storage", "identifier": tokenOutVaultPath };
    const receiverOutPath = { "domain": "public", "identifier": tokenOutReceiverPath };
    const balanceOutPath = { "domain": "public", "identifier": tokenOutBalancePath };

    FCL.config().put("accessNode.api", FLOW.rpc.emulator.accessNode)
    const myAuth = FLOW.authFunc(keyConfig);
    const response = await FCL.send([
        FCL.transaction`
        ${CODE}
        `,
        FCL.args([
            FCL.arg(pathFlat, T.Array(T.String)),
            FCL.arg(amountInSplitString, T.Array(T.UFix64)),
            FCL.arg(vaultInPath, T.Path),
            FCL.arg(vaultOutPath, T.Path),
            FCL.arg(receiverOutPath, T.Path),
            FCL.arg(balanceOutPath, T.Path),
        ]),
        FCL.proposer(myAuth),
        FCL.authorizations([myAuth]),
        FCL.payer(myAuth),
        FCL.limit(9999),
    ]);
    return await FCL.tx(response).onceSealed();
}


(async ()=> {
    if(PROCESS.argv[2] != undefined) {
        //SwapWithPaths(paths, amountInSplit, tokenInVaultPath, tokenOutVaultPath, tokenOutReceiverPath, tokenOutBalancePath, network)
    }
})()

module.exports = {
    SwapWithPaths
}