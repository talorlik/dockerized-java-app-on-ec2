package com.talorlik.javaapp.domain;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "audit_events")
public class AuditEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "actor_id")
    private Long actorId;

    @Column(name = "actor_email")
    private String actorEmail;

    @Column(nullable = false, length = 100)
    private String action;

    @Column(length = 255)
    private String target;

    // JSON column - persisted as string. Avoid storing sensitive data here.
    // columnDefinition pins Hibernate schema validation to the MySQL JSON
    // type used by V4__create_audit_events.sql; without this, @Lob on a
    // String maps to TINYTEXT/CLOB and validation fails against JSON.
    @Column(name = "metadata", columnDefinition = "json")
    private String metadata;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() { createdAt = Instant.now(); }

    public static AuditEvent of(String action, Long actorId, String actorEmail, String target, String metadataJson) {
        AuditEvent e = new AuditEvent();
        e.action = action;
        e.actorId = actorId;
        e.actorEmail = actorEmail;
        e.target = target;
        e.metadata = metadataJson;
        return e;
    }

    public Long getId() { return id; }
    public Long getActorId() { return actorId; }
    public String getActorEmail() { return actorEmail; }
    public String getAction() { return action; }
    public String getTarget() { return target; }
    public String getMetadata() { return metadata; }
    public Instant getCreatedAt() { return createdAt; }
}
