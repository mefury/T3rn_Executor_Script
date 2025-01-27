#!/bin/bash

# ==============================================
# T3RN EXECUTOR SETUP SCRIPT
# Version: 2.0
# Created by: MEFURY
# ==============================================

# Color codes
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Credit display
show_credit() {
    clear
    echo -e "${CYAN}"
    echo -e "=============================================="
    echo -e "           T3RN Executor Setup Script          "
    echo -e "=============================================="
    echo -e "${MAGENTA}"
    echo -e " Version 2.0"
    echo -e " Created by: MEFURY"
    echo -e "${CYAN}"
    echo -e "=============================================="
    echo -e "${NC}"
}

# Preparation animation
preparation_animation() {
    echo -e "\n${GREEN}Preparing installation environment..."
    echo -n "Loading components "
    for i in {1..5}; do
        echo -n "▹"
        sleep 0.3
    done
    echo -e "${NC}\n"
}

# Show credit information
show_credit

# Initial delay
echo -e "${GREEN}Initializing setup process...${NC}"
sleep 2

# Preparation sequence
preparation_animation

set -e

# Execution functions
# ==================

# Step 1: Process management
echo -e "${GREEN}▶ Checking system processes...${NC}"
if pgrep -x "executor" > /dev/null; then
    echo -e "${YELLOW}⚠ Found running instance - terminating...${NC}"
    pkill -9 executor
    sleep 2
fi

# Step 2: Cleanup
echo -e "${GREEN}▶ Performing system cleanup...${NC}"
rm -f executor-linux*
rm -rf executor

# Step 3: Download
echo -e "${GREEN}▶ Downloading latest release...${NC}"
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep "executor-linux" | grep "browser_download_url" | cut -d '"' -f 4)
wget -q --show-progress $DOWNLOAD_URL

# Step 4: Extraction
echo -e "${GREEN}▶ Extracting package contents...${NC}"
tar -xzf executor-linux*.tar.gz

# Step 5: Directory navigation
cd executor/executor/bin

# Configuration setup
# ===================

# Environment variables
export NODE_ENV=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_ORDERS=true
export EXECUTOR_PROCESS_CLAIMS=true
export ENABLED_NETWORKS='base-sepolia,optimism-sepolia,l1rn,blast-sepolia,arb-sepolia'
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
export EXECUTOR_ENABLE_BATCH_BIDING=true
export EXECUTOR_PROCESS_BIDS_ENABLED=true

# User inputs
echo -e "${YELLOW}"
read -p "Enter PRIVATE KEY: " PRIVATE_KEY
echo -e "${NC}"
export PRIVATE_KEY_LOCAL=$PRIVATE_KEY

echo -e "${YELLOW}"
read -p "Set MAX_L3_GAS_PRICE [500]: " GAS_PRICE
GAS_PRICE=${GAS_PRICE:-500}
echo -e "${NC}"
export EXECUTOR_MAX_L3_GAS_PRICE=$GAS_PRICE

# RPC Configuration
echo -e "\n${YELLOW}Select RPC Configuration:${NC}"
PS3='Choose option: '
options=("Public RPCs" "Default RPCs")
select opt in "${options[@]}"
do
    case $opt in
        "Public RPCs")
            echo -e "${GREEN}Using public endpoints${NC}"
            export RPC_ENDPOINTS_bssp='https://base-sepolia-rpc.publicnode.com'
            export RPC_ENDPOINTS_opsp='https://sepolia.optimism.io/'
            export API_ENDPOINTS_L1RN='https://brn.rpc.caldera.xyz/'
            export RPC_ENDPOINTS_blast='https://sepolia.blast.io/'
            export RPC_ENDPOINTS_arb='https://arbitrum-sepolia-rpc.publicnode.com/'
            break
            ;;
        "Default RPCs")
            echo -e "${GREEN}Using default configuration${NC}"
            break
            ;;
        *) echo -e "${YELLOW}Invalid selection${NC}";;
    esac
done

# Service management
# ==================

echo -e "${GREEN}▶ Configuring service...${NC}"
cat > loop.sh << 'EOL'
#!/bin/bash
while true; do
  ./executor || {
    echo "Service interruption detected - restarting..."
    sleep 60
  }
done
EOL

chmod +x loop.sh

# Final execution
echo -e "${GREEN}✅ Setup complete - launching service...${NC}"
exec ./loop.sh
