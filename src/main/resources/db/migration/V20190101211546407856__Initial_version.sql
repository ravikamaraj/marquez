CREATE TABLE owners (
  uuid       UUID PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  name       VARCHAR(64) NOT NULL UNIQUE
);

CREATE TABLE namespaces (
  uuid               UUID PRIMARY KEY,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMPTZ,
  name               VARCHAR(1024) NOT NULL UNIQUE,
  description        TEXT,
  current_owner_name VARCHAR(64) NOT NULL
);

CREATE TABLE namespace_ownerships ( 
  uuid           UUID PRIMARY KEY,
  started_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ended_at       TIMESTAMPTZ,
  namespace_uuid UUID REFERENCES namespaces (uuid),
  owner_uuid     UUID REFERENCES owners (uuid)
);

CREATE TABLE jobs (
  uuid                 UUID PRIMARY KEY,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMPTZ,
  namespace_uuid       UUID REFERENCES namespaces (uuid),
  name                 VARCHAR(64) NOT NULL,
  description          TEXT,
  current_version_uuid UUID NOT NULL,
  UNIQUE (name, namespace_uuid)
);

CREATE TABLE job_versions (
  uuid                UUID PRIMARY KEY,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMPTZ,
  job_uuid            UUID REFERENCES jobs (uuid),
  input_dataset_urns  VARCHAR(64)[],
  output_dataset_urns VARCHAR(64)[],
  version             UUID NOT NULL,
  location            VARCHAR(255) NOT NULL,
  latest_job_run_uuid UUID NOT NULL,
  UNIQUE (job_uuid, version)
);

CREATE TYPE run_states AS ENUM ('NEW', 'RUNNING', 'COMPLETE', 'FAILED', 'ABORTED');

CREATE TABLE job_runs (
  uuid               UUID PRIMARY KEY,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMPTZ,
  job_version_uuid   UUID REFERENCES job_versions (uuid),
  nominal_start_time TIMESTAMPTZ,
  nominal_end_time   TIMESTAMPTZ,
  current_run_state  run_states NOT NULL
);

CREATE TABLE job_run_states (
  uuid            UUID PRIMARY KEY,
  transitioned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  job_run_uuid    UUID REFERENCES job_runs (uuid),
  run_state       run_states NOT NULL
);

CREATE TABLE job_run_args (
  uuid         UUID PRIMARY KEY,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  job_run_uuid UUID REFERENCES job_runs (uuid),
  run_args     JSONB NOT NULL,
  checksum     BIGINT NOT NULL UNIQUE  
);

CREATE TABLE data_sources (
  uuid           UUID PRIMARY KEY,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  name           VARCHAR(64) NOT NULL,
  connection_url VARCHAR(255) NOT NULL,
  UNIQUE (name, connection_url)
);

CREATE TABLE datasets (
  uuid                 UUID PRIMARY KEY,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMPTZ,
  namespace_uuid       UUID REFERENCES namespaces (uuid),
  data_source_uuid     UUID REFERENCES data_sources (uuid),
  urn                  VARCHAR(64) NOT NULL,
  description          TEXT,
  current_version_uuid UUID,
  UNIQUE (namespace_uuid, data_source_uuid, urn)
);

CREATE TABLE db_table_info (
  uuid           UUID PRIMARY KEY,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  db_name        VARCHAR(64) NOT NULL,
  db_schema_name VARCHAR(64) NOT NULL,
  UNIQUE (db_name, db_schema_name)
);

CREATE TABLE db_table_versions (
  uuid               UUID PRIMARY KEY,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dataset_uuid       UUID REFERENCES datasets (uuid),
  job_run_uuid       UUID REFERENCES job_runs (uuid),
  db_table_info_uuid UUID REFERENCES db_table_info (uuid),
  db_table_name      VARCHAR(64) NOT NULL
  UNIQUE (dataset_uuid, db_table_info_uuid, db_table_name)
);
