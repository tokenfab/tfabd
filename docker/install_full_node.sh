# this is secret. Please chage it when intalling full node.
# should be changed
PASSWORD=${PASSWORD:-12345678} 
# chain id to replace genesis file with existing one.
# must be correct chain id equal to gitup folder name under networks repository.
CHAIN_ID=${CHAIN_ID:-tokenfab-testnet}
# give any key name for full node name. This will be visible at block explorer as a validator name. 
# should be changed. If no changes, you can change it at config.toml file with moniker name.
MONIKER=${MONIKER:-node002}
# configuration file names. no need to change
FILENAME=${FILENAME:-"$HOME"/.tfabd/config/genesis.json}
CONFIG=${CONFIG:-"$HOME"/.tfabd/config/config.toml}  

rm -rf ~/.tfabd

tfabd init --chain-id "$CHAIN_ID" "$MONIKER"

rm -rf "$HOME"/networks

git clone https://github.com/tokenfab/networks.git "$HOME"/networks

SOURCE_GENESIS="$HOME"/networks/"$CHAIN_ID"/genesis.json

result=$(stat $SOURCE_GENESIS)
if [ $? -ne 0 ]; then
  echo "Error: genesis file not found"
  exit 1
fi 

cp -rf $SOURCE_GENESIS $FILENAME 

PERSISTENT_PEERS_PATH="$HOME"/networks/"$CHAIN_ID"/persistent_peers

result=$(stat $PERSISTENT_PEERS_PATH)
if [ $? -ne 0 ]; then
  echo "Error: genesis file not found"
  exit 1
fi   

PERSISTENT_PEERS=$(cat $PERSISTENT_PEERS_PATH)

# making 1 sec block time.
sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/' $CONFIG
sed -i "s/persistent_peers = \"\"/persistent_peers = \"$PERSISTENT_PEERS\"/" $CONFIG


if ! tfabd keys show validator; then
   (echo "$PASSWORD"; echo "$PASSWORD") | tfabd keys add validator 
fi

echo "!!!!!!!! store your mnemonic words. !!!!!!!!" 
echo "transfer some coin to be a validator and then call create_validator.sh"
echo "chain will be start in a few seconds."
sleep 2
tfabd start

