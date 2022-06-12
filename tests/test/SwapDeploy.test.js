import path from "path";
import { emulator, init, mintFlow, getAccountAddress, shallPass, shallRevert, shallResolve } from "flow-js-testing";
import { toUFix64 } from "../setup/setup_Common";
import {
    deploySwapContract,
    deploySwapPairTemplate,

} from "../setup/setup_Deployment";

// We need to set timeout for a higher number, because some transactions might take up some time
jest.setTimeout(100000)

describe("Swap Deployment Testsuites", () => {
    beforeEach(async () => {
        const basePath = path.resolve(__dirname, "../../src")
        // Note: Use different port for different testsuites to run test simultaneously. 
        const port = 7002;
        await init(basePath, { port })
        return emulator.start(port, false)
    });
    // Stop emulator, so it could be restarted
    afterEach(async () => {
        return emulator.stop()
    });
    
    it("Should deploy Swap related contracts successfully", async () => {
        //await deploySwapPairTemplate()
        await shallResolve(deploySwapContract())
    });
    
});