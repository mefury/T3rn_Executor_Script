#!/bin/bash

# ==============================================
# T3rn Executor Setup Script
# Version: 2.0
# Created by: MEFURY
# ==============================================

# Color codes
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

set -e

# Step 1: Kill existing executor process
echo -e "\n${CYAN}Checking for running executor processes...${NC}"
if pgrep -x "executor" > /dev/null; then
    echo -e "${YELLOW}Found running executor. Killing process...${NC}"
    pkill -9 executor
    sleep 2
fi

# Step 2: Cleanup old files
echo -e "\n${CYAN}Cleaning up previous installations...${NC}"
rm -f executor-linux*
rm -rf executor

# Step 3: Download latest release
echo -e "\n${CYAN}Downloading latest executor binary...${NC}"
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep "executor-linux" | grep "browser_download_url" | cut -d '"' -f 4)
wget -q --show-progress $DOWNLOAD_URL

# Step 4: Extract downloaded file
echo -e "\n${CYAN}Extracting archive...${NC}"
tar -xzf executor-linux*.tar.gz

# Step 5: Change to binary directory
cd executor/executor/bin

# Step 6: Set environment variables
echo -e "\n${GREEN}Setting up environment variables...${NC}"

# Basic configuration
export NODE_ENV=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false

# Execution flags
export EXECUTOR_PROCESS_ORDERS=true
export EXECUTOR_PROCESS_CLAIMS=true

# Private key setup
echo -e "${MAGENTA}"
read -p "Enter your PRIVATE KEY: " PRIVATE_KEY
echo -e "${NC}"
export PRIVATE_KEY_LOCAL=$PRIVATE_KEY

# Network configuration
export ENABLED_NETWORKS='base-sepolia,optimism-sepolia,l1rn,blast-sepolia,arb-sepolia'

# Advanced flags
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
export EXECUTOR_ENABLE_BATCH_BIDING=true
export EXECUTOR_PROCESS_BIDS_ENABLED=true

# Gas price configuration
echo -e "${CYAN}"
read -p "Enter MAX_L3_GAS_PRICE [500]: " GAS_PRICE
GAS_PRICE=${GAS_PRICE:-500}
echo -e "${NC}"
export EXECUTOR_MAX_L3_GAS_PRICE=$GAS_PRICE

# RPC configuration
echo -e "\n${MAGENTA}RPC Endpoint Options:${NC}"
PS3='Choose RPC configuration: '
options=("Public RPCs" "Default RPCs")
select opt in "${options[@]}"
do
    case $opt in
        "Public RPCs")
            echo -e "${CYAN}Using public RPC endpoints${NC}"
            export RPC_ENDPOINTS_bssp='https://base-sepolia-rpc.publicnode.com'
            export RPC_ENDPOINTS_opsp='https://sepolia.optimism.io/'
            export API_ENDPOINTS_L1RN='https://brn.rpc.caldera.xyz/'
            export RPC_ENDPOINTS_blast='https://sepolia.blast.io/'
            export RPC_ENDPOINTS_arb='https://arbitrum-sepolia-rpc.publicnode.com/'
            break
            ;;
        "Default RPCs")
            echo -e "${CYAN}Using default RPC configuration${NC}"
            break
            ;;
        *) echo -e "${RED}Invalid option $REPLY${NC}";;
    esac
done

# Step 7: Create restart script
echo -e "\n${GREEN}Creating restart script...${NC}"
cat > loop.sh << 'EOL'
#!/bin/bash
while true; do
  ./executor
  if [ $? -ne 0 ]; then
    echo "Application crashed. Restarting in 1 minute..."
    sleep 60
  fi
done
EOL

chmod +x loop.sh

# Step 8: Start the application
echo -e "\n${GREEN}Starting executor...${NC}"
exec ./loop.sh
