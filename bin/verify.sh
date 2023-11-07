#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
c3_factory=$(jq -r ".CREATE3FACTORY_ADDR" $c3)
dao_factory=$(jq -r ".FACTORY_ADDR" $c3)
safe_factory=0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2
safe_singleton=0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552

verify() {
  local addr; addr=$1
  local chain_id; chain_id=$2
  local args; args=$3
  local path; path=$4
  local name; name=${path#*:}
  (set -x; forge verify-contract \
    --chain-id $chain_id \
    --num-of-optimizations 999999 \
    --watch \
    --constructor-args $args \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --compiler-version v0.8.17+commit.8df45f5f \
    --show-standard-json-input \
    $addr \
    $path > script/output/$chain_id/$name.v.json)
}

verify $dao_factory 5 $(cast abi-encode "constructor(address,address,address)" $c3_factory $safe_factory $safe_singleton) src/SafeDaoFactory.sol:SafeDaoFactory
