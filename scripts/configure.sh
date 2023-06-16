#!/bin/bash

# Full script path
script_path=`readlink -f "${BASH_SOURCE[0]}" 2>/dev/null||echo $0`

# This directory path
script_dir=`dirname "${script_path}"`
project_dir="${script_dir}/.."

# import logger
source ${script_dir}/logger.sh

# First install env dependencies
info "Installing env tools if needed ..."
${script_dir}/install_env.sh || error "Env tools installation error"
success "Env tools installed"

# Init submodules
cd ${project_dir} && git submodule init
cd ${project_dir} &&  git submodule update


# Install C-logger lib from submodules
info "Installing C-logger if needed ..."
${script_dir}/install_c-logger.sh || error "C-logger installation error"
success "C-logger installed"

# Install Criterion lib from submodules
info "Installing Criterion if needed ..."
${script_dir}/install_criterion.sh || error "Criterion installation error"
success "Criterion installed"