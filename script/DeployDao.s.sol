// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {Chains} from "create3-deploy/script/Chains.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";
import {SafeDaoFactory} from "../src/SafeDaoFactory.sol";

import {IGnosisSafe} from "../src/IGnosisSafe.sol";
import {ISafeDaoFactory} from "../src/ISafeDaoFactory.sol";

contract DeployDao is Common {
    using Chains for uint256;
    using stdJson for string;
    using ScriptTools for string;

    address FACTORY;
    address ADDR;
    bytes32 SALT;
    string daoName;

    string c3;
    string config;
    string instanceId;
    string outputName;
    string safeVerison = "v1.3.0";

    function name() public pure override returns (string memory) {
        return "DeployDao";
    }

    function setUp() public override {
        super.setUp();
        daoName = vm.envOr("DAO_NAME", string(""));
        instanceId = string(abi.encodePacked(daoName, ".c"));
        outputName = string(abi.encodePacked(daoName, ".a"));
        config = ScriptTools.readInput(instanceId);

        c3 = readC3();
        FACTORY = c3.readAddress(".FACTORY_ADDR");
        ADDR = c3.readAddress(".MSGDAO_ADDR");
        SALT = c3.readBytes32(".MSGDAO_SALT");
    }

    function run() public {
        deployDao(SALT, args());
        ScriptTools.exportContract(outputName, daoName, ADDR);
    }

    function deployDao(bytes32 salt, bytes memory initializer) public broadcast {
        address addr = ISafeDaoFactory(FACTORY).deploy(salt, initializer);
        require(addr == ADDR, "!addr");
    }

    function readC3() internal view returns (string memory) {
        string memory root = vm.projectRoot();
        return vm.readFile(string(abi.encodePacked(root, "/script/", "c3.json")));
    }

    function args() internal returns (bytes memory) {
        address[] memory owners = config.readAddressArray(".Owners");
        uint256 threshold = config.readUint(".threshold");
        address to = config.readAddress(".to");
        bytes memory data = config.readBytes(".data");
        address fallbackHandler = readSafeDeployment();
        address paymentToken = config.readAddress(".paymentToken");
        uint256 payment = config.readUint(".payment");
        address paymentReceiver = config.readAddress(".paymentReceiver");
        return abi.encodeWithSelector(
            IGnosisSafe.setup.selector,
            owners,
            threshold,
            to,
            data,
            fallbackHandler,
            paymentToken,
            payment,
            paymentReceiver
        );
    }

    function readSafeDeployment() internal returns (address fallbackHandler) {
        uint256 chainId = vm.envOr("CHAIN_ID", block.chainid);
        string memory root = vm.projectRoot();
        string memory safeFolder = string(abi.encodePacked("/lib/safe-deployments/src/assets/", safeVerison, "/"));
        string memory file =
            vm.readFile(string(abi.encodePacked(root, safeFolder, "compatibility_fallback_handler.json")));
        fallbackHandler = file.readAddress(string(abi.encodePacked(".networkAddresses.", vm.toString(chainId))));
    }
}
