import { getAccountAddress, executeScript } from "flow-js-testing";

const UFIX64_PRECISION = 8;

// UFix64 values shall be always passed as strings
export const toUFix64 = (value) => value.toFixed(UFIX64_PRECISION);
export const ScaleFactor = 1e18

export const getSwapConfigDeployerAddress = async () => getAccountAddress("SwapConfigDeployer");
export const getSwapFactoryDeployerAddress = async () => getAccountAddress("SwapFactoryDeployer");
export const getSwapPairTemplateDeployerAddress = async () => getAccountAddress("SwapPairTemplateDeployer");

export const getTestTokenDeployerAddress = async () => getAccountAddress("TestTokenDeployer");

export const queryTimestamp = async () => {
    const name = "query/query_timestamp";
    const args = [];
    return executeScript({ name, args });
}