import { BaseContract } from 'ethers'
import { ethers, network } from 'hardhat'
import { addFacets } from '../../utils/diamond'
import { deployContract } from '../../utils/deployContract'
import { DiamondInit } from '../../typechain-types'
import getFacets from '../../utils/getFacets'
import { addresses } from '../../config/addresses'
import { BURN_WALLET } from '../../config/constants'

const CHAIN_ID = ['avalanche', 'fuji'].includes(network.name)
  ? network.config?.chainId || '43113'
  : '43113'
// WARNING: the order here is important, check src/DiamondInit.sol
export const defaultArgs: DiamondInit.ArgsStruct = {
  unlockFee: '1000', // 10%
  depositToken: addresses.vpnd[CHAIN_ID],
  feeToken: addresses.usdc[CHAIN_ID],
  rewardToken: addresses.vape[CHAIN_ID],
  stratosphere: addresses.stratosphere[CHAIN_ID],
  xVAPE: addresses.xVAPE[CHAIN_ID],
  passport: addresses.passportPool[CHAIN_ID],
  replenishmentPool: addresses.vpndReplenishmentPool[CHAIN_ID],
  labsMultisig: addresses.teamMultisig[CHAIN_ID],
  burnWallet: BURN_WALLET,
}

export const FacetNames = getFacets()

export default async function deployDiamond(
  args: DiamondInit.ArgsStruct = defaultArgs
) {
  const [deployer] = await ethers.getSigners()
  // Deploy DiamondCutFacet
  const diamondCutFacet = await deployContract('DiamondCutFacet')

  // Deploy Diamond
  const diamond = await deployContract('LiquidMiningDiamond', {
    args: [deployer.address, await diamondCutFacet.getAddress()],
    log: true,
    // skipIfAlreadyDeployed: true,
  })

  // Deploy DiamondInit
  const diamondInit = await deployContract('DiamondInit')

  // Deploy Facets
  const facets: BaseContract[] = []
  const facetsByName = {} as {
    [K in (typeof FacetNames)[number]]: BaseContract
  }
  for (const FacetName of FacetNames) {
    const facet = await deployContract(FacetName)

    facets.push(facet)
    facetsByName[FacetName] = facet
  }

  // Add facets to diamond
  console.log('Args: ', Object.values(args))
  const functionCall = diamondInit.interface.encodeFunctionData('init', [
    Object.values(args),
  ])

  await addFacets(
    facets,
    await diamond.getAddress(),
    await diamondInit.getAddress(),
    functionCall
  )

  return diamond
}
