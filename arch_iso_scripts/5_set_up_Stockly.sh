#!/usr/bin/env bash
set -euo pipefail

# Setup Stockly
cd 
mkdir -p Stockly
cd Stockly 
git clone git@github.com:Stockly/Main.git
cd Main
git config --local core.hooksPath ./dev_tools/git_hooks/
