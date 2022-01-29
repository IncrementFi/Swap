const FCL = require('@onflow/fcl');
const T = require('@onflow/types');
const FLOW = require('./Flow')

const path = require('path');
const dotenv = require('dotenv')
dotenv.config({path:path.resolve(__dirname, '../.env')})
const PROCESS = require('process');

// Input Args
const network = PROCESS.argv[2]
const DeployConfig = require('./' + "swap.deploy.config." + network + ".json")
const TokenListAll = require('./' + "tokenlist.all." + network + ".json")

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
console.log('swap path', tokenKeyPath)


//
var keyConfig = {
    account: "0xf8d6e0586b0a20c7",
    keyIndex: 0,
    privateKey: "da193159f79102065ceb0c7cfef38910525e10a6a0c8c5109f645cb47f792a47",
    SequenceNumber: 0,
    signature: "p256"
};
if (network == "testnet") {
    keyConfig = {
        account: "0xf8bf9687f8dca813",
        keyIndex: 0,
        privateKey: "3e173ab34b4629ee8e16ee95a6aacb5f088fc95e53ba28ef0f528bf8bcce51ec",
        SequenceNumber: 0
    };
}

async function SwapWithOnePath() {

    var CODE = DeployConfig.Codes.Transactions.SwapWithOnePath
    
    const tokenOutName = tokenOutKey.split('.')[2]
    const tokenOutAddr = "0x"+tokenOutKey.split('.')[1]
    CODE = CODE.replaceAll('Token1Name', tokenOutName)
    CODE = CODE.replaceAll('Token1Addr', tokenOutAddr)

    
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
    FCL.config().put("accessNode.api", FLOW.rpc[network].accessNode)
    const myAuth = FLOW.authFunc(keyConfig);
    const response = await FCL.send([
        FCL.transaction`
        ${CODE}
        `,
        FCL.args([
            FCL.arg(tokenInAmount, T.UFix64),
            FCL.arg(tokenKeyPath, T.Array(T.String)),
            FCL.arg(vaultInPath, T.Path),
            FCL.arg(vaultOutPath, T.Path),
            FCL.arg(receiverOutPath, T.Path),
            FCL.arg(balanceOutPath, T.Path),
        ]),
        FCL.proposer(myAuth),
        FCL.authorizations([myAuth]),
        FCL.payer(myAuth),
        FCL.limit(3000),
    ]);
    return await FCL.tx(response).onceSealed();
}


(async ()=> {
    SwapWithOnePath()
})()