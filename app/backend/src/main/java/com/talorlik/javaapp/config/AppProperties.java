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

    public Aws getAws() { return aws; }
    public Secrets getSecrets() { return secrets; }
    public Jwt getJwt() { return jwt; }
    public Verification getVerification() { return verification; }
    public RateLimit getRateLimit() { return rateLimit; }
    public Cors getCors() { return cors; }
    public Ses getSes() { return ses; }

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
        public long getExpirationMinutes() { return expirationMinutes; }
        public void setExpirationMinutes(long v) { this.expirationMinutes = v; }
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
