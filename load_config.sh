#!/usr/bin/env bash
# load_config.sh
# Usage: ./load_config.sh [testnet|public]

CONFIG_FILE="config.ini"
ENVIRONMENT_PARAM=${1:-testnet}  # default to testnet

# Determine sections based on parameter
if [[ "$ENVIRONMENT_PARAM" == "testnet" ]]; then
    CONFIG_SECTION="config_testnet"
    ASSET_SECTION="assets_testnet"
elif [[ "$ENVIRONMENT_PARAM" == "public" ]]; then
    CONFIG_SECTION="config_public"
    ASSET_SECTION="assets_public"
else
    echo "Usage: $0 [testnet|public]"
    exit 1
fi

# Function to read key from section
read_config() {
    local section=$1
    local key=$2
    awk -F'=' -v section="$section" -v key="$key" '
        $0 ~ "\\["section"\\]" { in_section=1; next }
        /^\[/ { in_section=0 }
        in_section && $1 ~ key { gsub(/^[ \t"]+|[ \t"]+$/, "", $2); print $2 }
    ' "$CONFIG_FILE"
}

# Function to read asset list
read_assets() {
    local section=$1
    awk -v section="$section" '
        $0 ~ "\\["section"\\]" { in_section=1; next }
        /^\[/ { in_section=0 }
        in_section && $0 !~ /^#/ && NF { print $0 }
    ' "$CONFIG_FILE"
}

# Load configuration
IDENTITY_PATH=$(read_config "local" "identity_path")
ENVIRONMENT=$(read_config "$CONFIG_SECTION" "environment")
HORIZON_URL=$(read_config "$CONFIG_SECTION" "horizon_url")
ASSETS=$(read_assets "$ASSET_SECTION")

# Expand ~ or $HOME in IDENTITY_PATH
if [[ "$IDENTITY_PATH" == "~"* ]]; then
    IDENTITY_PATH="${IDENTITY_PATH/#\~/$HOME}"
else
    IDENTITY_PATH=$(eval echo "$IDENTITY_PATH")
fi

# Print results
echo "🌐 Environment: $ENVIRONMENT"
echo "🚀 Horizon URL: $HORIZON_URL"
echo "💾 Identity Path: $IDENTITY_PATH"
echo "💰 Assets ($ENVIRONMENT_PARAM):"
i=1
while read -r asset; do
    ISSUER="${asset%%:*}"
    CODE="${asset##*:}"
    echo "  $i. Asset Code: $CODE, Issuer: $ISSUER"
    ((i++))
done <<< "$ASSETS"
