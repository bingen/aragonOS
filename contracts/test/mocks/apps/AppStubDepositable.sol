pragma solidity 0.4.24;

import "../../../apps/AragonApp.sol";
import "../../../apps/UnsafeAragonApp.sol";


contract AppStubDepositable is AragonApp {
    function () external payable {
    }

    function initialize() onlyInit public {
        initialized();
    }

    function enableDeposits() external {
    }
}

contract UnsafeAppStubDepositable is AppStubDepositable, UnsafeAragonApp {
    constructor(IKernel _kernel) public {
        setKernel(_kernel);
    }
}
