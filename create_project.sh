#!/usr/bin/bash
set -oeu pipefail

dir=$1
project_name=$(basename "${dir}")

mkdir -p "${dir}"
mkdir -p "${dir}/src"
mkdir -p "${dir}/test"


