# T3rn Executor Setup Script

This script automates the setup of the **T3rn Executor** program, a CLI tool for interacting with the T3rn network. It handles downloading the latest release, configuring environment variables, and starting the executor.

---

## Features

- **Automatic Setup**: Downloads and configures the T3rn executor program.
- **Network Selection**: Allows users to select which chains to enable (Arbitrum, Base, Blast, Optimism, or all).
- **Custom RPC Endpoints**: Optionally set custom RPC endpoints for each chain.
- **Loop Script**: Creates a `loop.sh` script to automatically restart the executor if it crashes.
- **User-Friendly**: Interactive prompts guide users through the setup process.

---

## Prerequisites

- **Linux/macOS**: The script is designed for Unix-based systems.
- **Bash**: Ensure `bash` is installed (usually pre-installed on Linux/macOS).
- **curl**: Required for downloading files from GitHub.
- **wget**: Required for downloading the executor release.
- **tar**: Required for extracting the downloaded `.tar.gz` file.

---

## Setup Tutorial

### Step 1: Download and Run the Script

You can run the script directly from GitHub using the following command:

```bash
bash <(curl -s https://raw.githubusercontent.com/mefury/T3rn_Executor_Script/main/t3rnSetup.sh)
