package com.talorlik.javaapp.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app")
public class AppProperties {

    private final Aws aws = new Aws();
    private final Secrets secrets = new Secrets();
    private final Jwt jwt = new Jwt();
    private final Verification verification = new Verification();
    private final RateLimit rateLimit = new RateLimit();
    private final Cors cors = new Cors();
    private final Ses ses = new Ses();
    private final Admin admin = new Admin();

    public Aws getAws() { return aws; }
    public Secrets getSecrets() { return secrets; }
    public Jwt getJwt() { return jwt; }
    public Verification getVerification() { return verification; }
    public RateLimit getRateLimit() { return rateLimit; }
    public Cors getCors() { return cors; }
    public Ses getSes() { return ses; }
    public Admin getAdmin() { return admin; }

    public static class Aws { private String region = "us-east-1";
        public String getRegion() { return region; } public void setRegion(String r) { this.region = r; } }

    public static class Secrets {
        private String jwtSecretName;
        private String sesSecretName;
        private String adminSecretName;
        public String getJwtSecretName() { return jwtSecretName; }
        public void setJwtSecretName(String v) { this.jwtSecretName = v; }
        public String getSesSecretName() { return sesSecretName; }
        public void setSesSecretName(String v) { this.sesSecretName = v; }
        public String getAdminSecretName() { return adminSecretName; }
        public void setAdminSecretName(String v) { this.adminSecretName = v; }
    }

    public static class Jwt {
        private long expirationMinutes = 60;
        // "secrets-manager" (default, prod) or "inline" (local/dev/CI smoke).
        // Selected by Spring's @ConditionalOnProperty on the matching
        // JwtSecretProvider implementation.
        private String secretSource = "secrets-manager";
        // Used only when secretSource = "inline". Must be >= 32 bytes for HS256.
        private String inlineKey;
        private String inlineIssuer = "java-app";
        public long getExpirationMinutes() { return expirationMinutes; }
        public void setExpirationMinutes(long v) { this.expirationMinutes = v; }
        public String getSecretSource() { return secretSource; }
        public void setSecretSource(String v) { this.secretSource = v; }
        public String getInlineKey() { return inlineKey; }
        public void setInlineKey(String v) { this.inlineKey = v; }
        public String getInlineIssuer() { return inlineIssuer; }
        public void setInlineIssuer(String v) { this.inlineIssuer = v; }
    }

    public static class Admin {
        // When false, AdminSeeder is a no-op. Used to keep local/CI boots
        // hermetic - i.e., no Secrets Manager call for the admin password.
        private boolean seedEnabled = true;
        public boolean isSeedEnabled() { return seedEnabled; }
        public void setSeedEnabled(boolean v) { this.seedEnabled = v; }
    }

    public static class Verification {
        private int codeLength = 6;
        private int ttlMinutes = 30;
        private int maxAttempts = 5;
        public int getCodeLength() { return codeLength; } public void setCodeLength(int v) { codeLength = v; }
        public int getTtlMinutes() { return ttlMinutes; } public void setTtlMinutes(int v) { ttlMinutes = v; }
        public int getMaxAttempts() { return maxAttempts; } public void setMaxAttempts(int v) { maxAttempts = v; }
    }

    public static class RateLimit {
        private int loginPerMinute = 10;
        private int verifyPerMinute = 10;
        private int signupPerHour = 20;
        public int getLoginPerMinute() { return loginPerMinute; } public void setLoginPerMinute(int v) { loginPerMinute = v; }
        public int getVerifyPerMinute() { return verifyPerMinute; } public void setVerifyPerMinute(int v) { verifyPerMinute = v; }
        public int getSignupPerHour() { return signupPerHour; } public void setSignupPerHour(int v) { signupPerHour = v; }
    }

    public static class Cors {
        private String allowedOrigin;
        public String getAllowedOrigin() { return allowedOrigin; } public void setAllowedOrigin(String v) { allowedOrigin = v; }
    }

    public static class Ses {
        private boolean enabled = true;
        public boolean isEnabled() { return enabled; } public void setEnabled(boolean v) { enabled = v; }
    }
}
