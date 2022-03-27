import path from "path";
import { emulator, init, mintFlow, getAccountAddress, shallPass, shallRevert, shallResolve } from "flow-js-testing";

import {
    getTestTokenDeployerAddress,
    toUFix64
} from "../setup/setup_Common";

import {
    sqrt,
    getAmountOut
} from "../setup/setup_Config"

import {
    deploySwapContract,
} from "../setup/setup_Deployment";

import {
    createPair,
    queryPairAddr,
    queryPairInfoByTokenName,
    queryLptokenBalance
} from "../setup/setup_SwapFactory";

import {
    deployTokenByName,
    mintTokenByName,
    getBalanceByName,
    getTokenKeyByName
} from "../setup/setup_Tokens"

import {
    addLiquidity,
    removeLiquidity
} from "../setup/setup_SwapPair"

import {
    splitSwapExactTokensForTokens,
    splitSwapTokensForExactTokens,
    swapExactTokensForTokens,
    swapTokensForExactTokens
} from "../setup/setup_SwapRouter"

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(100000)

describe("Swap Pair Testsuites", () => {
    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "../../src");
        // Note: Use different port for different testsuites to run test simultaneously.
        const port = 7004;
        await init(basePath, { port });
        await emulator.start(port, false);
        return deploySwapContract()
    });
    // Stop emulator, so it could be restarted
    afterEach(async () => {
        return emulator.stop();
    });
    /*
    it("Split Swap Exact Tokens for Tokens - one swap", async () => {
        const liquidityProvider = await getAccountAddress("liquidityProvider");
        const trader = await getAccountAddress("trader");

        let tokenName0 = "FUSD";
        let tokenName1 = "USDC";
        await deployTokenByName(tokenName0);
        await deployTokenByName(tokenName1);

        await mintTokenByName(tokenName0, liquidityProvider, "15000000.0");
        await mintTokenByName(tokenName1, liquidityProvider, "15000000.0");
        await mintTokenByName(tokenName0, trader, "15.0");
        //await mintTokenByName(tokenName1, userAddr1, "10.0");
        
        await createPair(tokenName0, tokenName1);

        const reserve0 = 14000000.0
        const reserve1 = 9000000.0

        await addLiquidity(liquidityProvider, tokenName0, tokenName1, reserve0, reserve1, 0.1, 500)
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName(tokenName0, trader))[0], (await getBalanceByName(tokenName1, trader))[0])


        // Swap 
        let swapRes = await splitSwapExactTokensForTokens(
            trader,
            [tokenName0, tokenName1],
            ["10.0"],
            "0.0",
            "500.0"
        )
        expect(swapRes[1]).toBeNull()

        const afterPairInfo = (await queryPairInfoByTokenName(tokenName0, tokenName1))[0]
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName(tokenName0, trader))[0], (await getBalanceByName(tokenName1, trader))[0])
        
        let amountIn = 10.0
        let amountOut = amountIn * 0.997 * reserve1 / (reserve0 + amountIn * 0.997)
        //console.log('estimate out', amountOut)
            
        expect(
            (await getBalanceByName(tokenName1, trader))[0]
        ).toBe(
            "6.40928114"
        )

        expect(
            afterPairInfo[2]
        ).toBe(
            "14000010.00000000"
        )
    });
    
    it("Split Swap Exact Tokens for Tokens - multi swap", async () => {
        const liquidityProvider = await getAccountAddress("liquidityProvider");
        const trader = await getAccountAddress("trader");

        await deployTokenByName("FUSD");
        await deployTokenByName("USDC");
        await deployTokenByName("ETH");

        await mintTokenByName("FUSD", liquidityProvider, "10000000.0");
        await mintTokenByName("USDC", liquidityProvider, "10000000.0");
        await mintTokenByName("ETH", liquidityProvider, "10000000.0");

        await mintTokenByName("FUSD", trader, "10.0");
        
        await createPair("FUSD", "USDC");
        await createPair("FUSD", "ETH");
        await createPair("USDC", "ETH");

        await addLiquidity(liquidityProvider, "FUSD", "USDC", "1000", "1000", 0.1, 500)
        await addLiquidity(liquidityProvider, "FUSD", "ETH", "1000", "1", 0.1, 500)
        await addLiquidity(liquidityProvider, "USDC", "ETH", "1000", "1", 0.1, 500)
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName(tokenName0, trader))[0], (await getBalanceByName(tokenName1, trader))[0])

        // Swap 
        let swapRes = await splitSwapExactTokensForTokens(
            trader,
            ["FUSD", "ETH", "FUSD", "USDC", "ETH"],
            ["5.0", "5.0"],
            "0.0",
            "500.0"
        )
        expect(swapRes[1]).toBeNull()

        const afterPairInfo = (await queryPairInfoByTokenName("FUSD", "ETH"))[0]
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName("FUSD", trader))[0], (await getBalanceByName("ETH", trader))[0])
        
        let amountIn = 5.0
        let amountOut1 = amountIn * 0.997 * 1.0 / (1000.0 + amountIn * 0.997)
        let amountOut2_1 = amountIn * 0.997 * 1000.0 / (1000.0 + amountIn * 0.997)
        let amountOut2_2 = amountOut2_1 * 0.997 * 1.0 / (1000.0 + amountOut2_1 * 0.997)
        //console.log('estimate out', amountOut1+amountOut2_2)
        
        expect(
            (await getBalanceByName("ETH", trader))[0]
        ).toBe(
            "0.00988132"
        )

        expect(
            afterPairInfo[2]
        ).toBe(
            "1005.00000000"
        )
    });
    
    
    it("Split Swap Tokens for Exact Tokens - one swap", async () => {
        const liquidityProvider = await getAccountAddress("liquidityProvider");
        const trader = await getAccountAddress("trader");

        let tokenName0 = "FUSD";
        let tokenName1 = "USDC";
        await deployTokenByName(tokenName0);
        await deployTokenByName(tokenName1);

        await mintTokenByName(tokenName0, liquidityProvider, "15000000.0");
        await mintTokenByName(tokenName1, liquidityProvider, "15000000.0");
        await mintTokenByName(tokenName0, trader, "15.0");

        
        await createPair(tokenName0, tokenName1);

        const reserve0 = 14000000.0
        const reserve1 = 9000000.0

        await addLiquidity(liquidityProvider, tokenName0, tokenName1, reserve0, reserve1, 0.1, 500)
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName(tokenName0, trader))[0], (await getBalanceByName(tokenName1, trader))[0])


        // Swap 
        let swapRes = await splitSwapTokensForExactTokens(
            trader,
            [tokenName0, tokenName1],
            ["5.12345678"],
            "99999.0",
            "500.0"
        )
        expect(swapRes[1]).toBeNull()

        const afterPairInfo = (await queryPairInfoByTokenName(tokenName0, tokenName1))[0]
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName(tokenName0, trader))[0], (await getBalanceByName(tokenName1, trader))[0])
        
        let amountOut = 6.0
        let amountIn = amountOut * reserve0 / (reserve1 - amountOut) / 0.997
        //console.log('estimate in', amountIn)
        //console.log(afterPairInfo)
        
        expect(
            (await getBalanceByName(tokenName1, trader))[0]
        ).toBe(
            "5.12345678"
        )
    });
    

    it("Swap Exact Tokens for Tokens - multi swap", async () => {
        const liquidityProvider = await getAccountAddress("liquidityProvider");
        const trader = await getAccountAddress("trader");

        await deployTokenByName("FUSD");
        await deployTokenByName("USDC");
        await deployTokenByName("ETH");

        await mintTokenByName("FUSD", liquidityProvider, "10000000.0");
        await mintTokenByName("USDC", liquidityProvider, "10000000.0");
        await mintTokenByName("ETH", liquidityProvider, "10000000.0");

        await mintTokenByName("FUSD", trader, "10.0");
        
        await createPair("FUSD", "USDC");
        await createPair("FUSD", "ETH");
        await createPair("USDC", "ETH");

        await addLiquidity(liquidityProvider, "FUSD", "USDC", "1000", "1000", 0.1, 500)
        await addLiquidity(liquidityProvider, "FUSD", "ETH", "1000", "1", 0.1, 500)
        await addLiquidity(liquidityProvider, "USDC", "ETH", "1000", "1", 0.1, 500)
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName("FUSD", trader))[0], (await getBalanceByName("ETH", trader))[0])

        // Swap 
        let swapRes = await swapExactTokensForTokens(
            trader,
            ["FUSD", "USDC", "ETH"],
            "5.0",
            "0.0",
            "500.0"
        )
        expect(swapRes[1]).toBeNull()

        const afterPairInfo = (await queryPairInfoByTokenName("FUSD", "ETH"))[0]
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName("FUSD", trader))[0], (await getBalanceByName("ETH", trader))[0])
        
        let amountIn = 5.0
        let amountOut1 = amountIn * 0.997 * 1.0 / (1000.0 + amountIn * 0.997)
        let amountOut2_1 = amountIn * 0.997 * 1000.0 / (1000.0 + amountIn * 0.997)
        let amountOut2_2 = amountOut2_1 * 0.997 * 1.0 / (1000.0 + amountOut2_1 * 0.997)
        //console.log('estimate out', amountOut1+amountOut2_2)
        
        expect(
            (await getBalanceByName("ETH", trader))[0]
        ).toBe(
            "0.00492105"
        )
    });
    */

    it("Swap Tokens for Exact Tokens - one swap", async () => {
        const liquidityProvider = await getAccountAddress("liquidityProvider");
        const trader = await getAccountAddress("trader");

        let tokenName0 = "FUSD";
        let tokenName1 = "USDC";
        await deployTokenByName(tokenName0);
        await deployTokenByName(tokenName1);

        await mintTokenByName(tokenName0, liquidityProvider, "15000000.0");
        await mintTokenByName(tokenName1, liquidityProvider, "15000000.0");
        await mintTokenByName(tokenName0, trader, "15.0");

        
        await createPair(tokenName0, tokenName1);

        const reserve0 = 14000000.0
        const reserve1 = 9000000.0

        await addLiquidity(liquidityProvider, tokenName0, tokenName1, reserve0, reserve1, 0.1, 500)
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName(tokenName0, trader))[0], (await getBalanceByName(tokenName1, trader))[0])


        // Swap 
        let swapRes = await swapTokensForExactTokens(
            trader,
            [tokenName0, tokenName1],
            "5.12345678",
            "10.0",
            "500.0"
        )
        expect(swapRes[1]).toBeNull()

        const afterPairInfo = (await queryPairInfoByTokenName(tokenName0, tokenName1))[0]
        //console.log('init', await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName(tokenName0, trader))[0], (await getBalanceByName(tokenName1, trader))[0])
        
        let amountOut = 6.0
        let amountIn = amountOut * reserve0 / (reserve1 - amountOut) / 0.997
        //console.log('estimate in', amountIn)
        //console.log(afterPairInfo)
        
        expect(
            (await getBalanceByName(tokenName1, trader))[0]
        ).toBe(
            "5.12345678"
        )
    });
});