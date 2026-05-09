package com.talorlik.javaapp.security;

/**
 * Source of JWT signing material. Implementations are wired by Spring as
 * mutually exclusive beans, selected by the {@code app.jwt.secret-source}
 * property:
 * <ul>
 *   <li>{@code secrets-manager} (default, production): {@link SecretsManagerJwtSecretProvider}</li>
 *   <li>{@code inline} (local dev / hermetic CI smoke): {@link InlineJwtSecretProvider}</li>
 * </ul>
 *
 * Decoupling secret-sourcing from {@link JwtService} keeps token logic free
 * of credential-chain concerns and lets new sources (Vault, file, KMS) be
 * added by introducing a bean rather than editing JwtService.
 */
public interface JwtSecretProvider {

    JwtMaterial load();

    /** Carrier for the resolved signing key and (optional) issuer claim. */
    record JwtMaterial(String signingKey, String issuer) {}
}
