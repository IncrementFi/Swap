import fs from "fs";
import path from "path";
import { deployContractByName, getAccountAddress, executeScript, mintFlow, sendTransaction, getTemplate, getScriptCode } from "flow-js-testing"
import {
    getSwapConfigDeployerAddress,
    getSwapFactoryDeployerAddress,
    getSwapPairTemplateDeployerAddress,
    getTestTokenDeployerAddress,
    toUFix64
} from "./setup_Common"
import {
    deployFUSD,
} from "./setup_Tokens"

export const getSwapConfigAddress = async () => { return await getSwapConfigDeployerAddress() }
export const getSwapInterfacesAddress = async () => { return await getSwapConfigDeployerAddress() }
export const getSwapErrorAddress = async () => { return await getSwapConfigDeployerAddress() }

export const getSwapFactoryAddress = async () => { return await getSwapFactoryDeployerAddress() }
export const getSwapRouterAddress = async () => { return await getSwapFactoryDeployerAddress() }
export const getSwapPairTemplateAddress = async () => { return await getSwapPairTemplateDeployerAddress() }

/**
 * Deploy Swap related Contracts.
 * @throws Will throw an error if transaction is reverted.
 * @returns {Promise<*>}
 */
export const deploySwapContract = async () => {
    const swapConfigAddr = await getSwapConfigAddress()
    const swapInterfacesAddr = await getSwapInterfacesAddress()
    const swapErrorAddr = await getSwapErrorAddress()
    const swapFactoryAddr = await getSwapFactoryAddress()
    const swapRouterAddr = await getSwapRouterAddress()
    const swapPairTemplateAddr = await getSwapPairTemplateAddress()

    // Mint some flow to deployer account for extra storage capacity.
    await mintFlow(swapConfigAddr, "1.0")
    await mintFlow(swapFactoryAddr, "1.0")
    await mintFlow(getSwapRouterAddress, "1.0")
    
    // Deploy indepencies & pool contracts.
    const addressMap = { SwapInterfaces: swapInterfacesAddr, SwapConfig: swapConfigAddr, SwapError: swapErrorAddr, SwapFactory: swapFactoryAddr }

    await deployContractByName({ to: swapErrorAddr, name: "SwapError" })
    await deployContractByName({ to: swapInterfacesAddr, name: "SwapInterfaces" })
    await deployContractByName({ to: swapConfigAddr, name: "SwapConfig" })

    await deployContractByName({
        to: swapFactoryAddr,
        name: "SwapFactory", addressMap,
        args: [
            swapPairTemplateAddr
        ]
    })

    await deploySwapPairTemplate()

    return await deployContractByName({ to: swapRouterAddr, name: "SwapRouter", addressMap })
}

export const deploySwapPairTemplate = async () => {
    const swapConfigAddr = await getSwapConfigAddress()
    const swapInterfacesAddr = await getSwapInterfacesAddress()
    const swapErrorAddr = await getSwapErrorAddress()
    const swapFactoryAddr = await getSwapFactoryAddress()
    const swapRouterAddr = await getSwapRouterAddress()
    const swapPairTemplateAddr = await getSwapPairTemplateAddress()
    
    const cadenceRootPath = "../../src";
    const basePath = path.resolve(__dirname, cadenceRootPath);
    var code = fs.readFileSync(basePath+"/contracts/SwapPair.cdc", "utf-8");
    code = code.replaceAll("\"./tokens/FungibleToken.cdc\"", "0xee82856bf20e2aa6")
    code = code.replaceAll("\"./SwapInterfaces.cdc\"", swapInterfacesAddr)
    code = code.replaceAll("\"./SwapConfig.cdc\"", swapConfigAddr)
    code = code.replaceAll("\"./SwapError.cdc\"", swapConfigAddr)
    code = code.replaceAll("\"./SwapFactory.cdc\"", swapFactoryAddr)
    
    const name = "factory/deploy_pair_template";

    const signers = [swapPairTemplateAddr];
    const args = [code];
    const [res, err] = await sendTransaction({ name, signers, args });
    
    return [res, err]
}
