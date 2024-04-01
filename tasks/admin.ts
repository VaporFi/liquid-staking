import { task } from 'hardhat/config'
import LiquidMiningDiamond from '../deployments/LiquidMiningDiamond.json'

task('admin:authorize', 'Authorize an address to perform admin actions')
  .addParam('address')
  .setAction(async ({ address }, { ethers, network }) => {
    const diamondAddress =
      LiquidMiningDiamond[network.name as keyof typeof LiquidMiningDiamond]
        .address
    const AuthorizationFacet = await ethers.getContractAt(
      'AuthorizationFacet',
      diamondAddress
    )

    await AuthorizationFacet.authorize(address)
  })
