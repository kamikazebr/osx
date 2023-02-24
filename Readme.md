# Aragon OSx Protocol

The Aragon OSx protocol is the foundation layer of the new Aragon stack. It allows users to create, manage, and customize DAOs in a way that is lean, adaptable, and secure.

Within this monorepo, you will be able to find 3 individual packages:
- [Contracts](https://github.com/aragon/osx/tree/develop/packages/contracts): the Aragon OSx protocol contracts.
- [Subgraph](https://github.com/aragon/osx/tree/develop/packages/subgraph): contains all code generating our subgraph and event indexing.
- [Contract-ethers](https://github.com/aragon/osx/tree/develop/packages/contracts-ethers): contains the connection between the ethers package and our contracts.

For more information on the individual packages, please read the respective `README.md`.

## Contributing

We'd love to hear what you think! If you want to build this with us, please find a detailed contribution guide in the `CONTRIBUTION_GUIDE.md` [file here](https://github.com/aragon/osx/blob/develop/CONTRIBUTION_GUIDE.md).

## Setup

Start by running `yarn install` in the project root in your terminal.

### Dependencies

Since the repo is set up as yarn workspace, all the linking is done automatically.

## How the Aragon OSx protocol works

To review the contracts powering the Aragon OSx protocol, feel free to head to `packages/contracts`.

The Aragon OSx protocol architecture is composed of two key sections:

- __Core contracts__: the primitives the end user will interact with. It is composed of mostly 3 sections:
    - **DAO contract:** the main contract of our core. It holds a DAO's assets and possible actions.
    - **Permissions**: govern interactions between the plugins, DAOs, and any other address - allowing them (or not) to execute actions on behalf of and within the DAO.
    - **Plugins**: base templates of plugins to build upon.
- __Framework contracts__: in charge of creating and registering each deployed DAO or plugin. It contains:
    - **DAO and Plugin Factories**: creates DAOs or plugins.
    - **DAO and Plugin Registries**: registers into our protocol those DAOs or plugins.
    - **Plugin Processor:** installs and uninstalls plugins into DAOs.

Additionally to those two sections, we have developed several plugins DAOs can easily install upon creation. These are:

- __Token Voting plugin__: enabling token holders to vote yes, no or abstain on incoming DAO proposals
- __Multisig plugin__: enabling DAO governance based on approval from a pre-defined members list.
- __Addresslist Voting plugin__: enabling a pre-defined set of addresses to vote yes, no or abstain in a "one person, one vote" mode
- __Admin plugin__: enabling full access to an account needing to perform initial maintenance tasks without unnecessary overhead

Let's dive into more detail on each of these sections.

### Core Contracts

The *Core Contracts* describe how every DAO generated in the Aragon OSx protocol will be set up. It is extremely lean and by design and constitutes the most critical aspects of our architecture.

In a nutshell, each DAO is composed of 3 interconnecting components:

1. **The DAO contract:** The DAO contract is where the **core functionality** of the DAO lies. It is the contract in charge of:
    - Representing the identity of the DAO (ENS name, logo, description, other metadata)
    - Holding and managing the treasury assets
    - Executing arbitrary actions to:
        - transfer assets
        - call its own functions
        - call functions in external contracts
    - Providing general technical utilities like callback handling and others
2. **Permissions:** They are an integral part of any DAO and the center of our protocol architecture. The Permission manager **manages permissions for the DAO** by specifying which addresses hold a specific permission ID, needed to call certain functions on contracts associated with your DAO. The Permission manager lives inside the DAO contract.
3. **Plugins**: Any custom functionality can be added or removed through plugins, allowing you to **fully customize your DAO**. You'll find some base templates of plugins within the `plugins` folder of the *Core Contracts*. Some examples of plugins that DAOs could install are:
    - Governance (e.g., token voting, one-person one-vote)
    - Asset management (e.g., ERC-20 or NFT minting, token streaming, DeFi)
    - Membership (governing budget allowances, gating access, curating a member list)

The following graphic shows how an exemplary DAO setup, where the

![An examplary DAO setup](https://devs.aragon.org/assets/images/dao-plugin.drawio-7086d0911d25218097dae94665b1a7b1.svg)

An examplary DAO setup showing interactions between the three core contract pieces triggered by different user groups: The `DAO` and `PermissionManager` contract in blue and red, respectively, as well as two `Plugin` contracts in green. Bear in mind, the `DAO` and `Permission Manager` components both coexist within the same `DAO` contract. Function calls are visualized as black arrows and require the caller to hold a certain permission (red, dashed arrow). In this example, the permission manager determines whether the token voting plugin can execute actions on the DAO, a member can change its settings, or if an DeFi-related plugin is allowed to invest in a certain, external contract.

### Framework Contracts

In contrast, the *Framework Contracts* are in charge of creating an open ecosystem around DAOs and plugins. Starting with their respective registries and factories, the framework also includes the `PluginSetupProcessor`, designed to handle plugin installs, uninstalls, and updates upon a DAO's request.

- __Factories and Registries__
    - **The DAO Factory**: In charge of deploying instances of a new DAO based on the parameters given, including which plugins to install and additional metadata the DAO has (like a name, description, etc).
    - **The DAO Registry**: In charge of registering DAOs into our protocol so plugins can easily access all DAO instances within our protocol. It is also in charge of giving DAOs subdomains for easier access.
    - **The Plugin Factory**: A `PluginRepo` is the repository of versions for a given plugin. The `PluginRepoFactory` contract creates a `PluginRepo` instance for each plugin, so that plugins can update their versioning without complexity in a semantic way similar to the App Store.
    - **The Plugin Registry**: In charge of registering the `PluginRepo` addresses into our protocol so that DAOs can access all plugins published in the protocol.
- __Plugin Setup Processor__: The processor is the manager for plugins. It installs, uninstalls, and upgrades plugins for DAOs based on the instructions provided by the plugin setup.

For a more detailed description of each of these components, please visit our [Developer Portal](https://devs.aragon.org).

### Plugins

Each plugin consists of two key components:

- __The Plugin Logic__: contains the logic for each plugin; the main functionality the plugin extends for the DAO. Can be linked to other helper contracts if needed.
- __The Plugin Setup__: contains the installation, uninstallation, and upgrade instructions for a plugin into a DAO.

You can find all plugins built by the Aragon team [here](https://github.com/aragon/osx/tree/develop/packages/contracts/src/plugins).

### Connection between OSx, subgraph, and ethers.js packages

The [Aragon OSx contracts](https://github.com/aragon/osx/tree/develop/packages/contracts) emits events that get indexed within our `subgraph`. This `subgraph`, whose [source code can be found here](https://github.com/aragon/osx/tree/develop/packages/subgraph), is what then fuels the [Aragon SDK](https://github.com/aragon/sdk).

The [contract-ethers](https://github.com/aragon/osx/tree/develop/packages/contracts-ethers) package is the NPM package that provides `ethers.js` wrappers to use the [Aragon OSx contracts](https://github.com/aragon/osx/tree/develop/packages/contracts).

## Tests

You can find some [test DAOs here](https://github.com/aragon/osx/blob/develop/dummy_daos.json), if you’re looking to get started with testing.

To run tests, run these commands in the root folder in your terminal:

```bash
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
```

For faster runs of your tests and scripts, consider skipping `ts-node`'s type checking by setting the environment variable `TS_NODE_TRANSPILE_ONLY` to `1` in hardhat's environment.

For more details see [the documentation](https://hardhat.org/guides/typescript.html#performance-optimizations).

## Deployment

To deploy contracts, run these commands in your terminal:

```bash
npx hardhat run scripts/deploy.ts
TS_NODE_FILES=true npx ts-node scripts/deploy.ts
npx eslint '**/*.{js,ts}'
npx eslint '**/*.{js,ts}' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

You can find more details about [our deployment checklist here](https://github.com/aragon/osx/blob/develop/DEPLOYMENT_CHECKLIST.md).

## Releasing

To release a new version of the NPM packages and the contracts add one of these labels `release:patch`, `release:minor` and `release:major`.
This triggers the deployment of the contracts to the networks defined under `packages/contracts/networks.json`. Merges to `develop` triggers a release to testnets and merges to `main` releases to the mainnets.
The labels also indicate how the npm packages will be bumped to the next version:

| Label         | Version bump                                                                |
| ------------- | --------------------------------------------------------------------------- |
| release:patch | patch bump for `@aragon/core-contracts` and `@aragon/core-contracts-ethers` |
| release:minor | minor bump for `@aragon/core-contracts` and `@aragon/core-contracts-ethers` |
| release:major | major bump for `@aragon/core-contracts` and `@aragon/core-contracts-ethers` |

## Pull request commands

Certain actions can be triggered via a command to a pull request. To issue a command just comment on a pull request with one of these commands.

| Command                                      | Description                                                 |
| -------------------------------------------- | ----------------------------------------------------------- |
| `/mythx partial (quick \| standard \| deep)` | Scans the changed files for this pull request               |
| `/mythx full (quick \| standard \| deep)`    | Scans the all files for this pull request                   |
| `/release (patch \| minor \| major)`         | Adds the proper release label to this pull request          |
| `/subgraph (patch \| minor \| major)`        | Adds the proper subgraph release label to this pull request |
