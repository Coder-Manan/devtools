// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

/**
 * @title ONFT721MsgCodec
 * @notice Library for encoding and decoding ONFT721 LayerZero messages.
 */
library ONFT721URIStorageMsgCodec {
    uint8 private constant SEND_TO_OFFSET = 32;
    uint8 private constant TOKEN_ID_OFFSET = 64;
    uint8 private constant TOKEN_URI_LENGTH_OFFSET = 96;

    /**
     * @dev Encodes an ONFT721 LayerZero message payload.
     * @param _sendTo The recipient address.
     * @param _tokenId The ID of the token to transfer.
     * @param _tokenURI URI of the token to transfer
     * @param _composeMsg The composed payload.
     * @return payload The encoded message payload.
     * @return hasCompose A boolean indicating whether the message payload contains a composed payload.
     */
    function encode(
        bytes32 _sendTo,
        uint256 _tokenId,
        string memory _tokenURI,
        bytes memory _composeMsg
    ) internal view returns (bytes memory payload, bool hasCompose) {
        hasCompose = _composeMsg.length > 0;
        payload = hasCompose
            ? abi.encodePacked(_sendTo, _tokenId, uint256(bytes(_tokenURI).length), _tokenURI, addressToBytes32(msg.sender), _composeMsg)
            : abi.encodePacked(_sendTo, _tokenId, uint256(bytes(_tokenURI).length), _tokenURI);
    }

    /**
     * @dev Decodes sendTo from the ONFT LayerZero message.
     * @param _msg The message.
     * @return The recipient address in bytes32 format.
     */
    function sendTo(bytes calldata _msg) internal pure returns (bytes32) {
        return bytes32(_msg[:SEND_TO_OFFSET]);
    }

    /**
     * @dev Decodes tokenId from the ONFT LayerZero message.
     * @param _msg The message.
     * @return The ID of the tokens to transfer.
     */
    function tokenId(bytes calldata _msg) internal pure returns (uint256) {
        return uint256(bytes32(_msg[SEND_TO_OFFSET:TOKEN_ID_OFFSET]));
    }

    /**
    * @dev Decodes tokenURI from the ONFT LayerZero message
    * @param _msg The message.
    * @return The URI of the token
    */
    function tokenURI(bytes calldata _msg) internal pure returns (string memory) {
        // get the length of the string by decoding string length
        uint256 tokenURILength = uint256(bytes32(_msg[TOKEN_ID_OFFSET:TOKEN_URI_LENGTH_OFFSET]));
        // get these many bytes after the string length, decode to string and return that
        return string(_msg[TOKEN_URI_LENGTH_OFFSET: tokenURILength]);
    }

    /**
     * @dev Decodes whether there is a composed payload.
     * @param _msg The message.
     * @return A boolean indicating whether the message has a composed payload.
     */
    function isComposed(bytes calldata _msg) internal pure returns (bool) {
        return _msg.length > TOKEN_ID_OFFSET;
    }

    /**
     * @dev Decodes the composed message.
     * @param _msg The message.
     * @return The composed message.
     */
    function composeMsg(bytes calldata _msg) internal pure returns (bytes memory) {
        return _msg[TOKEN_ID_OFFSET:];
    }

    /**
     * @dev Converts an address to bytes32.
     * @param _addr The address to convert.
     * @return The bytes32 representation of the address.
     */
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    /**
     * @dev Converts bytes32 to an address.
     * @param _b The bytes32 value to convert.
     * @return The address representation of bytes32.
     */
    function bytes32ToAddress(bytes32 _b) internal pure returns (address) {
        return address(uint160(uint256(_b)));
    }
}
