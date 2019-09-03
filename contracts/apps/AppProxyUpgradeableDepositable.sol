pragma solidity 0.4.24;

import "./AppProxyUpgradeableBase.sol";
import "./AppProxyDepositable.sol";


contract AppProxyUpgradeableDepositable is AppProxyUpgradeableBase, AppProxyDepositable {
    /**
     * @dev Initialize AppProxyUpgradeable (makes it an upgradeable Aragon app)
     * @param _kernel Reference to organization kernel for the app
     * @param _appId Identifier for app
     * @param _initializePayload Payload for call to be made after setup to initialize
     */
    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
        AppProxyDepositable(_kernel, _appId, _initializePayload)
        public // solium-disable-line visibility-first
    {
        // solium-disable-previous-line no-empty-blocks
    }
}
