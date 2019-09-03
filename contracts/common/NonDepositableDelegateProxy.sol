pragma solidity 0.4.24;

import "./DelegateProxy.sol";


contract NonDepositableDelegateProxy is DelegateProxy {
    function () external payable {
        // send / transfer
        if (gasleft() < FWD_GAS_LIMIT) {
            revert();
        } else { // all calls except for send or transfer
            address target = implementation();
            delegatedFwd(target, msg.data);
        }
    }
}
