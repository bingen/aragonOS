pragma solidity 0.4.24;

import "../../../apps/UnsafeAragonApp.sol";


contract VaultMock is UnsafeAragonApp {
    event LogFund(address sender, uint256 amount);

    function initialize() external {
        initialized();
    }

    function () external payable {
        emit LogFund(msg.sender, msg.value);
    }
}
