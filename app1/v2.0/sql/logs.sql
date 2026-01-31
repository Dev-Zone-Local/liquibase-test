--liquibase formatted sql

--changeset niket:logs_v2_001
-- Create a basic logs table for accumulation and querying
CREATE TABLE app1.logs (
    log_id        VARCHAR(36)  NOT NULL,
    tenant_id     VARCHAR(64)  NOT NULL,
    occurred_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    level         VARCHAR(10)  NOT NULL,
    category      VARCHAR(128),
    message       TEXT         NOT NULL,
    payload       TEXT,                  -- optional structured details (e.g., JSON as text)
    source_service VARCHAR(128),
    source_host   VARCHAR(128),
    user_id       VARCHAR(64),
    request_id    VARCHAR(64),
    trace_id      VARCHAR(64),
    span_id       VARCHAR(64),
    PRIMARY KEY (log_id),
    CONSTRAINT chk_logs_level CHECK (level IN ('TRACE','DEBUG','INFO','WARN','ERROR','FATAL'))
);

-- Useful indexes for common lookup patterns
CREATE INDEX idx_logs_tenant_time ON app1.logs (tenant_id, occurred_at);
CREATE INDEX idx_logs_level_time  ON app1.logs (level, occurred_at);
CREATE INDEX idx_logs_trace       ON app1.logs (trace_id);
CREATE INDEX idx_logs_request     ON app1.logs (request_id);

-- Simple daily rollup view for quick aggregation
CREATE VIEW log_counts_daily AS
SELECT
    CAST(occurred_at AS DATE) AS day,
    tenant_id,
    COALESCE(source_service, '') AS source_service,
    level,
    COUNT(*) AS total
FROM app1.logs
GROUP BY CAST(occurred_at AS DATE), tenant_id, COALESCE(source_service, ''), level;

--rollback DROP VIEW IF EXISTS log_counts_daily;
--rollback DROP INDEX IF EXISTS idx_logs_request;
--rollback DROP INDEX IF EXISTS idx_logs_trace;
--rollback DROP INDEX IF EXISTS idx_logs_level_time;
--rollback DROP INDEX IF EXISTS idx_logs_tenant_time;
--rollback DROP TABLE IF EXISTS app1.logs;