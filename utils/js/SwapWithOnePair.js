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

const tokenInKey = PROCESS.argv[3]
const tokenOutKey = PROCESS.argv[4]
const tokenInAmount = PROCESS.argv[5]
var tokenInVaultPath = PROCESS.argv[6]
var tokenOutVaultPath = PROCESS.argv[7]
var tokenOutReceiverPath = PROCESS.argv[8]
var tokenOutBalancePath = PROCESS.argv[9]

//
console.log('js swap', tokenInKey, tokenOutKey)

const keyConfig = {
    account: "0xf8d6e0586b0a20c7",
    keyIndex: 0,
    privateKey: "da193159f79102065ceb0c7cfef38910525e10a6a0c8c5109f645cb47f792a47",
    SequenceNumber: 0,
    signature: "p256"
};

async function SwapWithOnePair() {

    var CODE = DeployConfig.Codes.Transactions.SwapWithOnePair
    
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
            FCL.arg(tokenInKey, T.String),
            FCL.arg(tokenOutKey, T.String),
            FCL.arg(tokenInAmount, T.UFix64),
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
    SwapWithOnePair()
})()