/*
 * SPDX-License-Identifier:    MIT
 */

pragma solidity ^0.4.24;

import "./IAgreement.sol";
import "./IDisputable.sol";
import "../AragonApp.sol";
import "../../lib/token/ERC20.sol";
import "../../lib/math/SafeMath64.sol";


contract DisputableAragonApp is IDisputable, AragonApp {
    /* Validation errors */
    string internal constant ERROR_SENDER_NOT_AGREEMENT = "DISPUTABLE_SENDER_NOT_AGREEMENT";
    string internal constant ERROR_AGREEMENT_STATE_INVALID = "DISPUTABLE_AGREEMENT_STATE_INVAL";

    // This role is used to protect who can challenge actions in derived Disputable apps. However, it is not required
    // to be validated in the app itself as the connected Agreement is responsible for performing the check on a challenge.
    // bytes32 public constant CHALLENGE_ROLE = keccak256("CHALLENGE_ROLE");
    bytes32 public constant CHALLENGE_ROLE = 0xef025787d7cd1a96d9014b8dc7b44899b8c1350859fb9e1e05f5a546dd65158d;

    // bytes32 public constant SET_AGREEMENT_ROLE = keccak256("SET_AGREEMENT_ROLE");
    bytes32 public constant SET_AGREEMENT_ROLE = 0x8dad640ab1b088990c972676ada708447affc660890ec9fc9a5483241c49f036;

    // bytes32 internal constant AGREEMENT_POSITION = keccak256("aragonOS.appStorage.agreement");
    bytes32 internal constant AGREEMENT_POSITION = 0x6dbe80ccdeafbf5f3fff5738b224414f85e9370da36f61bf21c65159df7409e9;

    event AgreementSet(IAgreement indexed agreement);

    modifier onlyAgreement() {
        require(address(_getAgreement()) == msg.sender, ERROR_SENDER_NOT_AGREEMENT);
        _;
    }

    /**
    * @notice Challenge disputable action #`_disputableActionId`
    * @dev This hook must be implemented by Disputable apps. However, we are already providing a base method to make sure it is safely
    *      override by the developer. As you can see, this base implementation simply adds the `onlyAgreement` modifier and calls an
    *      internal abstract implementation of the hook that must be implemented by the developer.
    * @param _disputableActionId Identification number of the disputable action to be challenged
    * @param _challengeId Identification number of the challenge in the context of the Agreement
    * @param _challenger Address challenging the disputable
    */
    function onDisputableActionChallenged(uint256 _disputableActionId, uint256 _challengeId, address _challenger) external onlyAgreement {
        _onDisputableActionChallenged(_disputableActionId, _challengeId, _challenger);
    }

    /**
    * @notice Allow disputable action #`_disputableActionId`
    * @dev This hook must be implemented by Disputable apps. However, we are already providing a base method to make sure it is safely
    *      override by the developer. As you can see, this base implementation simply adds the `onlyAgreement` modifier and calls an
    *      internal abstract implementation of the hook that must be implemented by the developer.
    * @param _disputableActionId Identification number of the disputable action to be allowed
    */
    function onDisputableActionAllowed(uint256 _disputableActionId) external onlyAgreement {
        _onDisputableActionAllowed(_disputableActionId);
    }

    /**
    * @notice Reject disputable action #`_disputableActionId`
    * @dev This hook must be implemented by Disputable apps. However, we are already providing a base method to make sure it is safely
    *      override by the developer. As you can see, this base implementation simply adds the `onlyAgreement` modifier and calls an
    *      internal abstract implementation of the hook that must be implemented by the developer.
    * @param _disputableActionId Identification number of the disputable action to be rejected
    */
    function onDisputableActionRejected(uint256 _disputableActionId) external onlyAgreement {
        _onDisputableActionRejected(_disputableActionId);
    }

    /**
    * @notice Void disputable action #`_disputableActionId`
    * @dev This hook must be implemented by Disputable apps. However, we are already providing a base method to make sure it is safely
    *      override by the developer. As you can see, this base implementation simply adds the `onlyAgreement` modifier and calls an
    *      internal abstract implementation of the hook that must be implemented by the developer.
    * @param _disputableActionId Identification number of the disputable action to be voided
    */
    function onDisputableActionVoided(uint256 _disputableActionId) external onlyAgreement {
        _onDisputableActionVoided(_disputableActionId);
    }

    /**
    * @notice `_agreement != 0 ? 'Set Agreement to ' + _agreement : 'Unset Agreement'`
    * @param _agreement Agreement instance to be set
    */
    function setAgreement(IAgreement _agreement) external auth(SET_AGREEMENT_ROLE) {
        IAgreement agreement = _getAgreement();
        bool isAgreementUnset = agreement == IAgreement(0);
        require(isAgreementUnset || (!isAgreementUnset && _agreement == IAgreement(0)), ERROR_AGREEMENT_STATE_INVALID);

        AGREEMENT_POSITION.setStorageAddress(address(_agreement));
        emit AgreementSet(_agreement);
    }

    /**
    * @dev Tell the agreement linked to the disputable instance
    * @return Agreement linked to the disputable instance
    */
    function getAgreement() external view returns (IAgreement) {
        return _getAgreement();
    }

    /**
    * @dev Internal implementation of the `onDisputableActionChallenged` hook
    * @param _disputableActionId Identification number of the disputable action to be challenged
    * @param _challengeId Identification number of the challenge in the context of the Agreement
    * @param _challenger Address challenging the disputable
    */
    function _onDisputableActionChallenged(uint256 _disputableActionId, uint256 _challengeId, address _challenger) internal;

    /**
    * @dev Internal implementation of the `onDisputableActionRejected` hook
    * @param _disputableActionId Identification number of the disputable action to be rejected
    */
    function _onDisputableActionRejected(uint256 _disputableActionId) internal;

    /**
    * @dev Internal implementation of the `onDisputableActionAllowed` hook
    * @param _disputableActionId Identification number of the disputable action to be allowed
    */
    function _onDisputableActionAllowed(uint256 _disputableActionId) internal;

    /**
    * @dev Internal implementation of the `onDisputableActionVoided` hook
    * @param _disputableActionId Identification number of the disputable action to be voided
    */
    function _onDisputableActionVoided(uint256 _disputableActionId) internal;

    /**
    * @dev Create a new action in the agreement
    * @param _disputableActionId Identification number of the disputable action in the context of the disputable
    * @param _context Link to a human-readable text giving context for the given action
    * @param _submitter Address of the user that has submitted the action
    * @return Unique identification number for the created action in the context of the agreement
    */
    function _newAgreementAction(uint256 _disputableActionId,  bytes _context, address _submitter) internal returns (uint256) {
        IAgreement agreement = _ensureAgreement();
        return agreement.newAction(_disputableActionId, _context, _submitter);
    }

    /**
    * @dev Close action in the agreement
    * @param _actionId Identification number of the disputable action in the context of the agreement
    */
    function _closeAgreementAction(uint256 _actionId) internal {
        IAgreement agreement = _ensureAgreement();
        agreement.closeAction(_actionId);
    }

    /**
    * @dev Tell the agreement linked to the disputable instance
    * @return Agreement linked to the disputable instance
    */
    function _getAgreement() internal view returns (IAgreement) {
        return IAgreement(AGREEMENT_POSITION.getStorageAddress());
    }

    /**
    * @dev Tell the agreement linked to the disputable instance
    * @return Agreement linked to the disputable instance
    */
    function _ensureAgreement() internal view returns (IAgreement) {
        IAgreement agreement = _getAgreement();
        require(agreement != IAgreement(0), ERROR_AGREEMENT_STATE_INVALID);
        return agreement;
    }
}
