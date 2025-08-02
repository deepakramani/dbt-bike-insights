COPY monitoring.ingest_audit_log(audit_id,table_name,load_type,records_loaded,load_started_at,load_ended_at,load_timestamp,status,error_message,file_name,dag_id,run_id)
FROM '/home/input_data/generated_audit_logs1.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');


CREATE OR REPLACE VIEW monitoring.v_audit_dashboard AS
SELECT
  audit_id,
  table_name,
  load_type,
  records_loaded,
  load_started_at,
  load_ended_at,
  status,
  error_message,
  file_name,
  dag_id,
  run_id,
  EXTRACT(EPOCH FROM (load_ended_at - load_started_at))::int AS load_duration_seconds
FROM monitoring.ingest_audit_log;

