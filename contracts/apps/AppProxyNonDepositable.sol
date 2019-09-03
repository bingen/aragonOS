pragma solidity 0.4.24;

import "./AppProxyBase.sol";
import "../common/NonDepositableDelegateProxy.sol";


contract AppProxyNonDepositable is AppProxyBase, NonDepositableDelegateProxy {
    /**
    * @dev Initialize AppProxyNonDepositable
    * @param _kernel Reference to organization kernel for the app
    * @param _appId Identifier for app
    * @param _initializePayload Payload for call to be made after setup to initialize
    */
    constructor(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
        AppProxyBase(_kernel, _appId, _initializePayload)
        public
    {
    }
}
