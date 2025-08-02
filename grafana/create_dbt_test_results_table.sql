DROP TABLE IF EXISTS monitoring.dbt_test_results;
CREATE TABLE IF NOT EXISTS monitoring.dbt_test_results (
    result_id SERIAL PRIMARY KEY,
    invocation_id VARCHAR(36),
    unique_id VARCHAR(500),
    test_name VARCHAR(255),
    model_name VARCHAR(255),
    test_type VARCHAR(100), -- generic, singular, custom
    status VARCHAR(50),     -- pass, fail, error, skip
    rows_affected INTEGER,
    execution_time_seconds NUMERIC(10,3),
    compiled_code TEXT,
    error_message TEXT,
    warn_message TEXT,
    adapter_response JSONB,
    run_started_at TIMESTAMP,
    run_completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

