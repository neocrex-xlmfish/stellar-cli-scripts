#!/bin/bash
# create_wallet.sh
# Create a Stellar wallet using the CLI and output public/secret keys
# Supports new wallet creation or existing alias

if [ -z "$1" ]; then
    echo "Usage: $0 <environment> [alias]"
    echo "Example: $0 testnet"
    echo "Example: $0 testnet wallet_1760465684"
    exit 1
fi

ENV="$1"
ALIAS="$2"

# Load config
CONFIG_OUTPUT=$(./load_config.sh "$ENV")
echo "=== Loaded Configuration ==="
echo "$CONFIG_OUTPUT"
echo "============================"

# If no alias provided, generate a new one and create wallet
if [ -z "$ALIAS" ]; then
    ALIAS="wallet_$(date +%s)"
    CLI_OUTPUT=$(stellar keys generate "$ALIAS" 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "Error creating wallet via Stellar CLI:"
        echo "$CLI_OUTPUT"
        exit 1
    fi

    # Extract TOML path (optional display)
    TOML_FILE=$(echo "$CLI_OUTPUT" | grep -Eo '".*\.toml"' | tr -d '"')
    echo "=== Wallet TOML Created: $TOML_FILE ==="
    cat "$TOML_FILE"
    echo "======================================="
fi

# Get secret key from alias
SECRET_KEY=$(stellar keys secret "$ALIAS")
if [[ $? -ne 0 ]] || [[ -z "$SECRET_KEY" ]]; then
    echo "Error retrieving secret key for alias $ALIAS"
    exit 1
fi

# Get public key from alias
PUBLIC_KEY=$(stellar keys public-key "$ALIAS")
if [[ $? -ne 0 ]] || [[ -z "$PUBLIC_KEY" ]]; then
    echo "Error retrieving public key for alias $ALIAS"
    exit 1
fi

echo "=== Wallet Keys ==="
echo "Alias      : $ALIAS"
echo "Public Key : $PUBLIC_KEY"
echo "Secret Key : $SECRET_KEY"
echo "==================="
