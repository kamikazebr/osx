// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {Permission, PluginManagerSimple, PluginManagerClonable, PluginManagerUUPSUpgradeable, PluginManagerTransparent} from "../../PluginManager.sol";
import {MultiplyHelper} from "./MultiplyHelper.sol";
import {CounterV1} from "./CounterV1.sol";

contract CounterV1PluginManager is PluginManagerSimple {
    using Clones for address;

    MultiplyHelper public multiplyHelperBase;
    CounterV1 public counterBase;

    address private constant NO_ORACLE = address(0);

    constructor() {
        multiplyHelperBase = new MultiplyHelper();
        counterBase = new CounterV1();
    }

    function deploy(address dao, bytes memory data)
        public
        virtual
        override
        returns (address deployedPlugin, Permission.ItemMultiTarget[] memory permissions)
    {
        // Decode the parameters from the UI
        (address _multiplyHelper, uint256 _num) = abi.decode(data, (address, uint256));

        address multiplyHelper = _multiplyHelper;

        // Allocate space for requested permission that will be applied on this plugin installation.
        permissions = new Permission.ItemMultiTarget[](_multiplyHelper == address(0) ? 3 : 2);

        if (_multiplyHelper == address(0)) {
            // Deploy some internal helper contract for the Plugin
            multiplyHelper = address(multiplyHelperBase).clone();
            MultiplyHelper(multiplyHelper).initialize(dao); // DEVELOPER HAS TO REMEMBER THIS => ACCEPTABLE
        }

        // Encode the parameters that will be passed to initialize() on the Plugin
        bytes memory initData = abi.encodeWithSelector(
            bytes4(keccak256("initialize(address,address,uint256)")),
            dao,
            multiplyHelper,
            _num
        );

        // Deploy the Plugin itself, make it point to the implementation and
        // pass it the initialization params
        deployedPlugin = address(new ERC1967Proxy(getImplementationAddress(), initData));

        // Allows plugin Count to call execute on DAO
        permissions[0] = Permission.ItemMultiTarget(
            Permission.Operation.Grant,
            dao,
            deployedPlugin,
            NO_ORACLE,
            keccak256("EXEC_PERMISSION")
        );

        // Allows DAO to call Multiply on plugin Count
        permissions[1] = Permission.ItemMultiTarget(
            Permission.Operation.Grant,
            deployedPlugin,
            dao,
            NO_ORACLE,
            counterBase.MULTIPLY_PERMISSION_ID()
        );

        // MultiplyHelper could be something that dev already has it from outside
        // which mightn't be a aragon plugin. It's dev's responsibility to do checks
        // and risk whether or not to still set the permission.
        if (_multiplyHelper == address(0)) {
            // Allows Count plugin to call MultiplyHelper's multiply function.
            permissions[2] = Permission.ItemMultiTarget(
                Permission.Operation.Grant,
                multiplyHelper,
                deployedPlugin,
                NO_ORACLE,
                multiplyHelperBase.MULTIPLY_PERMISSION_ID()
            );
        }
    }

    function deployABI() external view virtual override returns (string memory) {
        return "(address multiplyHelper, uint num)";
    }
}

contract CounterV1PluginManager_C is PluginManagerClonable {
    MultiplyHelper public multiplyHelperBase;
    CounterV1 public counterBase;

    address private constant NO_ORACLE = address(0);

    constructor() {
        multiplyHelperBase = new MultiplyHelper();
        counterBase = new CounterV1();
    }

    // Overriding the init data passed to the Plugin initialization
    function setupPreHook(address dao, bytes memory initData)
        public
        returns (bytes memory pluginInitData, bytes memory setupHookInitData)
    {
        (address _multiplyHelper, uint256 _num) = abi.decode(init, (address, uint256));

        // Encode the parameters that will be passed to initialize() on the Plugin
        pluginInitData = abi.encodeWithSelector(
            bytes4(keccak256("initialize(address,address,uint256)")),
            dao,
            multiplyHelper,
            _num
        );
        setupHookInitData = initData;
    }

    function setupHook(
        address dao,
        PluginClones deployedPlugin,
        bytes memory initData
    ) public virtual override returns (Permission.ItemMultiTarget[] memory permissions) {
        // Decode the parameters from the UI
        (address _multiplyHelper, uint256 _num) = abi.decode(initData, (address, uint256));

        address multiplyHelper = _multiplyHelper;

        // Allocate space for requested permission that will be applied on this plugin installation.
        permissions = new Permission.ItemMultiTarget[](_multiplyHelper == address(0) ? 3 : 2);

        if (_multiplyHelper == address(0)) {
            // Deploy some internal helper contract for the Plugin
            multiplyHelper = address(multiplyHelperBase).clone();
            MultiplyHelper(multiplyHelper).initialize(dao);
        }

        // Allows plugin Count to call execute on DAO
        permissions[0] = Permission.ItemMultiTarget(
            Permission.Operation.Grant,
            dao,
            deployedPlugin,
            NO_ORACLE,
            keccak256("EXEC_PERMISSION")
        );

        // Allows DAO to call Multiply on plugin Count
        permissions[1] = Permission.ItemMultiTarget(
            Permission.Operation.Grant,
            deployedPlugin,
            dao,
            NO_ORACLE,
            counterBase.MULTIPLY_PERMISSION_ID()
        );

        // MultiplyHelper could be something that dev already has it from outside
        // which mightn't be a aragon plugin. It's dev's responsibility to do checks
        // and risk whether or not to still set the permission.
        if (_multiplyHelper == address(0)) {
            // Allows Count plugin to call MultiplyHelper's multiply function.
            permissions[2] = Permission.ItemMultiTarget(
                Permission.Operation.Grant,
                multiplyHelper,
                deployedPlugin,
                NO_ORACLE,
                multiplyHelperBase.MULTIPLY_PERMISSION_ID()
            );
        }
    }

    function deployABI() external view virtual override returns (string memory) {
        return "(address multiplyHelper, uint num)";
    }
}

contract CounterV1PluginManager_U is PluginManagerUUPSUpgradeable {
    using Clones for address;

    MultiplyHelper public multiplyHelperBase;
    CounterV1 public counterBase;

    address private constant NO_ORACLE = address(0);

    constructor() {
        multiplyHelperBase = new MultiplyHelper();
        counterBase = new CounterV1();
    }

    // Overriding the init data passed to the Plugin initialization
    function setupPreHook(address dao, bytes memory _init)
        public
        returns (bytes memory pluginInitData, bytes memory setupHookInitData)
    {
        (address _multiplyHelper, uint256 _num) = abi.decode(init, (address, uint256));

        // Encode the parameters that will be passed to initialize() on the Plugin
        pluginInitData = abi.encodeWithSelector(
            bytes4(keccak256("initialize(address,address,uint256)")),
            dao,
            multiplyHelper,
            _num
        );
        setupHookInitData = initData;
    }

    // Explicitly deploy any internal helpers
    function setupHook(
        address dao,
        PluginUUPSUpgradeable deployedPlugin,
        bytes memory init
    ) public virtual override returns (Permission.ItemMultiTarget[] memory permissions) {
        // Decode the parameters from the UI
        (address _multiplyHelper, uint256 _num) = abi.decode(init, (address, uint256));

        address multiplyHelper = _multiplyHelper;

        // Allocate space for requested permission that will be applied on this plugin installation.
        permissions = new Permission.ItemMultiTarget[](_multiplyHelper == address(0) ? 3 : 2);

        if (_multiplyHelper == address(0)) {
            // Deploy some internal helper contract for the Plugin
            multiplyHelper = address(multiplyHelperBase).clone();
            MultiplyHelper(multiplyHelper).initialize(dao);
        }

        // Allows plugin Count to call execute on DAO
        permissions[0] = Permission.ItemMultiTarget(
            Permission.Operation.Grant,
            dao,
            deployedPlugin,
            NO_ORACLE,
            keccak256("EXEC_PERMISSION")
        );

        // Allows DAO to call Multiply on plugin Count
        permissions[1] = Permission.ItemMultiTarget(
            Permission.Operation.Grant,
            deployedPlugin,
            dao,
            NO_ORACLE,
            counterBase.MULTIPLY_PERMISSION_ID()
        );

        // MultiplyHelper could be something that dev already has it from outside
        // which mightn't be a aragon plugin. It's dev's responsibility to do checks
        // and risk whether or not to still set the permission.
        if (_multiplyHelper == address(0)) {
            // Allows Count plugin to call MultiplyHelper's multiply function.
            permissions[2] = Permission.ItemMultiTarget(
                Permission.Operation.Grant,
                multiplyHelper,
                deployedPlugin,
                NO_ORACLE,
                multiplyHelperBase.MULTIPLY_PERMISSION_ID()
            );
        }
    }

    function deployABI() external view virtual override returns (string memory) {
        return "(address multiplyHelper, uint num)";
    }
}

//////////////////////////////////////////////////////

contract TestCounterV1Manager is CounterV1PluginManager {
    event PluginDeployed(address plugin, Permission.ItemMultiTarget[] permissions);

    function deploy(address dao, bytes memory data)
        public
        override
        returns (address plugin, Permission.ItemMultiTarget[] memory permissions)
    {
        (plugin, permissions) = super.deploy(dao, data);

        emit PluginDeployed(plugin, permissions);
    }
}
