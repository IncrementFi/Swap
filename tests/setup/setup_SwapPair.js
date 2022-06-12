import fs from "fs";
import path from "path";

import { deployContractByName, getAccountAddress, executeScript, mintFlow, sendTransaction, getTemplate, getScriptCode } from "flow-js-testing"
import {
    getSwapConfigDeployerAddress,
    getSwapFactoryDeployerAddress,
    getSwapPairTemplateDeployerAddress,
    getTestTokenDeployerAddress,
    toUFix64,
    queryTimestamp
} from "./setup_Common"
import {
    getSwapFactoryAddress,
} from "./setup_Deployment"
import {
    getTokenKeyByName,
    getTokenPathPrefixByName
} from "./setup_Tokens"
import {
    queryPairInfoByTokenName
} from "./setup_SwapFactory"

/**
 * Add Liquidity
 * @returns {Promise<*>}
 */
export const addLiquidity = async(
    userAddr,
    tokenName0,
    tokenName1,
    tokenIn0,
    tokenIn1,
    slippage,
    duration
) => {
    
    let tokenKey0 = await getTokenKeyByName(tokenName0)
    let tokenKey1 = await getTokenKeyByName(tokenName1)

    let curTimestamp = (await queryTimestamp())[0]

    let tokenInMin0 = tokenIn0 * (1-slippage)
    let tokenInMin1 = tokenIn1 * (1-slippage)

    let tokenPathPrefix0 = await getTokenPathPrefixByName(tokenName0)
    let tokenPathPrefix1 = await getTokenPathPrefixByName(tokenName1)

    // StoragePath is not supported in Jest
    // have to replace the storage params
    const cadenceRootPath = "../../src";
    const basePath = path.resolve(__dirname, cadenceRootPath);
    var code = fs.readFileSync(basePath+"/transactions/user/add_liquidity.cdc", "utf-8");

    code = code.replace("token0VaultPath: StoragePath,", "")
    code = code.replace("token1VaultPath: StoragePath,", "")
    code = code.replaceAll("token0VaultPath", "/storage/"+tokenPathPrefix0+"Vault")
    code = code.replaceAll("token1VaultPath", "/storage/"+tokenPathPrefix1+"Vault")

    //const name = "user/add_liquidity";
    const signers = [userAddr]
    const args = [
        tokenKey0,
        tokenKey1,
        tokenIn0,
        tokenIn1,
        tokenInMin0,
        tokenInMin1,
        parseFloat(curTimestamp) + parseFloat(duration)
    ]
    return sendTransaction({ code, args, signers })
}

/**
 * Remove Liquidity
 * @returns {Promise<*>}
 */
 export const removeLiquidity = async(
    userAddr,
    tokenName0,
    tokenName1,
    lpTokenToRemove,
    slippage,
    duration
) => {
    const [pairInfo, err] = await queryPairInfoByTokenName(tokenName0, tokenName1)
    let totalLptoken = pairInfo[5]

    let tokenKey0 = await getTokenKeyByName(tokenName0)
    let tokenKey1 = await getTokenKeyByName(tokenName1)

    let curTimestamp = (await queryTimestamp())[0]

    let tokenOutMin0 = lpTokenToRemove / totalLptoken * totalLptoken[2] * (1-slippage)
    let tokenOutMin1 = lpTokenToRemove / totalLptoken * totalLptoken[3] * (1-slippage)

    let tokenPathPrefix0 = await getTokenPathPrefixByName(tokenName0)
    let tokenPathPrefix1 = await getTokenPathPrefixByName(tokenName1)

    // StoragePath is not supported in Jest
    // have to replace the storage params
    const cadenceRootPath = "../../src";
    const basePath = path.resolve(__dirname, cadenceRootPath);
    var code = fs.readFileSync(basePath+"/transactions/user/remove_liquidity.cdc", "utf-8");

    code = code.replace("token0VaultPath: StoragePath,", "")
    code = code.replace("token1VaultPath: StoragePath,", "")
    code = code.replaceAll("token0VaultPath", "/storage/"+tokenPathPrefix0+"Vault")
    code = code.replaceAll("token1VaultPath", "/storage/"+tokenPathPrefix1+"Vault")

    //const name = "user/add_liquidity";
    const signers = [userAddr]
    const args = [
        tokenKey0,
        tokenKey1,
        lpTokenToRemove,
        tokenOutMin0,
        tokenOutMin1,
        parseFloat(curTimestamp) + parseFloat(duration)
    ]
    return sendTransaction({ code, args, signers })
}

export const getPriceCumulativeLast = async (tokenName0, tokenName1) => {
    const [pairInfo, err] = await queryPairInfoByTokenName(tokenName0, tokenName1)
    console.log(pairInfo)
    const pairAddr = pairInfo[4]
    //import SwapPair from ${pairAddr}
    const code = `
        import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
        import SwapConfig from "../../contracts/SwapConfig.cdc"

        pub fun main(pairAddr: Address): [UInt256] {
            let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
            
            return [
                pairPublicRef.getPrice0CumulativeLastScaled(),
                pairPublicRef.getPrice1CumulativeLastScaled()
            ]
        }
    `;
    const args = [pairAddr];
    let res = await executeScript({ code, args });
    return res
}

export const getTwapInfo = async (tokenName0, tokenName1) => {
    const [pairInfo, err] = await queryPairInfoByTokenName(tokenName0, tokenName1)
    const pairAddr = pairInfo[4]
    //import SwapPair from ${pairAddr}
    const code = `
        import SwapInterfaces from "../../contracts/SwapInterfaces.cdc"
        import SwapConfig from "../../contracts/SwapConfig.cdc"

        pub fun main(pairAddr: Address): [AnyStruct] {
            let pairPublicRef = getAccount(pairAddr).getCapability<&{SwapInterfaces.PairPublic}>(SwapConfig.PairPublicPath).borrow()!
            
            let curTimestamp = getCurrentBlock().timestamp
            return [
                pairPublicRef.getPrice0CumulativeLastScaled(),
                pairPublicRef.getPrice1CumulativeLastScaled(),
                curTimestamp
            ]
        }
    `;
    const args = [pairAddr];
    let res = await executeScript({ code, args });
    return res
}