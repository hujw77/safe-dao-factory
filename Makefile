.PHONY: all fmt clean test salt deploy deploy-dao
.PHONY: tools foundry sync create3 verify

-include .env

all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean
test   :; @forge test
deploy :; @forge script script/Deploy.s.sol:Deploy --chain ${chain-id} --broadcast --verify --legacy

deploy-dao :; @forge script script/DeployDao.s.sol:DeployDao --chain ${chain-id} --broadcast --verify --legacy

salt   :; @create3 -s 000000000000
sync   :; @git submodule update --recursive
create3:; @cargo install --git https://github.com/darwinia-network/create3-deploy -f

tools  :  foundry create3
foundry:; curl -L https://foundry.paradigm.xyz | bash

verify :; @bash ./bin/verify.sh
