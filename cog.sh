#!/bin/bash

# ##################################################
#
# Cog
# Author: Troy McGinnis
# Company: Gearbox
# URI: https://gearboxbuilt.com
# Updated: February 13, 2018
#
#
NAME='cog'
VERSION="1.0.0"
#
# HISTORY:
#
# * 2018-02-13 - v1.0.0 - Cog refactor
#
# ##################################################

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

#
# Source Script files
# --------------------------------------------------

# TODO: Register/track modules to provide better feedback
source_modules() {

  # Source script files
  for module in ${SCRIPT_PATH}/modules/*; do

    if [ -d "$module" ]; then
      # source module shell script
      source "${module}/main.sh"

      # source module config
      local module_config
      module_config=${module}/.config

      # if there's a config and it's opted to load now, source it now
      if [ -f "$module_config" ]; then
        if [[ $(sed -n '2{p;q;}' "$module_config") == "# config-load" ]]; then
          source "${module}/.config"
        fi
      fi
    fi
  done

  source "${SCRIPT_PATH}/.config"
  source "${SCRIPT_PATH}/.colors"
}

source_lib() {
  if [[ -n "$1" && -f "$1" ]]; then
    local lib; local lib_dir; lib_dir="$( cd "$( dirname "${1}" )" && pwd )/lib"

    if [[ -d $lib_dir ]]; then
      for lib in ${lib_dir}/*; do source "$lib"; done
    fi
  fi
}


#
# Cog
# --------------------------------------------------

source "${SCRIPT_PATH}/lib/core.sh"
source "${SCRIPT_PATH}/lib/updates.sh"
source "${SCRIPT_PATH}/lib/usage.sh"
source "${SCRIPT_PATH}/lib/messages.sh"

# TODO: Do this better
check_requirements() {
  local requirements; requirements=(npm yarn bower rvm)

  for i in "${requirements[@]}"; do
    cog::check_requirement "${i}"
  done
}

exit_project() {
  printf "\n${RED}NO! BAD!${NC} Please pass in a project name with: [-n | --name]\nExiting...\n\n"
  exit_cog
}

exit_cog() {
  check_for_updates
  exit 1
}


#
# Main
# --------------------------------------------------

main() {
  source_modules

  # Check requirements
  check_requirements

  # Check for no params
  if [[ $# -lt 1 ]]
    then
      cog_usage
      exit_cog
  fi

  #
  # Handle args and such
  # aka: run
  #
  while (( $# >= 1 ))
  do
  key="$1"

  case $key in
    --dev)
      DEV=YES
      ;;
    --debug)
      DEBUG=YES
      ;;
    -v|--version)
      echo $VERSION
      exit_cog
      ;;
    ?|--help)
      cog_usage
      exit_cog
      ;;
    update|upgrade)
      update_self
      exit_cog
      ;;
    pull)
      project::pull "${@:2}"
      exit_cog
      ;;
    push)
      project::push "${@:2}"
      exit_cog
      ;;
    update)
      project::update "${@:2}"
      exit_cog
      ;;
    --*)
      # Hmm...
      ;;
    *)
      if [[ $(type -t "${1}::main") == 'function' ]]; then
        "${1}::main" "${@:2}"
        exit_cog
      fi
      ;;
  esac
  shift # past argument or value
  done
}

main "$@"
