pragma solidity 0.4.24;

import "../../../../common/IForwarder.sol";
import "../../../../apps/disputable/DisputableAragonApp.sol";


contract DisputableAppMock is DisputableAragonApp {
    bytes4 public constant ERC165_INTERFACE = ERC165_INTERFACE_ID;
    bytes4 public constant DISPUTABLE_INTERFACE = DISPUTABLE_INTERFACE_ID;

    event DisputableChallenged(uint256 indexed id);
    event DisputableAllowed(uint256 indexed id);
    event DisputableRejected(uint256 indexed id);
    event DisputableVoided(uint256 indexed id);

    function initialize() external {
        initialized();
    }

    function getDisputableAction(uint256 /*_disputableActionId*/) external view returns (uint64 endDate, bool challenged, bool finished) {
        return (uint64(0), false, false);
    }

    function canChallenge(uint256 /*_disputableActionId*/) external view returns (bool) {
        return true;
    }

    function canClose(uint256 /*_disputableActionId*/) external view returns (bool) {
        return true;
    }

    function interfaceID() external pure returns (bytes4) {
        IDisputable iDisputable;
        return iDisputable.setAgreement.selector ^
            iDisputable.onDisputableActionChallenged.selector ^
            iDisputable.onDisputableActionAllowed.selector ^
            iDisputable.onDisputableActionRejected.selector ^
            iDisputable.onDisputableActionVoided.selector ^
            iDisputable.getAgreement.selector ^
            iDisputable.getDisputableAction.selector ^
            iDisputable.canChallenge.selector ^
            iDisputable.canClose.selector ^
            iDisputable.appId.selector;
    }

    function erc165interfaceID() external pure returns (bytes4) {
        ERC165 erc165;
        return erc165.supportsInterface.selector;
    }

    /**
    * @dev Challenge an entry
    * @param _id Identification number of the entry to be challenged
    */
    function _onDisputableActionChallenged(uint256 _id, uint256 /* _challengeId */, address /* _challenger */) internal {
        emit DisputableChallenged(_id);
    }

    /**
    * @dev Allow an entry
    * @param _id Identification number of the entry to be allowed
    */
    function _onDisputableActionAllowed(uint256 _id) internal {
        emit DisputableAllowed(_id);
    }

    /**
    * @dev Reject an entry
    * @param _id Identification number of the entry to be rejected
    */
    function _onDisputableActionRejected(uint256 _id) internal {
        emit DisputableRejected(_id);
    }

    /**
    * @dev Void an entry
    * @param _id Identification number of the entry to be voided
    */
    function _onDisputableActionVoided(uint256 _id) internal {
        emit DisputableVoided(_id);
    }
}
