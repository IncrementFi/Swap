import path from "path";
import { emulator, init, mintFlow, getAccountAddress, shallPass, shallRevert, shallResolve } from "flow-js-testing";

import {
    getTestTokenDeployerAddress,
    toUFix64
} from "../setup/setup_Common";

import {
    sqrt
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
    it("Add liquidity - firstly", async () => {
        const userAddr = await getAccountAddress("user");

        let tokenName0 = "FUSD";
        let tokenName1 = "USDC";

        await deployTokenByName(tokenName0);
        await deployTokenByName(tokenName1);
        await mintTokenByName(tokenName0, userAddr, "100.0");
        await mintTokenByName(tokenName1, userAddr, "100.0");
        
        await createPair(tokenName0, tokenName1);

        const tokenKey0 = await getTokenKeyByName(tokenName0);
        const tokenKey1 = await getTokenKeyByName(tokenName1);

        shallResolve(
            await addLiquidity(
                userAddr,
                tokenName0,
                tokenName1,
                15.0,  // amount0
                10.0,  // amount1
                0.1,   // slippage
                500    // deadline
            )
        )
        
        // pool info
        const [pairInfo, err] = await queryPairInfoByTokenName(tokenName0, tokenName1)
        // lptokne
        const lpTokenAmount = await queryLptokenBalance(userAddr, tokenName0, tokenName1)

        expect(err).toBeNull()
        // init both-side liquidity should be 0.0
        expect(pairInfo[2]).toBe("15.00000000")
        expect(pairInfo[3]).toBe("10.00000000")

        // totalSupply of lptoken should be 0.0
        expect(pairInfo[5]).toBe("12.24744872")

        // 0.00000001 should be cut when provide the liquidation for the first time.
        expect(lpTokenAmount).toBe("12.24744871")

        // local vault check
        expect(
            (await getBalanceByName(tokenName0, userAddr))[0]
        ).toBe(
            "85.00000000"
        )
        expect(
            (await getBalanceByName(tokenName1, userAddr))[0]
        ).toBe(
            "90.00000000"
        )
    });
    it("Add liquidity - firstly - limit testing 1", async () => {
        const userAddr = await getAccountAddress("user");

        let tokenName0 = "FUSD";
        let tokenName1 = "USDC";

        await deployTokenByName(tokenName0);
        await deployTokenByName(tokenName1);
        await mintTokenByName(tokenName0, userAddr, "184467440736");
        await mintTokenByName(tokenName1, userAddr, "184467440736");
        
        await createPair(tokenName0, tokenName1);

        const tokenKey0 = await getTokenKeyByName(tokenName0);
        const tokenKey1 = await getTokenKeyByName(tokenName1);

        shallResolve(
            await addLiquidity(
                userAddr,
                tokenName0,
                tokenName1,
                184467440736.0,  // amount0
                184467440736.0,  // amount1
                0.1,   // slippage
                500    // deadline
            )
        )
        
        // pool info
        const [pairInfo, err] = await queryPairInfoByTokenName(tokenName0, tokenName1)
        // lptokne
        const lpTokenAmount = await queryLptokenBalance(userAddr, tokenName0, tokenName1)

        expect(err).toBeNull()
        // init both-side liquidity should be 0.0
        expect(pairInfo[2]).toBe("184467440736.00000000")
        expect(pairInfo[3]).toBe("184467440736.00000000")

        // totalSupply of lptoken should be 0.0
        expect(pairInfo[5]).toBe("184467440735.99600453")
    });
    it("Add liquidity - firstly - limit testing 2", async () => {
        const userAddr = await getAccountAddress("user");

        let tokenName0 = "FUSD";
        let tokenName1 = "USDC";

        await deployTokenByName(tokenName0);
        await deployTokenByName(tokenName1);
        await mintTokenByName(tokenName0, userAddr, "0.0001");
        await mintTokenByName(tokenName1, userAddr, "0.0004");
        
        await createPair(tokenName0, tokenName1);

        const tokenKey0 = await getTokenKeyByName(tokenName0);
        const tokenKey1 = await getTokenKeyByName(tokenName1);

        shallResolve(
            await addLiquidity(
                userAddr,
                tokenName0,
                tokenName1,
                0.0001,  // amount0
                0.0004,  // amount1
                0.1,   // slippage
                500    // deadline
            )
        )
        
        // pool info
        const [pairInfo, err] = await queryPairInfoByTokenName(tokenName0, tokenName1)
        // lptokne
        const lpTokenAmount = await queryLptokenBalance(userAddr, tokenName0, tokenName1)
        
        expect(err).toBeNull()
        // init both-side liquidity should be 0.0
        expect(pairInfo[2]).toBe("0.00010000")
        expect(pairInfo[3]).toBe("0.00040000")

        // totalSupply of lptoken should be 0.0
        expect(pairInfo[5]).toBe("0.00020000")
    });
    */

    it("Remove liquidity - randomly", async () => {
        const userAddr0 = await getAccountAddress("user0");
        const userAddr1 = await getAccountAddress("user1");

        let tokenName0 = "FUSD";
        let tokenName1 = "USDC";

        await deployTokenByName(tokenName0);
        await deployTokenByName(tokenName1);
        await mintTokenByName(tokenName0, userAddr0, "15000000.0");
        await mintTokenByName(tokenName1, userAddr0, "15000000.0");
        await mintTokenByName(tokenName0, userAddr1, "15.0");
        await mintTokenByName(tokenName1, userAddr1, "10.0");
        
        await createPair(tokenName0, tokenName1);

        const tokenKey0 = await getTokenKeyByName(tokenName0);
        const tokenKey1 = await getTokenKeyByName(tokenName1);

        shallResolve(
            await addLiquidity(userAddr0, tokenName0, tokenName1, 14000000.0, 9000000.0, 0.1, 500)
        )
        //console.log(await queryPairInfoByTokenName(tokenName0, tokenName1))
        shallResolve(
            await addLiquidity(userAddr1, tokenName0, tokenName1, 15.0, 10.0, 0.1, 500)
        )
        
        // lptokne
        let lpTokenAmount = await queryLptokenBalance(userAddr1, tokenName0, tokenName1)

        // remove all liquidity
        shallResolve(
            await removeLiquidity(userAddr1, tokenName0, tokenName1, lpTokenAmount, 0.5, 500)
        )
        
        // pool info
        const [pairInfo, err] = await queryPairInfoByTokenName(tokenName0, tokenName1)
        
        lpTokenAmount = await queryLptokenBalance(userAddr1, tokenName0, tokenName1)
        
        //console.log(lpTokenAmount)
        //console.log(await queryPairInfoByTokenName(tokenName0, tokenName1))
        //console.log('local vault', (await getBalanceByName(tokenName0, userAddr1))[0], (await getBalanceByName(tokenName1, userAddr1))[0])
        
        expect(
            (await getBalanceByName(tokenName0, userAddr1))[0]
        ).toBe(
            "14.99999999"
        )
        expect(
            (await getBalanceByName(tokenName1, userAddr1))[0]
        ).toBe(
            "9.99999999"
        )
        
        expect(err).toBeNull()
        // totalSupply of lptoken should be 0.0
        expect(pairInfo[5]).toBe("11224972.16031000")
        expect(lpTokenAmount).toBe("0.00000000")
    });
});