package com.talorlik.javaapp.security;

import com.talorlik.javaapp.config.AppProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Builds and parses HMAC-signed JWTs. The signing key is obtained from a
 * {@link JwtSecretProvider} at startup (single-shot read; not rotated
 * mid-process). The provider implementation is selected by the
 * {@code app.jwt.secret-source} property; in production this resolves to
 * Secrets Manager, in local/CI smoke to an inline key.
 */
@Component
public class JwtService {

    private final AppProperties props;
    private final JwtSecretProvider secretProvider;
    private SecretKey key;
    private String issuer;

    public JwtService(AppProperties props, JwtSecretProvider secretProvider) {
        this.props = props;
        this.secretProvider = secretProvider;
    }

    @PostConstruct
    void init() {
        JwtSecretProvider.JwtMaterial m = secretProvider.load();
        this.issuer = (m.issuer() != null && !m.issuer().isBlank())
            ? m.issuer()
            : "java-app";
        // jjwt requires >= 256-bit key for HS256. The inline provider enforces
        // this at construction; the SM provider trusts the secret payload.
        this.key = Keys.hmacShaKeyFor(m.signingKey().getBytes(StandardCharsets.UTF_8));
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
