// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {Permission, PluginManager, PluginManagerLib} from "../plugin/PluginManager.sol";
import {PluginUUPSUpgradableMock} from "../test/PluginUUPSUpgradableMock.sol";

contract PluginManagerMock is PluginManager {
    using PluginManagerLib for PluginManagerLib.Data;

    PluginUUPSUpgradableMock public helperBase;
    PluginUUPSUpgradableMock public pluginBase;

    address private constant NO_ORACLE = address(0);

    constructor() {
        helperBase = new PluginUUPSUpgradableMock();
        pluginBase = new PluginUUPSUpgradableMock();
    }

    function _getInstallInstruction(PluginManagerLib.Data memory installation)
        internal
        view
        override
        returns (PluginManagerLib.Data memory)
    {
        address helperAddr = installation.addHelper(address(helperBase), bytes(""));

        address pluginAddr = installation.addPlugin(address(pluginBase), bytes(""));

        installation.addPermission(
            Permission.Operation.Grant,
            installation.dao,
            pluginAddr,
            NO_ORACLE,
            keccak256("EXEC_PERMISSION")
        );

        installation.addPermission(
            Permission.Operation.Grant,
            pluginAddr,
            helperAddr,
            NO_ORACLE,
            keccak256("SETTINGS_PERMISSION")
        );

        return installation;
    }

    function _getUpdateInstruction(
        address proxy,
        uint16[3] calldata oldVersion,
        PluginManagerLib.Data memory update
    ) internal view override returns (PluginManagerLib.Data memory, bytes memory initData) {
        initData = bytes("");

        address helperAddr = update.addHelper(address(helperBase), bytes(""));

        update.addPermission(
            Permission.Operation.Revoke,
            update.dao,
            proxy,
            NO_ORACLE,
            keccak256("EXEC_PERMISSION")
        );

        update.addPermission(
            Permission.Operation.Grant,
            helperAddr,
            proxy,
            NO_ORACLE,
            keccak256("GRANT_PERMISSION")
        );

        return (update, initData);
    }

    function getImplementationAddress() public view virtual override returns (address) {
        return address(pluginBase);
    }

    function deployABI() external view virtual override returns (string memory) {
        return "";
    }
}
