import path from "path";
import { emulator, init, mintFlow, getAccountAddress, shallPass, shallRevert, shallResolve } from "flow-js-testing";
import {
    getTestTokenDeployerAddress,
    toUFix64
} from "../setup/setup_Common";

import {
    deploySwapContract,
} from "../setup/setup_Deployment";

import {
    createPair,
    queryPairAddr,
    queryPairInfoByTokenName
} from "../setup/setup_SwapFactory";

import {
    deployTokenByName,
    mintTokenByName,
    getBalanceByName,
    getTokenKeyByName
} from "../setup/setup_Tokens"

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(100000)

describe("Swap Factory Testsuites", () => {
    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "../../src");
        // Note: Use different port for different testsuites to run test simultaneously.
        const port = 7003;
        await init(basePath, { port });
        await emulator.start(port, false);
        return deploySwapContract()
    });
    // Stop emulator, so it could be restarted
    afterEach(async () => {
        return emulator.stop();
    });

    it("Create Pair", async () => {
        await deployTokenByName("FUSD");
        await deployTokenByName("USDC");

        await shallResolve(
            createPair("FUSD", "USDC")
        );

        // should get the new pair address correctly
        expect(
            (await queryPairAddr("FUSD", "USDC"))[0]
        ).not.toBeNull();
        
        // should be null if pair non-exist
        expect(
            (await queryPairAddr("FUSD", "BTC"))[0]
        ).toBeNull();
    });
    
    it("Check the init state of the new pair", async () => {
        await deployTokenByName("FUSD");
        await deployTokenByName("USDC");

        await shallResolve(
            createPair("FUSD", "USDC")
        );

        const [pairInfo, err] = await queryPairInfoByTokenName("FUSD", "USDC")
        expect(err).toBeNull()
        // init both-side liquidity should be 0.0
        expect(pairInfo[2]).toBe("0.00000000")
        expect(pairInfo[3]).toBe("0.00000000")
        // totalSupply of lptoken should be 0.0
        expect(pairInfo[5]).toBe("0.00000000")
    });

});