#!/bin/bash

cd ~
if [[ ! -e soft ]]; then
    mkdir -p soft
fi
cd ~/soft
# sudo apt update && 
# sudo apt install unzip
wget -q https://github.com/duckdb/duckdb/releases/download/v1.2.1/duckdb_cli-linux-amd64.zip -O duckdb_cli.zip
unzip duckdb_cli.zip
chmod +x duckdb
echo 'export PATH="/home/'$USER'/soft:$PATH"' >> ~/.bashrc
rm duckdb_cli.zip
cd ~