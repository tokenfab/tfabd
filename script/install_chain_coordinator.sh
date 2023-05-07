#!/bin/sh
#set -o errexit -o nounset -o pipefail

PASSWORD=${PASSWORD:-12345678}
STAKE=${STAKE_TOKEN:-TFAB}
FEE=${FEE_TOKEN:-uTFAB}
CHAIN_ID=${CHAIN_ID:-tokenfab-testnet}
MONIKER=${MONIKER:-node001}
FILENAME=${FILENAME:-"$HOME"/.tfabd/config/genesis.json}
CONFIG=${CONFIG:-"$HOME"/.tfabd/config/config.toml}

rm -rf ~/.tfabd

tfabd init --chain-id "$CHAIN_ID" "$MONIKER"
# staking/governance token is hardcoded in config, change this
sed -i "s/\"stake\"/\"$STAKE\"/" $FILENAME
# this is essential for sub-1s block times (or header times go crazy)
if grep -F "time_iota_ms" $FILENAME
then 
    sed -i 's/"time_iota_ms": "1000"/"time_iota_ms": "10"/' $FILENAME
else   
   sed -i 's/"max_gas": "-1"/"time_iota_ms": "10"/' $FILENAME
fi

# making 1 sec block time.
sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/' $CONFIG


if ! tfabd keys show validator; then
   (echo "$PASSWORD"; echo "$PASSWORD") | tfabd keys add validator 
fi
# hardcode the validator account for this instance
echo "$PASSWORD" | tfabd genesis add-genesis-account validator "10000000000000000$STAKE"

# submit a genesis validator tx
## Workraround for https://github.com/cosmos/cosmos-sdk/issues/8251
(echo "$PASSWORD"; echo "$PASSWORD"; echo "$PASSWORD") | tfabd genesis gentx validator "100000000000$STAKE" --chain-id="$CHAIN_ID" --amount="100000000000$STAKE"
## should be:
# (echo "$PASSWORD"; echo "$PASSWORD"; echo "$PASSWORD") | tfabd gentx validator "100000000000$STAKE" --chain-id="$CHAIN_ID"
tfabd genesis collect-gentxs
