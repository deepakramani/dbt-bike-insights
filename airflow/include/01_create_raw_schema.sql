/*

Create 'raw' schema to ingest raw data. 

*/

CREATE SCHEMA IF NOT EXISTS raw;

CREATE EXTENSION IF NOT EXISTS unaccent;
COMMENT ON EXTENSION unaccent IS 'Text normalization extension to remove accents';
