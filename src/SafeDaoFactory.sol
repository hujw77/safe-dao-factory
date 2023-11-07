// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ICREATE3Factory} from "create3-deploy/src/ICREATE3Factory.sol";
import {IGnosisSafeProxyFactory} from "./IGnosisSafeProxyFactory.sol";

contract SafeDaoFactory {
    event ProxyCreation(address proxy, address singleton);

    address public immutable CREATE3_FACTORY;
    address public immutable SAFE_FACTORY;
    address public immutable SAFE_SINGLETON;

    constructor(address c3, address safe, address singleton) {
        CREATE3_FACTORY = c3;
        SAFE_FACTORY = safe;
        SAFE_SINGLETON = singleton;
    }

    function deploy(bytes32 salt, bytes memory initializer) external returns (address proxy) {
        bytes memory creationCode = IGnosisSafeProxyFactory(SAFE_FACTORY).proxyCreationCode();
        bytes memory deploymentCode = abi.encodePacked(creationCode, uint256(uint160(SAFE_SINGLETON)));
        proxy = ICREATE3Factory(CREATE3_FACTORY).deploy(salt, deploymentCode);
        if (initializer.length > 0) {
            assembly {
                if eq(call(gas(), proxy, 0, add(initializer, 0x20), mload(initializer), 0, 0), 0) { revert(0, 0) }
            }
        }
        emit ProxyCreation(proxy, SAFE_SINGLETON);
    }
}
