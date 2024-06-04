#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
dao_factory=$(jq -r ".FACTORY_ADDR" $c3)
safe_factory=0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2
safe_singleton=0x3E5c63644E683549055b9Be8653de26E0B4CD36E

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

verify $dao_factory 1 $(cast abi-encode "constructor(address,address)" $safe_factory $safe_singleton) src/SafeDaoFactory.sol:SafeDaoFactory
