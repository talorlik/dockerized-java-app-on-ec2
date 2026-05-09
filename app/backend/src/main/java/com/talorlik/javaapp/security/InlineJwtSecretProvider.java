package com.talorlik.javaapp.security;

import com.talorlik.javaapp.config.AppProperties;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;

/**
 * Inline JWT secret provider. Reads the signing key directly from
 * {@code app.jwt.inline-key} and the issuer from {@code app.jwt.inline-issuer}.
 * Intended for local development and hermetic CI smoke runs where reaching
 * AWS Secrets Manager is not appropriate.
 *
 * Active when {@code app.jwt.secret-source=inline}.
 *
 * Validation runs at construction (fail-fast) rather than in {@link #load()}:
 * a misconfigured local stack should refuse to start, not start with a weak
 * key. HS256 requires {@code >= 256 bits}, hence the 32-byte minimum.
 */
@Component
@ConditionalOnProperty(name = "app.jwt.secret-source", havingValue = "inline")
public class InlineJwtSecretProvider implements JwtSecretProvider {

    private static final int MIN_KEY_BYTES = 32;

    private final String signingKey;
    private final String issuer;

    public InlineJwtSecretProvider(AppProperties props) {
        AppProperties.Jwt j = props.getJwt();
        if (j.getInlineKey() == null || j.getInlineKey().isBlank()) {
            throw new IllegalStateException(
                "app.jwt.secret-source=inline but app.jwt.inline-key is unset");
        }
        int len = j.getInlineKey().getBytes(StandardCharsets.UTF_8).length;
        if (len < MIN_KEY_BYTES) {
            throw new IllegalStateException(
                "app.jwt.inline-key must be at least " + MIN_KEY_BYTES
                    + " bytes for HS256; got " + len);
        }
        this.signingKey = j.getInlineKey();
        this.issuer = (j.getInlineIssuer() != null && !j.getInlineIssuer().isBlank())
            ? j.getInlineIssuer()
            : "java-app";
    }

    @Override
    public JwtMaterial load() {
        return new JwtMaterial(signingKey, issuer);
    }
}
