#!/bin/bash

cd ~
if [[ ! -e soft ]]; then
    mkdir -p soft
fi
cd ~/soft
wget -q "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b -p "${HOME}/soft/miniforge3"
rm ${HOME}/soft/Miniforge3-$(uname)-$(uname -m).sh
${HOME}/soft/miniforge3/bin/conda init $SHELL_NAME
cd ~/dbt-bike-insights