-- V3__create_verification_codes.sql

CREATE TABLE verification_codes (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    user_id     BIGINT       NOT NULL,
    code_hash   VARCHAR(255) NOT NULL,
    attempts    INT          NOT NULL DEFAULT 0,
    expires_at  DATETIME     NOT NULL,
    consumed_at DATETIME     NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_vc_user (user_id),
    KEY idx_vc_expires (expires_at),
    CONSTRAINT fk_vc_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
