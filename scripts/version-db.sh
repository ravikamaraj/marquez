#!/bin/bash
#
# A utility script for versioning database migrations. The resulting migration
# script V<timestamp>__<Description>.sql (ex: V20181231221546323003__Create_owners_table.sql)
# will be found under the directory src/main/resources/db/migration.
#
# Usage: $ ./version-db.sh <description>
#
# Note: Do NOT modify previous migration scripts. The checksum of each script
#       is stored in the flyway_schema_history table and used to track the state
#       of the database (see: https://flywaydb.org).

set -eu

readonly PROJECT_ROOT=$(git rev-parse --show-toplevel)
readonly DB_MIGRATION_PATH="${PROJECT_ROOT}/src/main/resources/db/migration"
readonly DB_VERSION=$(date +%Y%m%d%H%s)

# Description of versioned migration sql script
description=$(echo "${1}" | xargs)

touch "${DB_MIGRATION_PATH}/V${DB_VERSION}__${description// /_}.sql"
