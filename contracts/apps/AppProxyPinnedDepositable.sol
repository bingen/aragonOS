pragma solidity 0.4.24;

import "./AppProxyPinnedBase.sol";
import "./AppProxyDepositable.sol";


contract AppProxyPinnedDepositable is AppProxyPinnedBase, AppProxyDepositable {
    /**
     * @dev Initialize AppProxyPinned (makes it an un-upgradeable Aragon app)
     * @param _kernel Reference to organization kernel for the app
     * @param _appId Identifier for app
     * @param _initializePayload Payload for call to be made after setup to initialize
     */
    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
        AppProxyDepositable(_kernel, _appId, _initializePayload)
        public // solium-disable-line visibility-first
    {
        setPinnedCode(getAppBase(_appId));
        require(isContract(pinnedCode()));
    }
}
