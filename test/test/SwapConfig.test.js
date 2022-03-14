import path from "path";
import { emulator, init, shallPass, shallRevert, shallResolve } from "flow-js-testing";
import { toUFix64 } from "../setup/setup_Common";
import {
    sqrt,
    getAmountOut,
    getAmountIn,
    quote,
    deployConfigContract,
    UFix64ToScaledUInt256,
    ScaledUInt256ToUFix64,
    UFix64MaxBackAndForth
} from "../setup/setup_Config";
import { hasUncaughtExceptionCaptureCallback } from "process";

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(100000);

describe("SwapConfig Testsuites", () => {
    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "../../src");
        // Note: Use different port for different testsuites to run test simultaneously. 
        const port = 7001;
        await init(basePath, { port });
        await emulator.start(port, false);
    });
    // Stop emulator, so it could be restarted
    afterEach(async () => {
        return emulator.stop();
    });
    /*
    it("Test sqrt", async () => {
        await deployConfigContract();
        expect(
            (await sqrt(1.0000))[0]
        ).toBe(
            "1.00000000"
        );
        expect(
            (await sqrt(10.0000))[0]
        ).toBe(
            "3.16227766"
        );
        expect(
            (await sqrt(0.00000001))[0]
        ).toBe(
            "0.00010000"
        );
        expect(
            (await sqrt(0.54))[0]
        ).toBe(
            "0.73484692"
        );
        expect(
            (await sqrt(184467440735))[0]
        ).toBe(
            "429496.72959756"
        );
    });
    
    it("Test getAmountOut", async () => {
        await deployConfigContract();
        var reserveIn = 999.0
        var reserveOut = 100999.0
        var amountIn = 13.0
        var amountOut = 0
        amountOut = (await getAmountOut(amountIn, reserveIn, reserveOut))[0]

        expect(
            amountOut
        ).toBe(
            "1293.57558147"
        );
        //
        var reserveIn = 999412189.0
        var reserveOut = 39912189.0
        var amountIn = 1893913.0
        var amountOut = 0
        amountOut = (await getAmountOut(amountIn, reserveIn, reserveOut))[0]
        expect(
            amountOut
        ).toBe(
            "75265.56609763"
        );

        var reserveIn = 0.001232
        var reserveOut = 0.00043
        var amountIn = 0.1231
        var amountOut = 0
        amountOut = (await getAmountOut(amountIn, reserveIn, reserveOut))[0]
        expect(
            amountOut
        ).toBe(
            "0.00042572"
        );
    });
    
    it("Test getAmountIn", async () => {
        await deployConfigContract();
        var reserveIn = 999.0
        var reserveOut = 100999.0
        var amountIn = 0.0
        var amountOut = 1293.57558147
        amountIn = (await getAmountIn(amountOut, reserveIn, reserveOut))[0]
        expect(
            amountIn
        ).toBe(
            "12.99999999"
        );
        //
        var reserveIn = 999412189.0
        var reserveOut = 39912189.0
        var amountIn = 0.0
        var amountOut = 75265.56609763
        amountIn = (await getAmountIn(amountOut, reserveIn, reserveOut))[0]
        expect(
            amountIn
        ).toBe(
            "1893912.99999996"
        );

        var reserveIn = 0.001232
        var reserveOut = 0.00043
        var amountIn = 0.0
        var amountOut = 0.00042572
        amountIn = (await getAmountIn(amountOut, reserveIn, reserveOut))[0]
        expect(
            amountIn
        ).toBe(
            "0.12291243"
        );
    });
    
    it("Test quote", async () => {
        await deployConfigContract();

        var reserveA = 999.0
        var reserveB = 100999.0
        var amountA = 1293.57558147
        var amountB = 0.0
        amountB = (await quote(amountA, reserveA, reserveB))[0]
        expect(
            amountB
        ).toBe(
            "130780.62077366"
        );

        var reserveA = 999412189.0
        var reserveB = 39912189.0
        var amountA = 75265.56609763
        var amountB = 0.0
        amountB = (await quote(amountA, reserveA, reserveB))[0]
        expect(
            amountB
        ).toBe(
            "3005.78033002"
        );

        var reserveA = 0.001232
        var reserveB = 0.00043
        var amountA = 0.00042572
        var amountB = 0.0
        amountB = (await quote(amountA, reserveA, reserveB))[0]
        expect(
            amountB
        ).toBe(
            "0.00014858"
        );
    });
    */

    it("Test getAmountIn", async () => {
        await deployConfigContract();
        var reserveIn = 999.0
        var reserveOut = 100999.0
        var amountIn = 0.0
        var amountOut = 95.0
        amountIn = (await getAmountIn(amountOut, reserveIn, reserveOut))[0]
        amountIn = 0.94337758
        console.log('estimated in', amountIn)
        console.log('   js:', amountOut * reserveIn / (reserveOut - amountOut) / 0.997)
        console.log('real out', (await getAmountOut(amountIn, reserveIn, reserveOut))[0] )
        //amountIn = 0.9930782446348948

        console.log('   js:', 0.997 * amountIn * reserveOut / (reserveIn + 0.997 * amountIn))
        console.log('want out', amountOut)
    });
});