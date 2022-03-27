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
    getTokenPathPrefixByName,
    getTokenAddrByName
} from "./setup_Tokens"

import {
    queryPairInfoByTokenName
} from "./setup_SwapFactory"

/**
 * SplitSwapExactTokensForTokens
 * @returns {Promise<*>}
 */
export const splitSwapExactTokensForTokens = async(
    userAddr,
    Array_tokenNamePath,
    Array_amountInSplit,
    amountOutMin,
    duration,
) => {
    let tokenInName = Array_tokenNamePath[0]
    let tokenOutName = Array_tokenNamePath[Array_tokenNamePath.length-1]
    let tokenKeyPath = []
    for (let i = 0; i < Array_tokenNamePath.length; ++i) {
        let tokenName = Array_tokenNamePath[i]
        tokenKeyPath.push(await getTokenKeyByName(tokenName))
    }

    let tokenInPathPrefix = await getTokenPathPrefixByName(tokenInName)
    let tokenOutPathPrefix = await getTokenPathPrefixByName(tokenOutName)

    let tokenInVaultPath = "/storage/" + tokenInPathPrefix + "Vault"
    let tokenOutVaultPath = "/storage/" + tokenOutPathPrefix + "Vault"
    let tokenOutReceiverPath = "/public/" + tokenOutPathPrefix + "Receiver"
    let tokenOutBalancePath = "/public/" + tokenOutPathPrefix + "Balance"

    const cadenceRootPath = "../../src";
    const basePath = path.resolve(__dirname, cadenceRootPath);
    var code = fs.readFileSync(basePath+"/transactions/user/split_swap_exact_tokens_for_tokens.template", "utf-8");
    code = code.replace("tokenInVaultPath: StoragePath,", "")
    code = code.replace("tokenOutVaultPath: StoragePath,", "")
    code = code.replace("tokenOutReceiverPath: PublicPath,", "")
    code = code.replace("tokenOutBalancePath: PublicPath,", "")
    code = code.replaceAll("tokenInVaultPath", tokenInVaultPath)
    code = code.replaceAll("tokenOutVaultPath", tokenOutVaultPath)
    code = code.replaceAll("tokenOutReceiverPath", tokenOutReceiverPath)
    code = code.replaceAll("tokenOutBalancePath", tokenOutBalancePath)

    code = code.replaceAll("Token1Addr", await getTokenAddrByName(tokenOutName))
    code = code.replaceAll("Token1Name", tokenOutName)

    let curTimestamp = (await queryTimestamp())[0]

    const signers = [userAddr]
    const args = [
        tokenKeyPath,
        Array_amountInSplit,
        amountOutMin,
        parseFloat(curTimestamp) + parseFloat(duration)
    ]
    return sendTransaction({ code, args, signers })
}

/**
 * SplitSwapTokensForExactTokens
 * @returns {Promise<*>}
 */
 export const splitSwapTokensForExactTokens = async(
    userAddr,
    Array_tokenNamePath,
    Array_amountOutSplit,
    amountInMax,
    duration,
) => {
    let tokenInName = Array_tokenNamePath[0]
    let tokenOutName = Array_tokenNamePath[Array_tokenNamePath.length-1]
    let tokenKeyPath = []
    for (let i = 0; i < Array_tokenNamePath.length; ++i) {
        let tokenName = Array_tokenNamePath[i]
        tokenKeyPath.push(await getTokenKeyByName(tokenName))
    }

    let tokenInPathPrefix = await getTokenPathPrefixByName(tokenInName)
    let tokenOutPathPrefix = await getTokenPathPrefixByName(tokenOutName)

    let tokenInVaultPath = "/storage/" + tokenInPathPrefix + "Vault"
    let tokenOutVaultPath = "/storage/" + tokenOutPathPrefix + "Vault"
    let tokenOutReceiverPath = "/public/" + tokenOutPathPrefix + "Receiver"
    let tokenOutBalancePath = "/public/" + tokenOutPathPrefix + "Balance"

    const cadenceRootPath = "../../src";
    const basePath = path.resolve(__dirname, cadenceRootPath);
    var code = fs.readFileSync(basePath+"/transactions/user/split_swap_tokens_for_exact_tokens.template", "utf-8");
    code = code.replace("tokenInVaultPath: StoragePath,", "")
    code = code.replace("tokenOutVaultPath: StoragePath,", "")
    code = code.replace("tokenOutReceiverPath: PublicPath,", "")
    code = code.replace("tokenOutBalancePath: PublicPath,", "")
    code = code.replaceAll("tokenInVaultPath", tokenInVaultPath)
    code = code.replaceAll("tokenOutVaultPath", tokenOutVaultPath)
    code = code.replaceAll("tokenOutReceiverPath", tokenOutReceiverPath)
    code = code.replaceAll("tokenOutBalancePath", tokenOutBalancePath)

    code = code.replaceAll("Token1Addr", await getTokenAddrByName(tokenOutName))
    code = code.replaceAll("Token1Name", tokenOutName)

    let curTimestamp = (await queryTimestamp())[0]

    const signers = [userAddr]
    const args = [
        tokenKeyPath,
        Array_amountOutSplit,
        amountInMax,
        parseFloat(curTimestamp) + parseFloat(duration)
    ]
    return sendTransaction({ code, args, signers })
}

/**
 * SwapExactTokensForTokens
 * @returns {Promise<*>}
 */
 export const swapExactTokensForTokens = async(
    userAddr,
    Array_tokenNamePath,
    amountIn,
    amountOutMin,
    duration,
) => {
    let tokenInName = Array_tokenNamePath[0]
    let tokenOutName = Array_tokenNamePath[Array_tokenNamePath.length-1]
    let tokenKeyPath = []
    for (let i = 0; i < Array_tokenNamePath.length; ++i) {
        let tokenName = Array_tokenNamePath[i]
        tokenKeyPath.push(await getTokenKeyByName(tokenName))
    }

    let tokenInPathPrefix = await getTokenPathPrefixByName(tokenInName)
    let tokenOutPathPrefix = await getTokenPathPrefixByName(tokenOutName)

    let tokenInVaultPath = "/storage/" + tokenInPathPrefix + "Vault"
    let tokenOutVaultPath = "/storage/" + tokenOutPathPrefix + "Vault"
    let tokenOutReceiverPath = "/public/" + tokenOutPathPrefix + "Receiver"
    let tokenOutBalancePath = "/public/" + tokenOutPathPrefix + "Balance"

    const cadenceRootPath = "../../src";
    const basePath = path.resolve(__dirname, cadenceRootPath);
    var code = fs.readFileSync(basePath+"/transactions/user/swap_exact_tokens_for_tokens.template", "utf-8");
    code = code.replace("tokenInVaultPath: StoragePath,", "")
    code = code.replace("tokenOutVaultPath: StoragePath,", "")
    code = code.replace("tokenOutReceiverPath: PublicPath,", "")
    code = code.replace("tokenOutBalancePath: PublicPath,", "")
    code = code.replaceAll("tokenInVaultPath", tokenInVaultPath)
    code = code.replaceAll("tokenOutVaultPath", tokenOutVaultPath)
    code = code.replaceAll("tokenOutReceiverPath", tokenOutReceiverPath)
    code = code.replaceAll("tokenOutBalancePath", tokenOutBalancePath)

    code = code.replaceAll("Token1Addr", await getTokenAddrByName(tokenOutName))
    code = code.replaceAll("Token1Name", tokenOutName)

    let curTimestamp = (await queryTimestamp())[0]

    const signers = [userAddr]
    const args = [
        tokenKeyPath,
        amountIn,
        amountOutMin,
        parseFloat(curTimestamp) + parseFloat(duration)
    ]
    return sendTransaction({ code, args, signers })
}

/**
 * SplitSwapTokensForExactTokens
 * @returns {Promise<*>}
 */
 export const swapTokensForExactTokens = async(
    userAddr,
    Array_tokenNamePath,
    amountOut,
    amountInMax,
    duration,
) => {
    let tokenInName = Array_tokenNamePath[0]
    let tokenOutName = Array_tokenNamePath[Array_tokenNamePath.length-1]
    let tokenKeyPath = []
    for (let i = 0; i < Array_tokenNamePath.length; ++i) {
        let tokenName = Array_tokenNamePath[i]
        tokenKeyPath.push(await getTokenKeyByName(tokenName))
    }

    let tokenInPathPrefix = await getTokenPathPrefixByName(tokenInName)
    let tokenOutPathPrefix = await getTokenPathPrefixByName(tokenOutName)

    let tokenInVaultPath = "/storage/" + tokenInPathPrefix + "Vault"
    let tokenOutVaultPath = "/storage/" + tokenOutPathPrefix + "Vault"
    let tokenOutReceiverPath = "/public/" + tokenOutPathPrefix + "Receiver"
    let tokenOutBalancePath = "/public/" + tokenOutPathPrefix + "Balance"

    const cadenceRootPath = "../../src";
    const basePath = path.resolve(__dirname, cadenceRootPath);
    var code = fs.readFileSync(basePath+"/transactions/user/swap_tokens_for_exact_tokens.template", "utf-8");
    code = code.replace("tokenInVaultPath: StoragePath,", "")
    code = code.replace("tokenOutVaultPath: StoragePath,", "")
    code = code.replace("tokenOutReceiverPath: PublicPath,", "")
    code = code.replace("tokenOutBalancePath: PublicPath,", "")
    code = code.replaceAll("tokenInVaultPath", tokenInVaultPath)
    code = code.replaceAll("tokenOutVaultPath", tokenOutVaultPath)
    code = code.replaceAll("tokenOutReceiverPath", tokenOutReceiverPath)
    code = code.replaceAll("tokenOutBalancePath", tokenOutBalancePath)

    code = code.replaceAll("Token1Addr", await getTokenAddrByName(tokenOutName))
    code = code.replaceAll("Token1Name", tokenOutName)

    let curTimestamp = (await queryTimestamp())[0]

    const signers = [userAddr]
    const args = [
        tokenKeyPath,
        amountInMax,
        amountOut,
        parseFloat(curTimestamp) + parseFloat(duration)
    ]
    return sendTransaction({ code, args, signers })
}