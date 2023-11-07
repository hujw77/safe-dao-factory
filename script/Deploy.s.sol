// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";
import {SafeDaoFactory} from "../src/SafeDaoFactory.sol";

contract Deploy is Common {
    using stdJson for string;
    using ScriptTools for string;

    address ADDR;
    bytes32 SALT;

    string c3;
    string safeVerison = "v1.3.0";

    function name() public pure override returns (string memory) {
        return "Deploy";
    }

    function setUp() public override {
        super.setUp();
        instanceId = vm.envOr("INSTANCE_ID", string("deploy.c"));
        outputName = "deploy.a";
        config = ScriptTools.readInput(instanceId);

        c3 = readC3();
        ADDR = c3.readAddress(".ADDR");
        SALT = c3.readBytes32(".SALT");
    }

    function run() public broadcast {
        bytes memory byteCode = type(SafeDaoFactory).creationCode;
        address addr = _deploy3(SALT, abi.encodePacked(byteCode, args()));
        require(addr == ADDR, "!addr");
    }

    function readC3() internal view returns (string memory) {
        string memory root = vm.projectRoot();
        return vm.readFile(string(abi.encodePacked(root, "/script/", "c3.json")));
    }

    function args() internal view returns (bytes memory) {
        (address SAFE_FACTORY, address SAFE_SINGLETON) = readSafeDeployment();
        return abi.encode(CREATE3_FACTORY_ADDR, SAFE_FACTORY, SAFE_SINGLETON);
    }

    function readSafeDeployment() internal view returns (address proxyFactory, address gnosisSafe) {
        uint256 chainId = getRootChainId();
        string memory root = vm.projectRoot();
        string memory safeFolder = string(abi.encodePacked("/lib/safe-deployments/src/assets/", safeVerison, "/"));
        string memory proxyFactoryFile = vm.readFile(string(abi.encodePacked(safeFolder, "proxy_factory.json")));
        proxyFactory =
            proxyFactoryFile.readAddress(string(abi.encodePacked(".networkAddresses.", vm.toString(chainId))));
        string gasisSafeJson;
        if (chainId.isL2()) {
            gasisSafeJson = "gnosis_safe_l2.json";
        } else {
            gasisSafeJson = "gnosis_safe.json";
        }
        string memory gnosisSageFile = vm.readFile(string(abi.encodePacked(safeFolder, gasisSafeJson)));
        gnosisSafe = gnosisSageFile.readAddress(string(abi.encodePacked(".networkAddresses.", vm.toString(chainId))));
    }
}
