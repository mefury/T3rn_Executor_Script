#!/bin/bash

# ==============================================
# T3rn Executor Setup Script
# Created by: MEFURY
# ==============================================

# Stylish Intro
echo -e "\n\033[1;36m=============================================="
echo -e "          T3rn Executor Setup          "
echo -e "==============================================\033[0m"
echo -e "\033[1;33mCreated by: \033[1;35mMEFURY\033[0m"
echo -e "\033[1;33mVersion: 1.0\033[0m"
echo -e "\033[1;33mDescription: This script will setup the T3rn executor program.\033[0m"
echo -e "\033[1;36m==============================================\033[0m\n"

# Wait for 5 seconds
echo -e "\033[1;33mGetting things ready for your...\033[0m"
sleep 5

# Check if executor is already running
if pgrep -x "executor" > /dev/null; then
    echo -e "\033[1;31mExecutor is already running!\033[0m"
    read -p "Do you want to stop the running executor and proceed? (y/n): " stop_executor
    if [[ $stop_executor == "y" ]]; then
        echo -e "\033[1;33mStopping the running executor...\033[0m"
        pkill -x "executor"
        sleep 2 # Wait for the process to stop
        echo -e "\033[1;32mExecutor stopped.\033[0m"
    else
        echo -e "\033[1;33mExiting setup. Please stop the executor manually and try again.\033[0m"
        exit 1
    fi
fi

# Step 1: Check and delete existing /executor folder
if [ -d "executor" ]; then
    echo -e "\033[1;31mDeleting existing /executor folder...\033[0m"
    rm -rf executor
    echo -e "\033[1;32mDeleted /executor folder.\033[0m"
fi

# Step 2: Delete any existing executor-linux-*.tar.gz files
echo -e "\033[1;33mCleaning up old executor-linux-*.tar.gz files...\033[0m"
rm -f executor-linux-*.tar.gz
echo -e "\033[1;32mCleanup complete.\033[0m"

# Step 3: Download the latest release of the executor program
echo -e "\033[1;33mDownloading the latest release...\033[0m"
wget $(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep "executor-linux" | grep "browser_download_url" | cut -d '"' -f 4)
echo -e "\033[1;32mDownload complete.\033[0m"

# Step 4: Extract the tar.gz file
echo -e "\033[1;33mExtracting the tar.gz file...\033[0m"
tar -xvzf executor-linux-*.tar.gz
echo -e "\033[1;32mExtraction complete.\033[0m"

# Step 5: Navigate to the executor/bin directory
cd executor/executor/bin

# Step 6: Set up environment variables
echo -e "\033[1;33mSetting up environment variables...\033[0m"

# Export NODE_ENV
export NODE_ENV=testnet
echo -e "\033[1;32mNODE_ENV set to 'testnet'.\033[0m"

# Export LOG_LEVEL and LOG_PRETTY
export LOG_LEVEL=debug
export LOG_PRETTY=false
echo -e "\033[1;32mLOG_LEVEL set to 'debug' and LOG_PRETTY set to 'false'.\033[0m"

# Export EXECUTOR_PROCESS_ORDERS and EXECUTOR_PROCESS_CLAIMS
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
echo -e "\033[1;32mEXECUTOR_PROCESS_ORDERS and EXECUTOR_PROCESS_CLAIMS set to 'true'.\033[0m"

# Export RPC_ENDPOINTS_L1RN
export RPC_ENDPOINTS_L1RN='https://brn.calderarpc.com/'
echo -e "\033[1;32mRPC_ENDPOINTS_L1RN set to 'https://brn.calderarpc.com/'.\033[0m"

# Step 7: Select networks to enable
echo -e "\033[1;33mSelect networks to enable:\033[0m"
echo -e "\033[1;37m1. Arbitrum"
echo -e "2. Base"
echo -e "3. Blast"
echo -e "4. Optimism"
echo -e "5. All of them\033[0m"

selected=()
while true; do
    read -p "Enter the number(s) of the chains you want to enable (comma-separated, or 5 for all): " chain_nums
    if [[ $chain_nums == "5" ]]; then
        selected=("arbitrum-sepolia" "base-sepolia" "blast-sepolia" "optimism-sepolia" "l1rn")
        break
    else
        IFS=',' read -r -a nums <<< "$chain_nums"
        for num in "${nums[@]}"; do
            case $num in
                1) selected+=("arbitrum-sepolia") ;;
                2) selected+=("base-sepolia") ;;
                3) selected+=("blast-sepolia") ;;
                4) selected+=("optimism-sepolia") ;;
                *) echo -e "\033[1;31mInvalid option: $num. Please try again.\033[0m" ;;
            esac
        done
        if [ ${#selected[@]} -gt 0 ]; then
            selected+=("l1rn") # Always include l1rn
            break
        else
            echo -e "\033[1;31mNo valid chains selected. Please try again.\033[0m"
        fi
    fi
done

# Export ENABLED_NETWORKS
export ENABLED_NETWORKS=$(IFS=,; echo "${selected[*]}")
echo -e "\033[1;32mENABLED_NETWORKS set to '$ENABLED_NETWORKS'.\033[0m"

# Step 8: Set EXECUTOR_MAX_L3_GAS_PRICE
read -p "Enter fee rate (default 500): " fee_rate
if [ -z "$fee_rate" ]; then
    fee_rate=500
fi
export EXECUTOR_MAX_L3_GAS_PRICE=$fee_rate
echo -e "\033[1;32mEXECUTOR_MAX_L3_GAS_PRICE set to '$fee_rate'.\033[0m"

# Step 9: Set PRIVATE_KEY_LOCAL
read -p "Enter your wallet private key: " private_key
export PRIVATE_KEY_LOCAL=$private_key
echo -e "\033[1;32mPRIVATE_KEY_LOCAL set.\033[0m"

# Step 10: Set EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
echo -e "\033[1;32mEXECUTOR_PROCESS_PENDING_ORDERS_FROM_API set to 'false'.\033[0m"

# Step 11: Set custom RPC endpoints
read -p "Do you want to set custom RPC endpoints? (y/n): " set_rpc
if [[ $set_rpc == "y" ]]; then
    read -p "Enter Arbitrum RPC endpoint: " arbt_rpc
    if [ -n "$arbt_rpc" ]; then
        export RPC_ENDPOINTS_ARBT="$arbt_rpc"
    fi

    read -p "Enter Optimism RPC endpoint: " opsp_rpc
    if [ -n "$opsp_rpc" ]; then
        export RPC_ENDPOINTS_OPSP="$opsp_rpc"
    fi

    read -p "Enter Blast RPC endpoint: " blss_rpc
    if [ -n "$blss_rpc" ]; then
        export RPC_ENDPOINTS_BLSS="$blss_rpc"
    fi

    read -p "Enter Base RPC endpoint: " bssp_rpc
    if [ -n "$bssp_rpc" ]; then
        export RPC_ENDPOINTS_BSSP="$bssp_rpc"
    fi

    read -p "Enter T3rn RPC endpoint: " l1rn_rpc
    if [ -n "$l1rn_rpc" ]; then
        export RPC_ENDPOINTS_L1RN="$l1rn_rpc"
    fi

    echo -e "\033[1;32mCustom RPC endpoints set.\033[0m"
else
    echo -e "\033[1;33mUsing default RPC endpoints.\033[0m"
fi

# Step 12: Create loop.sh script
echo -e "\033[1;33mCreating loop.sh script...\033[0m"
cat <<EOL > loop.sh
#!/bin/bash

while true; do
  ./executor
  if [ \$? -ne 0 ]; then
    echo "Application crashed. Restarting in 1 minute..."
    sleep 60
  fi
done
EOL

chmod +x loop.sh
echo -e "\033[1;32mloop.sh script created and made executable.\033[0m"

# Step 13: Run the executor
echo -e "\033[1;33mStarting the executor...\033[0m"
./loop.sh
