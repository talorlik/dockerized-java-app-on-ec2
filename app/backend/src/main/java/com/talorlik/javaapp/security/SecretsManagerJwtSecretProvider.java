package com.talorlik.javaapp.security;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.talorlik.javaapp.config.AppProperties;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;

/**
 * Default JWT secret provider. Reads a JSON-encoded secret from AWS Secrets
 * Manager at the path configured by {@code app.secrets.jwt-secret-name}.
 * Expected payload shape:
 * <pre>{ "signing_key": "...", "issuer": "java-app" }</pre>
 * The {@code issuer} field is optional and defaults to {@code java-app}.
 *
 * Active when {@code app.jwt.secret-source=secrets-manager} or unset, so
 * production behavior is unchanged from the pre-strategy implementation.
 */
@Component
@ConditionalOnProperty(name = "app.jwt.secret-source", havingValue = "secrets-manager", matchIfMissing = true)
public class SecretsManagerJwtSecretProvider implements JwtSecretProvider {

    private final SecretsManagerClient sm;
    private final AppProperties props;
    private final ObjectMapper mapper = new ObjectMapper();

    public SecretsManagerJwtSecretProvider(SecretsManagerClient sm, AppProperties props) {
        this.sm = sm;
        this.props = props;
    }

    @Override
    public JwtMaterial load() {
        try {
            var resp = sm.getSecretValue(GetSecretValueRequest.builder()
                .secretId(props.getSecrets().getJwtSecretName())
                .build());
            JsonNode json = mapper.readTree(resp.secretString());
            String signingKey = json.get("signing_key").asText();
            String issuer = json.has("issuer") ? json.get("issuer").asText() : "java-app";
            return new JwtMaterial(signingKey, issuer);
        } catch (Exception e) {
            // Wrap as IllegalStateException so Spring fails the bean lifecycle
            // with a clear root cause rather than the raw SDK exception.
            throw new IllegalStateException(
                "Failed to load JWT signing material from Secrets Manager", e);
        }
    }
}
