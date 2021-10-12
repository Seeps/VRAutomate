#!/bin/bash

cd "${0%/*}"

terraform init
terraform apply

env NO_PROXY='*' ansible-playbook -i inventory velociraptor.yml