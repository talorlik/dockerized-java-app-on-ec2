package com.talorlik.javaapp.security;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.talorlik.javaapp.config.AppProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Builds and parses HMAC-signed JWTs. Signing key is fetched from Secrets
 * Manager at startup (single-shot read; not rotated mid-process).
 */
@Component
public class JwtService {

    private final AppProperties props;
    private final SecretsManagerClient sm;
    private final ObjectMapper mapper = new ObjectMapper();
    private SecretKey key;
    private String issuer;

    public JwtService(AppProperties props, SecretsManagerClient sm) {
        this.props = props;
        this.sm = sm;
    }

    @PostConstruct
    void init() throws Exception {
        var resp = sm.getSecretValue(GetSecretValueRequest.builder()
            .secretId(props.getSecrets().getJwtSecretName())
            .build());
        JsonNode json = mapper.readTree(resp.secretString());
        String signingKey = json.get("signing_key").asText();
        this.issuer = json.has("issuer") ? json.get("issuer").asText() : "java-app";
        // jjwt requires >= 256-bit key for HS256
        this.key = Keys.hmacShaKeyFor(signingKey.getBytes(StandardCharsets.UTF_8));
    }

    public String issueToken(String subject, List<String> roles) {
        long now = System.currentTimeMillis();
        long exp = now + props.getJwt().getExpirationMinutes() * 60_000L;
        return Jwts.builder()
            .issuer(issuer)
            .subject(subject)
            .issuedAt(new Date(now))
            .expiration(new Date(exp))
            .claims(Map.of("roles", roles))
            .signWith(key, Jwts.SIG.HS256)
            .compact();
    }

    public Claims parse(String token) {
        return Jwts.parser()
            .verifyWith(key)
            .requireIssuer(issuer)
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }

    public long expirationSeconds() {
        return props.getJwt().getExpirationMinutes() * 60L;
    }
}
