import { deployContractByName, getAccountAddress, executeScript, mintFlow, sendTransaction, getTemplate, getScriptCode } from "flow-js-testing"
import {
    getSwapConfigDeployerAddress,
    getSwapFactoryDeployerAddress,
    getSwapPairTemplateDeployerAddress,
    getTestTokenDeployerAddress,
    toUFix64,
} from "./setup_Common"
import {
    getSwapFactoryAddress,
} from "./setup_Deployment"
import {
    getTokenKeyByName
} from "./setup_Tokens"

/**
 * Create Pair
 * @returns {Promise<*>}
 */
export const createPair = async(tokenName0, tokenName1) => {
    let code = `
        import Token0Name from Token0Addr
        import Token1Name from Token1Addr
        import SwapFactory from 0xSwapFactory
        import FungibleToken from "../../contracts/tokens/FungibleToken.cdc"

        transaction() {
            prepare(userAccount: AuthAccount) {
                let token0Vault <- Token0Name.createEmptyVault()
                let token1Vault <- Token1Name.createEmptyVault()
                
                let accountCreationFee <- userAccount.borrow<&FungibleToken.Vault>(from: /storage/flowTokenVault)!.withdraw(amount: 0.001)
                SwapFactory.createPair(token0Vault: <-token0Vault, token1Vault: <-token1Vault, accountCreationFee: <-accountCreationFee)
            }
        }
    `
    let testTokenAddr = await getTestTokenDeployerAddress()
    let flowTokenAddr = "0x0ae53cb6e3f42a79"
    const swapFactoryAddr = await getSwapFactoryAddress()
    
    let tokenAddr0 = testTokenAddr
    let tokenAddr1 = testTokenAddr
    if (tokenAddr0 == "FlowToken") tokenAddr0 = flowTokenAddr
    if (tokenAddr1 == "FlowToken") tokenAddr1 = flowTokenAddr

    code = code.replaceAll('0xSwapFactory', swapFactoryAddr)
    code = code.replaceAll("Token0Name", tokenName0)
    code = code.replaceAll("Token1Name", tokenName1)
    code = code.replaceAll("Token0Addr", tokenAddr0)
    code = code.replaceAll("Token1Addr", tokenAddr1)
    
    const signers = [swapFactoryAddr]
    const args = []
    return sendTransaction({ code, args, signers })
}

export const queryPairAddr = async (tokenName0, tokenName1) => {
    const tokenKey0 = await getTokenKeyByName(tokenName0);
    const tokenKey1 = await getTokenKeyByName(tokenName1);

    const name = "query/query_pair_addr";
    const args = [tokenKey0, tokenKey1];
    return executeScript({ name, args });
}

/*
pairInfo = [
    'A.f8d6e0586b0a20c7.wFlow',  // 0: token0Key
    'A.f8d6e0586b0a20c7.USDC',   // 1: token1Key
    '4000.00000000',             // 2: token0Balance
    '10000.00000000',            // 3: token1Balance
    '0x120e725050340cab'         // 4: pairAddr
    '123.12'                     // 5: totalSupply for lptokens
]
*/
export const queryPairInfoByTokenName = async (tokenName0, tokenName1) => {
    const tokenKey0 = await getTokenKeyByName(tokenName0);
    const tokenKey1 = await getTokenKeyByName(tokenName1);
        
    const name = "query/query_pair_info_by_tokenkey";
    const args = [tokenKey0, tokenKey1];
    return executeScript({ name, args });
}

/// @Return lptoken amount in user local storage
export const queryLptokenBalance = async (userAddr, tokenKey0, tokenKey1) => {
    const targePpoolAddr = (await queryPairAddr(tokenKey0, tokenKey1))[0]

    const name = "query/query_user_all_liquidities";
    const args = [userAddr];
    const [res, err] = await executeScript({ name, args });
    for (let poolAddr in res) {
        if (poolAddr === targePpoolAddr) {
            return res[poolAddr]
        }
    }
    return "0.00000000"
}
