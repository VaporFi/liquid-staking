import 'dotenv/config'
import { getEnvValSafe } from './utils'
import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-foundry'
import '@nomicfoundation/hardhat-network-helpers'
import '@nomiclabs/hardhat-solhint'
import '@nomicfoundation/hardhat-toolbox'

import './tasks/verify'
import './tasks/automatedClaim'
import './tasks/season'
import './tasks/admin'

import { formatUnits, parseUnits } from 'ethers'

const AVALANCHE_RPC_URL = getEnvValSafe('AVALANCHE_RPC_URL')
const FUJI_RPC_URL = getEnvValSafe('FUJI_RPC_URL')

const DEPLOYER_PRIVATE_KEY = getEnvValSafe('PRIVATE_KEY')

const COINMARKETCAP_API_KEY = getEnvValSafe('COINMARKETCAP_API_KEY')
const SNOWTRACE_API_KEY = getEnvValSafe('SNOWTRACE_API_KEY', false)

const config: HardhatUserConfig = {
  networks: {
    avalanche: {
      accounts: [DEPLOYER_PRIVATE_KEY],
      chainId: 43114,
      url: AVALANCHE_RPC_URL,
      gasPrice: +parseUnits('28', 'gwei').toString(),
    },
    fuji: {
      accounts: [DEPLOYER_PRIVATE_KEY],
      chainId: 43113,
      url: FUJI_RPC_URL,
      gas: 8000000,
      timeout: 10000000,
    },
    hardhat: {
      forking: {
        // blockNumber: 21540815,
        blockNumber: 32454282, //this is the block at which the fix was deployed.
        url: AVALANCHE_RPC_URL,
      },
    },
  },
  solidity: {
    version: '0.8.18',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000000,
      },
    },
  },
  etherscan: {
    apiKey: {
      snowtrace: 'snowtrace',
      snowtraceFuji: 'snowtraceFuji',
    },
    customChains: [
      {
        network: 'snowtrace',
        chainId: 43114,
        urls: {
          apiURL:
            'https://api.routescan.io/v2/network/mainnet/evm/43114/etherscan',
          browserURL: 'https://snowtrace.dev/',
        },
      },
      {
        network: 'snowtraceFuji',
        chainId: 43113,
        urls: {
          apiURL:
            'https://api.routescan.io/v2/network/testnet/evm/43113/etherscan',
          browserURL: 'https://testnet.snowtrace.io/',
        },
      },
    ],
  },
}

export default config
