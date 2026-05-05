package com.talorlik.javaapp.domain;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "verification_codes")
public class VerificationCode {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Stored hashed (BCrypt). Plaintext code is only sent via email.
    @Column(name = "code_hash", nullable = false)
    private String codeHash;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false)
    private int attempts = 0;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "consumed_at")
    private Instant consumedAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @PrePersist
    void onCreate() { createdAt = Instant.now(); }

    public Long getId() { return id; }
    public String getCodeHash() { return codeHash; }
    public void setCodeHash(String h) { this.codeHash = h; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public int getAttempts() { return attempts; }
    public void setAttempts(int v) { this.attempts = v; }
    public Instant getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Instant t) { this.expiresAt = t; }
    public Instant getConsumedAt() { return consumedAt; }
    public void setConsumedAt(Instant t) { this.consumedAt = t; }
    public Instant getCreatedAt() { return createdAt; }
}
