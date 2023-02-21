// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {PermissionLib} from "../../../core/permission/PermissionLib.sol";
import {createERC1967Proxy} from "../../../utils/Proxy.sol";
import {PluginRepoRegistry} from "./PluginRepoRegistry.sol";
import {PluginRepo} from "./PluginRepo.sol";

/// @title PluginRepoFactory
/// @author Aragon Association - 2022-2023
/// @notice This contract creates `PluginRepo` proxies and registers them on an `PluginRepoRegistry` contract.
contract PluginRepoFactory {
    /// @notice The Aragon plugin registry contract.
    PluginRepoRegistry public pluginRepoRegistry;

    /// @notice The address of the `PluginRepo` base contract.
    address public pluginRepoBase;

    // @notice Thrown if the plugin repository subdomain is empty.
    error EmptyPluginRepoSubdomain();

    /// @notice Initializes the addresses of the Aragon plugin registry and `PluginRepo` base contract to proxy to.
    /// @param _pluginRepoRegistry The aragon plugin registry address.
    constructor(PluginRepoRegistry _pluginRepoRegistry) {
        pluginRepoRegistry = _pluginRepoRegistry;

        pluginRepoBase = address(new PluginRepo());
    }

    /// @notice Creates a plugin repository proxy pointing to the `pluginRepoBase` implementation and registers it in the Aragon plugin registry.
    /// @param _subdomain The plugin repository subdomain.
    /// @param _initialOwner The plugin maintainer address.
    function createPluginRepo(
        string calldata _subdomain,
        address _initialOwner
    ) external returns (PluginRepo) {
        return _createPluginRepo(_subdomain, _initialOwner);
    }

    /// @notice Creates and registers a `PluginRepo` with an ENS subdomain and publishes an initial version `1.0`.
    /// @param _subdomain The plugin repository subdomain.
    /// @param _pluginSetup The plugin factory contract associated with the plugin version.
    /// @param _maintainer The plugin maintainer address.
    /// @param _releaseMetadata The release metadata URI.
    /// @param _buildMetadata The build metadata URI.
    /// @dev After the creation of the `PluginRepo` and release of the first version by the factory, ownership is transferred to the `_maintainer` address.
    function createPluginRepoWithFirstVersion(
        string calldata _subdomain,
        address _pluginSetup,
        address _maintainer,
        bytes memory _releaseMetadata,
        bytes memory _buildMetadata
    ) external returns (PluginRepo pluginRepo) {
        // Sets `address(this)` as initial owner which is later replaced with the maintainer address.
        pluginRepo = _createPluginRepo(_subdomain, _maintainer);

        pluginRepo.createVersion(1, _pluginSetup, _buildMetadata, _releaseMetadata);
    }



    /// @notice Internal method creating a `PluginRepo` via the [ERC-1967](https://eips.ethereum.org/EIPS/eip-1967) proxy pattern from the provided base contract and registering it in the Aragon plugin registry.
    /// @param _subdomain The plugin repository subdomain.
    /// @param _initialOwner The initial owner address.
    function _createPluginRepo(
        string calldata _subdomain,
        address _initialOwner
    ) internal returns (PluginRepo pluginRepo) {
        if (!(bytes(_subdomain).length > 0)) {
            revert EmptyPluginRepoSubdomain();
        }

        pluginRepo = PluginRepo(
            createERC1967Proxy(
                pluginRepoBase,
                abi.encodeWithSelector(PluginRepo.initialize.selector, _initialOwner)
            )
        );

        pluginRepoRegistry.registerPluginRepo(_subdomain, address(pluginRepo));
    }
}
