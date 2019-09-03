pragma solidity 0.4.24;

import "./AppProxyBase.sol";

contract AppProxyUpgradeableBase is AppProxyBase {
    /**
     * @dev ERC897, the address the proxy would delegate calls to
     */
    function implementation() public view returns (address) {
        return getAppBase(appId());
    }

    /**
     * @dev ERC897, whether it is a forwarding (1) or an upgradeable (2) proxy
     */
    function proxyType() public pure returns (uint256 proxyTypeId) {
        return UPGRADEABLE;
    }
}
