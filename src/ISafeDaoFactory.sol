// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISafeDaoFactory {
    function deploy(bytes32 salt, bytes memory initializer) external returns (address proxy);
}
