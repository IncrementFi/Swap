import { deployContractByName, executeScript, mintFlow } from "flow-js-testing";
import { getSwapConfigDeployerAddress } from "./setup_Common";

/**
 * Deploy contract to the SwapConfig deployer account.
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 */ 
export const deployConfigContract = async () => {
    const ConfigDeployer = await getSwapConfigDeployerAddress();
    // Mint some flow to deployer account for extra storage capacity.
    await mintFlow(ConfigDeployer, "100.0");

    return deployContractByName({
        to: ConfigDeployer,
        name: "SwapConfig"
    });
}

/**
 * 
 * @param {UFix64} num
 * @returns [UFix64, error]
 */
export const sqrt = async (num) => {
    const ConfigDeployerAddress = await getSwapConfigDeployerAddress();
    const code = `
        import SwapConfig from ${ConfigDeployerAddress}

        pub fun main(_ num: UFix64): UFix64 {
            let numScaled = SwapConfig.UFix64ToScaledUInt256(num)
            let resScaled = SwapConfig.sqrt(numScaled)
            return SwapConfig.ScaledUInt256ToUFix64(resScaled)
        }
    `;
    const args = [num];
    let res = await executeScript({ code, args });
    return res
}

export const getAmountOut = async (amountIn, reserveIn, reserveOut) => {
    const ConfigDeployerAddress = await getSwapConfigDeployerAddress();
    const code = `
        import SwapConfig from ${ConfigDeployerAddress}

        pub fun main(_ amountIn: UFix64, _ reserveIn: UFix64, _ reserveOut: UFix64): UFix64 {
            return SwapConfig.getAmountOut(amountIn: amountIn, reserveIn: reserveIn, reserveOut: reserveOut)
        }
    `;
    const args = [amountIn, reserveIn, reserveOut];
    let res = await executeScript({ code, args });
    return res
}

export const getAmountIn = async (amountOut, reserveIn, reserveOut) => {
    const ConfigDeployerAddress = await getSwapConfigDeployerAddress();
    const code = `
        import SwapConfig from ${ConfigDeployerAddress}

        pub fun main(_ amountOut: UFix64, _ reserveIn: UFix64, _ reserveOut: UFix64): UFix64 {
            return SwapConfig.getAmountIn(amountOut: amountOut, reserveIn: reserveIn, reserveOut: reserveOut)
        }
    `;
    const args = [amountOut, reserveIn, reserveOut];
    let res = await executeScript({ code, args });
    return res
}

export const quote = async (amountA, reserveA, reserveB) => {
    const ConfigDeployerAddress = await getSwapConfigDeployerAddress();
    const code = `
        import SwapConfig from ${ConfigDeployerAddress}

        pub fun main(_ amountA: UFix64, _ reserveA: UFix64, _ reserveB: UFix64): UFix64 {
            return SwapConfig.quote(amountA: amountA, reserveA: reserveA, reserveB: reserveB)
        }
    `;
    const args = [amountA, reserveA, reserveB];
    let res = await executeScript({ code, args });
    return res
}





/**
 * 
 * @param {UFix64} num 
 * @returns num x 1e18 in UInt256
 */
export const UFix64ToScaledUInt256 = async (num) => {
    const ConfigDeployerAddress = await getSwapConfigDeployerAddress();
    const code = `
        import SwapConfig from ${ConfigDeployerAddress}

        pub fun main(_ num: UFix64): UInt256 {
            return SwapConfig.UFix64ToScaledUInt256(num)
        }
    `;
    const args = [num];
    return executeScript({ code, args });
}

/**
 * 
 * @param {UInt256} num
 * @returns num / 1e18 in UFix64
 */
export const ScaledUInt256ToUFix64 = async (num) => {
    const ConfigDeployerAddress = await getSwapConfigDeployerAddress();
    const code = `
        import SwapConfig from ${ConfigDeployerAddress}

        pub fun main(_ s: UInt256): UFix64 {
            return SwapConfig.ScaledUInt256ToUFix64(s)
        }
    `;
    const args = [num];
    return executeScript({ code, args });
}

// Hardcoded test script due to javascript cannot correctly show number more than 21 decmials
export const UFix64MaxBackAndForth = async () => {
    const ConfigDeployerAddress = await getSwapConfigDeployerAddress();
    const code = `
        import SwapConfig from ${ConfigDeployerAddress}

        pub fun main(): Bool {
            let fmax = UFix64.max
            let scaled_fmax = SwapConfig.UFix64ToScaledUInt256(fmax)
            let fmax_back = SwapConfig.ScaledUInt256ToUFix64(scaled_fmax)
            return fmax == fmax_back
        }
    `;
    const args = [];
    return executeScript({ code, args });
}