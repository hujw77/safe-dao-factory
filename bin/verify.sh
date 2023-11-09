#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
dao_factory=$(jq -r ".FACTORY_ADDR" $c3)
safe_factory=0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC
safe_singleton=0x69f4D1788e39c87893C980c06EdF4b7f686e2938

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

verify $dao_factory 46 $(cast abi-encode "constructor(address,address)" $safe_factory $safe_singleton) src/SafeDaoFactory.sol:SafeDaoFactory
