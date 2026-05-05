-- V4__create_audit_events.sql

CREATE TABLE audit_events (
    id         BIGINT       NOT NULL AUTO_INCREMENT,
    actor_id   BIGINT       NULL,
    actor_email VARCHAR(255) NULL,
    action     VARCHAR(100) NOT NULL,
    target     VARCHAR(255) NULL,
    metadata   JSON         NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_audit_action (action),
    KEY idx_audit_actor (actor_id),
    KEY idx_audit_created (created_at)
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
