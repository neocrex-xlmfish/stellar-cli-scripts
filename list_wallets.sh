#!/usr/bin/env bash
# list_wallets.sh
# Lists all wallet TOML files, aliases, seed phrases, and optionally public/secret keys

if [ -z "$1" ]; then
    echo "Usage: $0 <environment>"
    echo "Example: $0 testnet"
    exit 1
fi

ENV="$1"

# Load configuration using the updated load_config.sh
CONFIG_OUTPUT=$(./load_config.sh "$ENV")
IDENTITY_PATH=$(echo "$CONFIG_OUTPUT" | grep '^💾 Identity Path:' | sed -E 's/💾 Identity Path:[ \t]*//')

if [ -z "$IDENTITY_PATH" ]; then
    echo "Error: identity_path not found in config"
    exit 1
fi

if [ ! -d "$IDENTITY_PATH" ]; then
    echo "Error: identity_path directory does not exist: $IDENTITY_PATH"
    exit 1
fi

echo "=== Wallets found in $IDENTITY_PATH ==="

# Iterate over .toml files
for TOML_FILE in "$IDENTITY_PATH"/*.toml; do
    [ -e "$TOML_FILE" ] || continue  # skip if no toml files

    # Extract wallet alias from filename
    WALLET_ALIAS=$(basename "$TOML_FILE" .toml)

    # Extract seed_phrase (optional)
    SEED_PHRASE=$(grep -E '^seed_phrase\s*=' "$TOML_FILE" | sed -E 's/seed_phrase\s*=\s*"([^"]+)"/\1/')

    echo "Alias      : $WALLET_ALIAS"
    echo "TOML File  : $TOML_FILE"
    if [ -n "$SEED_PHRASE" ]; then
        echo "Seed Phrase: $SEED_PHRASE"
    fi

    # Attempt to get public/secret keys via CLI
    SECRET_KEY=$(stellar keys secret "$WALLET_ALIAS" 2>/dev/null)
    PUBLIC_KEY=$(stellar keys public-key "$WALLET_ALIAS" 2>/dev/null)

    if [ -n "$SECRET_KEY" ] && [ -n "$PUBLIC_KEY" ]; then
        echo "Public Key : $PUBLIC_KEY"
        echo "Secret Key : $SECRET_KEY"
    else
        echo "Public/Secret Keys: Unable to retrieve (wallet may be inaccessible)"
    fi

    echo "----------------------------"
done

echo "=== End of wallet list ==="
