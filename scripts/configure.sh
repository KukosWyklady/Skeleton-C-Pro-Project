# Full script path
script_path=`readlink -f "${BASH_SOURCE[0]}" 2>/dev/null||echo $0`

# This directory path
script_dir=`dirname "${script_path}"`

# import logger
source ${script_dir}/logger.sh

# First install env dependencies
info "Installing env tools if needed ..."
${script_dir}/install_env.sh || error "Env tools installation error"
success "Env tools installed"