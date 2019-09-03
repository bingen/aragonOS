pragma solidity 0.4.24;

import "../apps/AppProxyUpgradeableBase.sol";
import "../apps/AppProxyUpgradeableDepositable.sol";
import "../apps/AppProxyUpgradeableNonDepositable.sol";
import "../apps/AppProxyPinnedBase.sol";
import "../apps/AppProxyPinnedDepositable.sol";
import "../apps/AppProxyPinnedNonDepositable.sol";


contract AppProxyFactory {
    event NewAppProxy(address proxy, bool isUpgradeable, bytes32 appId);

    /**
    * @notice Create a new upgradeable app instance on `_kernel` with identifier `_appId`
    * @param _kernel App's Kernel reference
    * @param _appId Identifier for app
    * @return AppProxyUpgradeable
    */
    function newAppProxy(IKernel _kernel, bytes32 _appId) public returns (AppProxyUpgradeableBase) {
        return newAppProxy(_kernel, _appId, new bytes(0), false);
    }

    /**
    * @notice Create a new upgradeable app instance on `_kernel` with identifier `_appId` and initialization payload `_initializePayload`
    * @param _kernel App's Kernel reference
    * @param _appId Identifier for app
    * @return AppProxyUpgradeable
    */
    function newAppProxy(IKernel _kernel, bytes32 _appId, bytes _initializePayload, bool _depositable) public returns (AppProxyUpgradeableBase) {
        AppProxyUpgradeableBase proxy;
        if (_depositable) {
            proxy = new AppProxyUpgradeableDepositable(_kernel, _appId, _initializePayload);
        } else {
            proxy = new AppProxyUpgradeableNonDepositable(_kernel, _appId, _initializePayload);
        }
        emit NewAppProxy(address(proxy), true, _appId);
        return proxy;
    }

    /**
    * @notice Create a new pinned app instance on `_kernel` with identifier `_appId`
    * @param _kernel App's Kernel reference
    * @param _appId Identifier for app
    * @return AppProxyPinned
    */
    function newAppProxyPinned(IKernel _kernel, bytes32 _appId) public returns (AppProxyPinnedBase) {
        return newAppProxyPinned(_kernel, _appId, new bytes(0), false);
    }

    /**
    * @notice Create a new pinned app instance on `_kernel` with identifier `_appId` and initialization payload `_initializePayload`
    * @param _kernel App's Kernel reference
    * @param _appId Identifier for app
    * @param _initializePayload Proxy initialization payload
    * @return AppProxyPinned
    */
    function newAppProxyPinned(IKernel _kernel, bytes32 _appId, bytes _initializePayload, bool _depositable) public returns (AppProxyPinnedBase) {
        AppProxyPinnedBase proxy;
        if (_depositable) {
            proxy = new AppProxyPinnedDepositable(_kernel, _appId, _initializePayload);
        } else {
            proxy = new AppProxyPinnedNonDepositable(_kernel, _appId, _initializePayload);
        }
        emit NewAppProxy(address(proxy), false, _appId);
        return proxy;
    }
}
