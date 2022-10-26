// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IDAO} from "../../../dao/primitives/IDAO.sol";
import {PluginUUPSUpgradeable} from "../PluginUUPSUpgradeable.sol";

contract TestPlugin is PluginUUPSUpgradeable {
    bytes32 public constant DO_SOMETHING_PERMISSION_ID = keccak256("DO_SOMETHING_PERMISSION");

    function initialize(IDAO _dao) external initializer {
        __PluginUUPSUpgradeable_init(_dao);
    }

    function addPermissioned(uint256 _param1, uint256 _param2)
        external
        view
        auth(DO_SOMETHING_PERMISSION_ID)
        returns (uint256)
    {
        return _param1 + _param2;
    }

    function subPermissioned(uint256 _param1, uint256 _param2)
        external
        view
        auth(DO_SOMETHING_PERMISSION_ID)
        returns (uint256)
    {
        return _param1 - _param2;
    }

    function msgSender() external view returns (address) {
        return _msgSender();
    }
}
