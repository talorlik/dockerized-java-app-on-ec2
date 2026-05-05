package com.talorlik.javaapp.service;

import com.talorlik.javaapp.config.AppProperties;
import com.talorlik.javaapp.domain.Role;
import com.talorlik.javaapp.domain.User;
import com.talorlik.javaapp.domain.VerificationCode;
import com.talorlik.javaapp.email.EmailService;
import com.talorlik.javaapp.exception.ApiException;
import com.talorlik.javaapp.repository.RoleRepository;
import com.talorlik.javaapp.repository.UserRepository;
import com.talorlik.javaapp.repository.VerificationCodeRepository;
import com.talorlik.javaapp.security.JwtService;
import com.talorlik.javaapp.util.RateLimiter;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.HashSet;
import java.util.List;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);
    private static final String DIGITS = "0123456789";
    private static final SecureRandom RNG = new SecureRandom();

    private final UserRepository users;
    private final RoleRepository roles;
    private final VerificationCodeRepository codes;
    private final PasswordEncoder encoder;
    private final EmailService email;
    private final JwtService jwt;
    private final AppProperties props;
    private final AuditService audit;

    private RateLimiter signupLimiter;
    private RateLimiter loginLimiter;
    private RateLimiter verifyLimiter;

    public AuthService(UserRepository users,
                       RoleRepository roles,
                       VerificationCodeRepository codes,
                       PasswordEncoder encoder,
                       EmailService email,
                       JwtService jwt,
                       AppProperties props,
                       AuditService audit) {
        this.users = users;
        this.roles = roles;
        this.codes = codes;
        this.encoder = encoder;
        this.email = email;
        this.jwt = jwt;
        this.props = props;
        this.audit = audit;
    }

    @PostConstruct
    void initLimiters() {
        signupLimiter = new RateLimiter(props.getRateLimit().getSignupPerHour(), Duration.ofHours(1));
        loginLimiter  = new RateLimiter(props.getRateLimit().getLoginPerMinute(), Duration.ofMinutes(1));
        verifyLimiter = new RateLimiter(props.getRateLimit().getVerifyPerMinute(), Duration.ofMinutes(1));
    }

    @Transactional
    public void signup(String email, String password, String fullName) {
        if (!signupLimiter.tryConsume("signup:" + email.toLowerCase())) {
            throw new ApiException(429, "Too many signup attempts. Try again later.");
        }
        if (users.existsByEmailIgnoreCase(email)) {
            // Generic response - same shape as success-but-already-pending.
            // Do not enumerate users.
            log.info("Signup attempt for existing email (suppressed)");
            return;
        }

        User u = new User();
        u.setEmail(email.toLowerCase());
        u.setPasswordHash(encoder.encode(password));
        u.setFullName(fullName);
        u.setRoles(new HashSet<>(List.of(roles.findByName(Role.USER).orElseThrow())));
        users.save(u);

        String code = generateCode(props.getVerification().getCodeLength());
        VerificationCode vc = new VerificationCode();
        vc.setUser(u);
        vc.setCodeHash(encoder.encode(code));
        vc.setExpiresAt(Instant.now().plus(Duration.ofMinutes(props.getVerification().getTtlMinutes())));
        codes.save(vc);

        this.email.sendVerificationCode(u.getEmail(), code);
        audit.record("USER_SIGNUP", u.getId(), u.getEmail(), null, null);
    }

    @Transactional
    public void verify(String emailAddr, String code) {
        if (!verifyLimiter.tryConsume("verify:" + emailAddr.toLowerCase())) {
            throw new ApiException(429, "Too many verification attempts.");
        }
        User u = users.findByEmailIgnoreCase(emailAddr).orElseThrow(() -> generic());
        VerificationCode vc = codes.findActiveForUser(u, Instant.now()).orElseThrow(() -> generic());

        if (vc.getAttempts() >= props.getVerification().getMaxAttempts()) {
            throw generic();
        }
        vc.setAttempts(vc.getAttempts() + 1);

        if (!encoder.matches(code, vc.getCodeHash())) {
            codes.save(vc);
            throw generic();
        }

        vc.setConsumedAt(Instant.now());
        codes.save(vc);

        u.setVerified(true);
        users.save(u);
        audit.record("USER_VERIFIED", u.getId(), u.getEmail(), null, null);
    }

    @Transactional
    public String login(String emailAddr, String password) {
        if (!loginLimiter.tryConsume("login:" + emailAddr.toLowerCase())) {
            throw new ApiException(429, "Too many login attempts.");
        }
        User u = users.findByEmailIgnoreCase(emailAddr).orElseThrow(this::genericAuth);
        if (!u.isEnabled() || !u.isVerified()) throw genericAuth();
        if (!encoder.matches(password, u.getPasswordHash())) throw genericAuth();

        List<String> roleNames = u.getRoles().stream().map(Role::getName).toList();
        audit.record("USER_LOGIN", u.getId(), u.getEmail(), null, null);
        return jwt.issueToken(u.getEmail(), roleNames);
    }

    private static String generateCode(int length) {
        StringBuilder b = new StringBuilder(length);
        for (int i = 0; i < length; i++) b.append(DIGITS.charAt(RNG.nextInt(10)));
        return b.toString();
    }

    private static ApiException generic() {
        return new ApiException(400, "Invalid or expired verification code.");
    }

    private ApiException genericAuth() {
        return new ApiException(401, "Invalid credentials.");
    }
}
