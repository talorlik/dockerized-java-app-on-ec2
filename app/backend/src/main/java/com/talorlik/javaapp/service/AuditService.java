package com.talorlik.javaapp.service;

import com.talorlik.javaapp.domain.AuditEvent;
import com.talorlik.javaapp.repository.AuditEventRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuditService {

    private final AuditEventRepository repo;

    public AuditService(AuditEventRepository repo) { this.repo = repo; }

    @Transactional
    public void record(String action, Long actorId, String actorEmail, String target, String metadataJson) {
        repo.save(AuditEvent.of(action, actorId, actorEmail, target, metadataJson));
    }
}
