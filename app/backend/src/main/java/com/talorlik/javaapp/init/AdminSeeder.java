package com.talorlik.javaapp.init;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.talorlik.javaapp.config.AppProperties;
import com.talorlik.javaapp.domain.Role;
import com.talorlik.javaapp.domain.User;
import com.talorlik.javaapp.repository.RoleRepository;
import com.talorlik.javaapp.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;

import java.util.HashSet;
import java.util.List;

/**
 * Reads /java-app/prod/admin from Secrets Manager and inserts the admin user
 * if absent. Runs once at startup. Never logs the password.
 */
@Component
public class AdminSeeder {

    private static final Logger log = LoggerFactory.getLogger(AdminSeeder.class);

    private final SecretsManagerClient sm;
    private final UserRepository users;
    private final RoleRepository roles;
    private final PasswordEncoder encoder;
    private final AppProperties props;
    private final ObjectMapper mapper = new ObjectMapper();

    public AdminSeeder(SecretsManagerClient sm,
                       UserRepository users,
                       RoleRepository roles,
                       PasswordEncoder encoder,
                       AppProperties props) {
        this.sm = sm;
        this.users = users;
        this.roles = roles;
        this.encoder = encoder;
        this.props = props;
    }

    @EventListener(ApplicationReadyEvent.class)
    @Transactional
    public void seed() {
        if (!props.getAdmin().isSeedEnabled()) {
            // Hermetic local/CI: no Secrets Manager call, no admin row.
            log.info("AdminSeeder disabled by config (app.admin.seed-enabled=false)");
            return;
        }
        try {
            var resp = sm.getSecretValue(GetSecretValueRequest.builder()
                .secretId(props.getSecrets().getAdminSecretName())
                .build());
            JsonNode json = mapper.readTree(resp.secretString());
            String email = json.get("username").asText().toLowerCase();
            String password = json.get("password").asText();

            if (users.existsByEmailIgnoreCase(email)) {
                log.info("Admin user already present (idempotent skip)");
                return;
            }

            Role admin = roles.findByName(Role.ADMIN).orElseThrow();
            Role user  = roles.findByName(Role.USER).orElseThrow();

            User u = new User();
            u.setEmail(email);
            u.setFullName("Administrator");
            u.setPasswordHash(encoder.encode(password));
            u.setVerified(true);
            u.setEnabled(true);
            u.setRoles(new HashSet<>(List.of(admin, user)));
            users.save(u);

            // Do not log the password. Email is fine; it's not secret.
            log.info("Admin user seeded: {}", email);
        } catch (Exception e) {
            log.error("Admin seed failed: {}", e.getClass().getSimpleName());
            // Re-throwing would block startup. Better to keep app available.
        }
    }
}
