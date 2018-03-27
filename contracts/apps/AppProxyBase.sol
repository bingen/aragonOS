pragma solidity 0.4.18;

import "./IAppProxy.sol";
import "./AppStorage.sol";
import "../common/DelegateProxy.sol";
import "../kernel/KernelStorage.sol";
import "../lib/zeppelin/token/ERC20.sol";


contract AppProxyBase is IAppProxy, AppStorage, DelegateProxy, KernelConstants {
    event ProxyDeposit(address sender, uint256 value);

    /**
    * @notice Send funds to default Vault. This contract should never receive funds,
    *         but in case it does, this function allows to recover them.
    * @param _token Token balance to be sent to Vault. ETH(0x0) for ether.
    */
    function transferToVault(address _token) external {
        address vault = kernel.getDefaultVault();
        require(isContract(vault));

        if (_token == ETH) {
            vault.transfer(address(this).balance);
        } else {
            uint256 amount = ERC20(_token).balanceOf(this);
            ERC20(_token).transfer(vault, amount);
        }
    }

    /**
    * @dev Initialize AppProxy
    * @param _kernel Reference to organization kernel for the app
    * @param _appId Identifier for app
    * @param _initializePayload Payload for call to be made after setup to initialize
    */
    function AppProxyBase(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public {
        kernel = _kernel;
        appId = _appId;

        // Implicit check that kernel is actually a Kernel
        // The EVM doesn't actually provide a way for us to make sure, but we can force a revert to
        // occur if the kernel is set to 0x0 or a non-code address when we try to call a method on
        // it.
        address appCode = getAppBase(appId);

        // If initialize payload is provided, it will be executed
        if (_initializePayload.length > 0) {
            require(isContract(appCode));
            // Cannot make delegatecall as a delegateproxy.delegatedFwd as it
            // returns ending execution context and halts contract deployment
            require(appCode.delegatecall(_initializePayload));
        }
    }

    function getAppBase(bytes32 _appId) internal view returns (address) {
        return kernel.getApp(keccak256(APP_BASES_NAMESPACE, _appId));
    }

    function () payable public {
        // all calls except for send or transfer
        if (msg.gas > 10000) {
            address target = getCode();
            require(target != 0); // if app code hasn't been set yet, don't call
            delegatedFwd(target, msg.data);
        }

        // send / transfer
        require(msg.value > 0 && msg.data.length == 0);
        ProxyDeposit(msg.sender, msg.value);
    }
}
