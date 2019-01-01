#!/bin/bash
#
# A utility script for flyway script versioning. The resulting migartion
# sql script V<timestamp>__<description>.sql will be under the directory
# src/main/resources/db/migration.
#
# Usage: $ ./version-db.sh <description>

set -eu

readonly PROJECT_ROOT=$(git rev-parse --show-toplevel)
readonly DB_MIGRATION_PATH="${PROJECT_ROOT}/src/main/resources/db/migration"
readonly DB_VERSION=$(date +%Y%m%d%H%s)

# Description of versioned migration sql script
description=$(echo "${1}" | xargs)

touch "${DB_MIGRATION_PATH}/V${DB_VERSION}__${description// /_}.sql"
