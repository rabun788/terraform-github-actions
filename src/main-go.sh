#!/bin/bash

function stripColors {
  echo "${1}" | sed 's/\x1b\[[0-9;]*m//g'
}

function parseInputs {
  # Required inputs
  if [ "${INPUT_TF_ACTIONS_VERSION}" != "" ]; then
    tfVersion=${INPUT_TF_ACTIONS_VERSION}
  else
    echo "Input terraform_version cannot be empty"
    exit 1
  fi

  if [ "${INPUT_TF_ACTIONS_SUBCOMMAND}" != "" ]; then
    tfSubcommand=${INPUT_TF_ACTIONS_SUBCOMMAND}
  else
    echo "Input terraform_subcommand cannot be empty"
    exit 1
  fi

  # Optional inputs
  tfWorkingDir="."
  if [ "${INPUT_TF_ACTIONS_WORKING_DIR}" != "" ] || [ "${INPUT_TF_ACTIONS_WORKING_DIR}" != "." ]; then
    tfWorkingDir=${INPUT_TF_ACTIONS_WORKING_DIR}
  fi

  tfComment=0
  if [ "${INPUT_TF_ACTIONS_COMMENT}" == "1" ] || [ "${INPUT_TF_ACTIONS_COMMENT}" == "true" ]; then
    tfComment=1
  fi

  INPUT_GCS_CREDS=""
  if [ "${INPUT_GCS_CREDS}" != "" ]; then
    INPUT_GCS_CREDS=${INPUT_GCS_CREDS}
  fi

}

function main {

  # Source the other files to gain access to their functions
  scriptDir=$(dirname ${0})
  source ${scriptDir}/terraform_go.sh
  source ${scriptDir}/terraform_init.sh
  source ${scriptDir}/terraform_output.sh

  parseInputs

  cd ${GITHUB_WORKSPACE}/${tfWorkingDir}

  case "${tfSubcommand}" in

    go)
#      installTerraform
      terraformGO ${*}
      ;;
    output)
      terraformOutput ${*}
      ;;
    *)
      echo "Error: Must provide a valid value for terraform_subcommand"
      exit 1
      ;;
  esac
}

main "${*}"
