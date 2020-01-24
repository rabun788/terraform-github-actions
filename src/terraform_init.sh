#!/bin/bash
BACKEND_BUCKET="${BACKEND_BUCKET:-}"
PREFIX="${PREFIX:-}"
echo "${INPUT_GCS_CREDS}" | jq  > /src/google.json
function terraformGO {
   # Gather the output of `terraform init`.
   echo "init: info: initializing Terraform configuration in ${tfWorkingDir}"

   initOutput=$(

      terraform init -input=false -no-color -force-copy -backend=true -get=true \
        -backend-config="bucket=${BACKEND_BUCKET}" -backend-config="prefix=${PREFIX}" \
        -backend-config="credentials=/src/google.json" -backend=true
      )
   wait
   echo "${initOutput}"

#   applyOutput=$(
    terraform apply -auto-approve
#   )
#   wait
#   echo "${applyOutput}"

}
