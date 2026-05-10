This file is a merged representation of the entire codebase, combined into a single document by Repomix.
The content has been processed where empty lines have been removed, line numbers have been added.

# File Summary

## Purpose
This file contains a packed representation of the entire repository's contents.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Empty lines have been removed from all files
- Line numbers have been added to the beginning of each line
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
.github/
  scripts/
    docs_drift_check.sh
    purge_pending_secrets.sh
  workflows/
    app-deploy.yml
    app-destroy.yml
    ci.yml
    infra-apply.yml
    infra-destroy.yml
    infra-plan.yml
  env.local.example
  secrets.local.example
  vars.local.example
app/
  backend/
    .mvn/
      wrapper/
        maven-wrapper.properties
    src/
      main/
        java/
          com/
            talorlik/
              javaapp/
                config/
                  AppProperties.java
                  AwsConfig.java
                controller/
                  AdminController.java
                  AuthController.java
                  ProfileController.java
                domain/
                  AuditEvent.java
                  Role.java
                  User.java
                  VerificationCode.java
                dto/
                  AuthDtos.java
                  UserDtos.java
                email/
                  EmailService.java
                exception/
                  ApiException.java
                  GlobalExceptionHandler.java
                init/
                  AdminSeeder.java
                repository/
                  AuditEventRepository.java
                  RoleRepository.java
                  UserRepository.java
                  VerificationCodeRepository.java
                security/
                  InlineJwtSecretProvider.java
                  JwtAuthenticationFilter.java
                  JwtSecretProvider.java
                  JwtService.java
                  SecretsManagerJwtSecretProvider.java
                  SecurityConfig.java
                service/
                  AuditService.java
                  AuthService.java
                util/
                  RateLimiter.java
                JavaAppApplication.java
        resources/
          db/
            migration/
              V1__create_users.sql
              V2__create_roles.sql
              V3__create_verification_codes.sql
              V4__create_audit_events.sql
          application-local.yml
          application-test.yml
          application.yml
      test/
        java/
          com/
            talorlik/
              javaapp/
                integration/
                  MigrationsIT.java
                unit/
                  PasswordPolicyTest.java
    .dockerignore
    Dockerfile
    mvnw
    mvnw.cmd
    pom.xml
  docker/
    docker-compose.local.yml
    docker-compose.prod.yml
    env.template
  frontend/
    src/
      css/
        main.css
      js/
        pages/
          admin_edit.js
          admin_list.js
          login.js
          profile.js
          signup.js
          thanks.js
          verify.js
        api.js
        app.js
        router.js
      index.html
    Dockerfile
    nginx.conf
docs/
  auxiliary/
    architecture-diagrams/
      generated-python.py
      requirements.txt
  dark-theme.css
  index.html
  light-theme.css
  main.js
  robots.txt
  sitemap.xml
infra/
  bootstrap/
    main.tf
    outputs.tf
    providers.tf
    variables.tf
    versions.tf
  envs/
    prod/
      lambda/
        db_bootstrap/
          pymysql/
            constants/
              __init__.py
              CLIENT.py
              COMMAND.py
              CR.py
              ER.py
              FIELD_TYPE.py
              FLAG.py
              SERVER_STATUS.py
            __init__.py
            _auth.py
            charset.py
            connections.py
            converters.py
            cursors.py
            err.py
            optionfile.py
            protocol.py
            times.py
          main.py
      templates/
        user_data.sh.tpl
      alb.tf
      asg.tf
      backend.tf
      db_bootstrap.tf
      ecr.tf
      iam.tf
      locals.tf
      main.tf
      network.tf
      observability.tf
      outputs.tf
      providers.tf
      rds.tf
      route53.tf
      secrets.tf
      security.tf
      ses.tf
      terraform.tfvars.example
      tfplan-fix.bin
      variables.tf
      versions.tf
      waf.tf
tests/
  e2e/
    specs/
      smoke.spec.ts
    playwright.config.ts
.actrc
.editorconfig
.gitattributes
.gitignore
repomix.config.json
```

# Files

## File: .github/scripts/docs_drift_check.sh
````bash
 1: #!/usr/bin/env bash
 2: set -euo pipefail
 3: ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
 4: cd "$ROOT_DIR"
 5: echo "Running docs drift checks..."
 6: python3 <<'PY'
 7: import pathlib
 8: import re
 9: import sys
10: root = pathlib.Path(".")
11: doc_files = [root / "README.md"] + [p for p in (root / "docs").rglob("*") if p.is_file()]
12: doc_files = [
13:     p for p in doc_files
14:     if p.as_posix() != "docs/auxiliary/operations_guide/DOC_SOURCE_OF_TRUTH_MATRIX.md"
15: ]
16: forbidden = [
17:     (r"https://java\.talorlik\.com:8443", "legacy public endpoint on :8443"),
18:     (r"HTTPS `8443`", "legacy ALB listener docs on 8443"),
19:     (r"Merge to `main`", "outdated workflow trigger narrative"),
20:     (r"main merges", "outdated workflow trigger narrative"),
21:     (r"pull request touching `infra/\*\*`", "outdated infra-plan trigger narrative"),
22:     (r"--type String --overwrite --value sha-", "release params should be SecureString in docs"),
23: ]
24: required = [
25:     (r"workflow_dispatch:", root / ".github/workflows/ci.yml", "ci manual trigger"),
26:     (r"workflow_call:", root / ".github/workflows/ci.yml", "ci reusable gate trigger"),
27:     (r"workflow_dispatch:", root / ".github/workflows/infra-plan.yml", "infra-plan manual trigger"),
28:     (r"workflow_dispatch:", root / ".github/workflows/infra-apply.yml", "infra-apply manual trigger"),
29:     (r"workflow_dispatch:", root / ".github/workflows/app-deploy.yml", "app-deploy manual trigger"),
30: ]
31: failed = False
32: for pattern, label in forbidden:
33:     rx = re.compile(pattern)
34:     hits = []
35:     for file in doc_files:
36:         try:
37:             text = file.read_text(encoding="utf-8", errors="ignore")
38:         except Exception:
39:             continue
40:         for idx, line in enumerate(text.splitlines(), 1):
41:             if rx.search(line):
42:                 hits.append((file.as_posix(), idx, line.strip()))
43:     if hits:
44:         failed = True
45:         print(f"ERROR: Found forbidden drift token: {label}")
46:         for path, ln, line in hits[:20]:
47:             print(f"  {path}:{ln}: {line}")
48:         print()
49: for pattern, file, label in required:
50:     rx = re.compile(pattern)
51:     try:
52:         text = file.read_text(encoding="utf-8", errors="ignore")
53:     except Exception:
54:         text = ""
55:     if not rx.search(text):
56:         failed = True
57:         print(f"ERROR: Missing expected canonical signal: {label} ({file.as_posix()})")
58: if failed:
59:     print("Docs drift check failed.")
60:     sys.exit(1)
61: print("Docs drift checks passed.")
62: PY
````

## File: .github/secrets.local.example
````
 1: # .github/secrets.local - Loaded by .actrc as `--secret-file`.
 2: #
 3: # Maps to `${{ secrets.* }}` references inside workflows during local act
 4: # runs. Real GitHub-hosted runners read from the repo/environment Secrets
 5: # UI; this file is local-only and gitignored.
 6: #
 7: # Only secrets actually referenced by workflows are listed. If you add a new
 8: # `${{ secrets.X }}` reference, append `X=` here.
 9: #
10: # Cross-reference with Settings -> Secrets and variables -> Actions in the
11: # upstream repo to ensure the same names exist on both sides.
12: 
13: # IAM role for the DEPLOYMENT account. Trusted for OIDC via
14: # token.actions.githubusercontent.com on real CI; under act, set this to any
15: # placeholder string - the OIDC step is skipped via `if: env.ACT != 'true'`
16: # in infra-apply.yml, infra-destroy.yml, app-deploy.yml.
17: DEPLOYMENT_ROLE_ARN=arn:aws:iam::000000000000:role/github-role
18: 
19: # Cross-account assume-role into the DOMAIN account for Route53. Only
20: # referenced as TF_VAR_domain_account_route53_role_arn inside terraform
21: # plan/apply/destroy. Under act, terraform receives this from the env vars
22: # the workflow sets. Provide a real value if you intend to run a full plan
23: # locally; otherwise a placeholder is fine for fmt/validate-only flows.
24: DOMAIN_ROUTE53_ROLE_ARN=arn:aws:iam::000000000000:role/route53-dns-manager-role
25: 
26: # ACM certificate for java.talorlik.com (issued in DEPLOYMENT account,
27: # region-pinned to AWS_REGION).
28: ACM_CERTIFICATE_ARN=arn:aws:acm:us-east-1:000000000000:certificate/00000000-0000-0000-0000-000000000000
29: 
30: GH_TOKEN=REPLACE
````

## File: .github/vars.local.example
````
 1: # .github/vars.local - Loaded by .actrc as `--var-file`.
 2: #
 3: # Maps to `${{ vars.* }}` references inside workflows during local act runs.
 4: # On real CI these come from Settings -> Secrets and variables -> Actions
 5: # (Variables tab). This file is local-only and gitignored.
 6: #
 7: # Only vars actually referenced by workflows are listed.
 8: LOCAL_AWS_PROFILE=REPLACE
 9: 
10: AWS_REGION=us-east-1
11: 
12: # 12-digit AWS account IDs. DEPLOYMENT hosts the app, ALB, RDS, ECR, etc.
13: # DOMAIN hosts the talorlik.com Route53 hosted zone.
14: DEPLOYMENT_ACCOUNT_ID=000000000000
15: DOMAIN_ACCOUNT_ID=000000000000
16: 
17: # Hosted zone ID for talorlik.com in the DOMAIN account.
18: HOSTED_ZONE_ID=Z000000000000000000000
````

## File: app/backend/.mvn/wrapper/maven-wrapper.properties
````
 1: # Apache Maven Wrapper (script-only mode).
 2: #
 3: # `distributionUrl` pins the Maven version. `distributionSha256Sum` is
 4: # verified by mvnw before extraction. Update both when bumping Maven.
 5: #
 6: # Maven 3.9.9 binary zip SHA-256 published at
 7: # https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip.sha512
 8: # (sha256 cross-verified against
 9: # https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip.sha256).
10: distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip
11: distributionSha256Sum=4ec3f26fb1a692473aea0235c300bd20f0f9fe741947c82c1234cefd76ac3a3c
````

## File: app/backend/src/main/java/com/talorlik/javaapp/config/AwsConfig.java
````java
 1: package com.talorlik.javaapp.config;
 2: import org.springframework.boot.context.properties.EnableConfigurationProperties;
 3: import org.springframework.context.annotation.Bean;
 4: import org.springframework.context.annotation.Configuration;
 5: import software.amazon.awssdk.regions.Region;
 6: import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
 7: import software.amazon.awssdk.services.sesv2.SesV2Client;
 8: @Configuration
 9: @EnableConfigurationProperties(AppProperties.class)
10: public class AwsConfig {
11:     @Bean
12:     public SecretsManagerClient secretsManagerClient(AppProperties props) {
13:         return SecretsManagerClient.builder()
14:             .region(Region.of(props.getAws().getRegion()))
15:             .build();
16:     }
17:     @Bean
18:     public SesV2Client sesV2Client(AppProperties props) {
19:         return SesV2Client.builder()
20:             .region(Region.of(props.getAws().getRegion()))
21:             .build();
22:     }
23: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/controller/AdminController.java
````java
 1: package com.talorlik.javaapp.controller;
 2: import com.talorlik.javaapp.domain.User;
 3: import com.talorlik.javaapp.dto.UserDtos.*;
 4: import com.talorlik.javaapp.exception.ApiException;
 5: import com.talorlik.javaapp.repository.UserRepository;
 6: import com.talorlik.javaapp.service.AuditService;
 7: import jakarta.servlet.http.HttpServletResponse;
 8: import jakarta.validation.Valid;
 9: import org.springframework.data.domain.Page;
10: import org.springframework.data.domain.PageRequest;
11: import org.springframework.data.domain.Sort;
12: import org.springframework.http.MediaType;
13: import org.springframework.security.core.annotation.AuthenticationPrincipal;
14: import org.springframework.transaction.annotation.Transactional;
15: import org.springframework.web.bind.annotation.*;
16: import java.io.IOException;
17: import java.io.PrintWriter;
18: import java.util.Map;
19: @RestController
20: @RequestMapping("/api/admin")
21: public class AdminController {
22:     private final UserRepository users;
23:     private final AuditService audit;
24:     public AdminController(UserRepository users, AuditService audit) {
25:         this.users = users;
26:         this.audit = audit;
27:     }
28:     @GetMapping("/users")
29:     public Map<String, Object> list(@AuthenticationPrincipal String adminEmail,
30:                                     @RequestParam(defaultValue = "0") int page,
31:                                     @RequestParam(defaultValue = "20") int size,
32:                                     @RequestParam(defaultValue = "createdAt") String sort,
33:                                     @RequestParam(defaultValue = "desc") String dir,
34:                                     @RequestParam(required = false) String q,
35:                                     @RequestParam(required = false) Boolean verified) {
36:         Sort.Direction d = "asc".equalsIgnoreCase(dir) ? Sort.Direction.ASC : Sort.Direction.DESC;
37:         Page<User> p = users.search(q, verified, PageRequest.of(page, Math.min(size, 100), Sort.by(d, sort)));
38:         return Map.of(
39:             "page", p.getNumber(),
40:             "size", p.getSize(),
41:             "total", p.getTotalElements(),
42:             "totalPages", p.getTotalPages(),
43:             "items", p.map(ProfileResponse::of).getContent()
44:         );
45:     }
46:     @GetMapping("/users/{id}")
47:     public ProfileResponse get(@PathVariable Long id) {
48:         return ProfileResponse.of(users.findById(id).orElseThrow(() -> new ApiException(404, "Not found.")));
49:     }
50:     @Transactional
51:     @PutMapping("/users/{id}")
52:     public ProfileResponse update(@AuthenticationPrincipal String adminEmail,
53:                                   @PathVariable Long id,
54:                                   @Valid @RequestBody AdminUpdateRequest req) {
55:         User u = users.findById(id).orElseThrow(() -> new ApiException(404, "Not found."));
56:         if (req.fullName() != null) u.setFullName(req.fullName());
57:         if (req.enabled() != null) u.setEnabled(req.enabled());
58:         if (Boolean.TRUE.equals(req.resetVerification())) u.setVerified(false);
59:         users.save(u);
60:         audit.record("ADMIN_USER_UPDATE", null, adminEmail, u.getEmail(), null);
61:         return ProfileResponse.of(u);
62:     }
63:     @Transactional
64:     @DeleteMapping("/users/{id}")
65:     public void delete(@AuthenticationPrincipal String adminEmail, @PathVariable Long id) {
66:         User u = users.findById(id).orElseThrow(() -> new ApiException(404, "Not found."));
67:         users.delete(u);
68:         audit.record("ADMIN_USER_DELETE", null, adminEmail, u.getEmail(), null);
69:     }
70:     @GetMapping(value = "/users.csv", produces = "text/csv")
71:     public void exportCsv(HttpServletResponse response) throws IOException {
72:         response.setContentType("text/csv; charset=utf-8");
73:         response.setHeader("Content-Disposition", "attachment; filename=users.csv");
74:         try (PrintWriter w = response.getWriter()) {
75:             w.println("id,email,full_name,verified,enabled,created_at,updated_at");
76:             for (User u : users.findAll()) {
77:                 w.printf("%d,%s,%s,%s,%s,%s,%s%n",
78:                     u.getId(),
79:                     csv(u.getEmail()),
80:                     csv(u.getFullName()),
81:                     u.isVerified(),
82:                     u.isEnabled(),
83:                     u.getCreatedAt(),
84:                     u.getUpdatedAt());
85:             }
86:         }
87:     }
88:     private static String csv(String v) {
89:         if (v == null) return "";
90:         if (v.contains(",") || v.contains("\"") || v.contains("\n")) {
91:             return "\"" + v.replace("\"", "\"\"") + "\"";
92:         }
93:         return v;
94:     }
95: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/controller/AuthController.java
````java
 1: package com.talorlik.javaapp.controller;
 2: import com.talorlik.javaapp.dto.AuthDtos.*;
 3: import com.talorlik.javaapp.security.JwtService;
 4: import com.talorlik.javaapp.service.AuthService;
 5: import jakarta.validation.Valid;
 6: import org.springframework.http.ResponseEntity;
 7: import org.springframework.web.bind.annotation.*;
 8: @RestController
 9: @RequestMapping("/api/auth")
10: public class AuthController {
11:     private final AuthService auth;
12:     private final JwtService jwt;
13:     public AuthController(AuthService auth, JwtService jwt) {
14:         this.auth = auth;
15:         this.jwt = jwt;
16:     }
17:     @PostMapping("/signup")
18:     public ResponseEntity<GenericResponse> signup(@Valid @RequestBody SignupRequest req) {
19:         auth.signup(req.email(), req.password(), req.fullName());
20:         // Generic accept response: never reveal whether the email pre-existed.
21:         return ResponseEntity.accepted().body(new GenericResponse("ok", "If the email is valid, a verification code has been sent."));
22:     }
23:     @PostMapping("/verify")
24:     public ResponseEntity<GenericResponse> verify(@Valid @RequestBody VerifyRequest req) {
25:         auth.verify(req.email(), req.code());
26:         return ResponseEntity.ok(new GenericResponse("ok", "Account verified."));
27:     }
28:     @PostMapping("/login")
29:     public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest req) {
30:         String token = auth.login(req.email(), req.password());
31:         return ResponseEntity.ok(new TokenResponse(token, jwt.expirationSeconds()));
32:     }
33: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/controller/ProfileController.java
````java
 1: package com.talorlik.javaapp.controller;
 2: import com.talorlik.javaapp.domain.User;
 3: import com.talorlik.javaapp.dto.UserDtos.*;
 4: import com.talorlik.javaapp.exception.ApiException;
 5: import com.talorlik.javaapp.repository.UserRepository;
 6: import jakarta.validation.Valid;
 7: import org.springframework.http.ResponseEntity;
 8: import org.springframework.security.core.annotation.AuthenticationPrincipal;
 9: import org.springframework.transaction.annotation.Transactional;
10: import org.springframework.web.bind.annotation.*;
11: @RestController
12: @RequestMapping("/api/profile")
13: public class ProfileController {
14:     private final UserRepository users;
15:     public ProfileController(UserRepository users) { this.users = users; }
16:     @GetMapping
17:     public ResponseEntity<ProfileResponse> me(@AuthenticationPrincipal String email) {
18:         User u = users.findByEmailIgnoreCase(email).orElseThrow(() -> new ApiException(404, "Not found."));
19:         return ResponseEntity.ok(ProfileResponse.of(u));
20:     }
21:     @Transactional
22:     @PutMapping
23:     public ResponseEntity<ProfileResponse> update(@AuthenticationPrincipal String email,
24:                                                    @Valid @RequestBody ProfileUpdateRequest req) {
25:         User u = users.findByEmailIgnoreCase(email).orElseThrow(() -> new ApiException(404, "Not found."));
26:         // Email is intentionally not modifiable.
27:         u.setFullName(req.fullName());
28:         users.save(u);
29:         return ResponseEntity.ok(ProfileResponse.of(u));
30:     }
31: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/domain/Role.java
````java
 1: package com.talorlik.javaapp.domain;
 2: import jakarta.persistence.*;
 3: @Entity
 4: @Table(name = "roles")
 5: public class Role {
 6:     public static final String USER  = "ROLE_USER";
 7:     public static final String ADMIN = "ROLE_ADMIN";
 8:     @Id
 9:     @GeneratedValue(strategy = GenerationType.IDENTITY)
10:     private Long id;
11:     @Column(nullable = false, unique = true, length = 50)
12:     private String name;
13:     public Long getId() { return id; }
14:     public String getName() { return name; }
15:     public void setName(String name) { this.name = name; }
16: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/domain/User.java
````java
 1: package com.talorlik.javaapp.domain;
 2: import jakarta.persistence.*;
 3: import java.time.Instant;
 4: import java.util.HashSet;
 5: import java.util.Set;
 6: @Entity
 7: @Table(name = "users")
 8: public class User {
 9:     @Id
10:     @GeneratedValue(strategy = GenerationType.IDENTITY)
11:     private Long id;
12:     @Column(nullable = false, unique = true)
13:     private String email;
14:     @Column(name = "password_hash", nullable = false)
15:     private String passwordHash;
16:     @Column(name = "full_name", nullable = false)
17:     private String fullName;
18:     @Column(nullable = false)
19:     private boolean verified = false;
20:     @Column(nullable = false)
21:     private boolean enabled = true;
22:     @Column(name = "created_at", nullable = false, updatable = false)
23:     private Instant createdAt;
24:     @Column(name = "updated_at", nullable = false)
25:     private Instant updatedAt;
26:     @ManyToMany(fetch = FetchType.EAGER)
27:     @JoinTable(
28:         name = "user_roles",
29:         joinColumns = @JoinColumn(name = "user_id"),
30:         inverseJoinColumns = @JoinColumn(name = "role_id")
31:     )
32:     private Set<Role> roles = new HashSet<>();
33:     @PrePersist
34:     protected void onCreate() {
35:         Instant now = Instant.now();
36:         if (createdAt == null) createdAt = now;
37:         updatedAt = now;
38:     }
39:     @PreUpdate
40:     protected void onUpdate() {
41:         updatedAt = Instant.now();
42:     }
43:     // ----- getters/setters -----
44:     public Long getId() { return id; }
45:     public void setId(Long id) { this.id = id; }
46:     public String getEmail() { return email; }
47:     public void setEmail(String email) { this.email = email; }
48:     public String getPasswordHash() { return passwordHash; }
49:     public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
50:     public String getFullName() { return fullName; }
51:     public void setFullName(String fullName) { this.fullName = fullName; }
52:     public boolean isVerified() { return verified; }
53:     public void setVerified(boolean verified) { this.verified = verified; }
54:     public boolean isEnabled() { return enabled; }
55:     public void setEnabled(boolean enabled) { this.enabled = enabled; }
56:     public Instant getCreatedAt() { return createdAt; }
57:     public Instant getUpdatedAt() { return updatedAt; }
58:     public Set<Role> getRoles() { return roles; }
59:     public void setRoles(Set<Role> roles) { this.roles = roles; }
60: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/domain/VerificationCode.java
````java
 1: package com.talorlik.javaapp.domain;
 2: import jakarta.persistence.*;
 3: import java.time.Instant;
 4: @Entity
 5: @Table(name = "verification_codes")
 6: public class VerificationCode {
 7:     @Id
 8:     @GeneratedValue(strategy = GenerationType.IDENTITY)
 9:     private Long id;
10:     // Stored hashed (BCrypt). Plaintext code is only sent via email.
11:     @Column(name = "code_hash", nullable = false)
12:     private String codeHash;
13:     @ManyToOne(fetch = FetchType.LAZY, optional = false)
14:     @JoinColumn(name = "user_id")
15:     private User user;
16:     @Column(nullable = false)
17:     private int attempts = 0;
18:     @Column(name = "expires_at", nullable = false)
19:     private Instant expiresAt;
20:     @Column(name = "consumed_at")
21:     private Instant consumedAt;
22:     @Column(name = "created_at", nullable = false, updatable = false)
23:     private Instant createdAt;
24:     @PrePersist
25:     void onCreate() { createdAt = Instant.now(); }
26:     public Long getId() { return id; }
27:     public String getCodeHash() { return codeHash; }
28:     public void setCodeHash(String h) { this.codeHash = h; }
29:     public User getUser() { return user; }
30:     public void setUser(User user) { this.user = user; }
31:     public int getAttempts() { return attempts; }
32:     public void setAttempts(int v) { this.attempts = v; }
33:     public Instant getExpiresAt() { return expiresAt; }
34:     public void setExpiresAt(Instant t) { this.expiresAt = t; }
35:     public Instant getConsumedAt() { return consumedAt; }
36:     public void setConsumedAt(Instant t) { this.consumedAt = t; }
37:     public Instant getCreatedAt() { return createdAt; }
38: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/dto/AuthDtos.java
````java
 1: package com.talorlik.javaapp.dto;
 2: import jakarta.validation.constraints.Email;
 3: import jakarta.validation.constraints.NotBlank;
 4: import jakarta.validation.constraints.Size;
 5: public class AuthDtos {
 6:     public record SignupRequest(
 7:         @Email @NotBlank String email,
 8:         @NotBlank @Size(min = 12, max = 128) String password,
 9:         @NotBlank @Size(max = 255) String fullName
10:     ) {}
11:     public record VerifyRequest(
12:         @Email @NotBlank String email,
13:         @NotBlank @Size(min = 4, max = 32) String code
14:     ) {}
15:     public record LoginRequest(
16:         @Email @NotBlank String email,
17:         @NotBlank String password
18:     ) {}
19:     public record TokenResponse(String token, long expiresInSeconds) {}
20:     public record GenericResponse(String status, String message) {}
21: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/dto/UserDtos.java
````java
 1: package com.talorlik.javaapp.dto;
 2: import com.talorlik.javaapp.domain.Role;
 3: import com.talorlik.javaapp.domain.User;
 4: import jakarta.validation.constraints.NotBlank;
 5: import jakarta.validation.constraints.Size;
 6: import java.time.Instant;
 7: import java.util.Set;
 8: import java.util.stream.Collectors;
 9: public class UserDtos {
10:     public record ProfileResponse(
11:         Long id,
12:         String email,
13:         String fullName,
14:         boolean verified,
15:         boolean enabled,
16:         Set<String> roles,
17:         Instant createdAt,
18:         Instant updatedAt
19:     ) {
20:         public static ProfileResponse of(User u) {
21:             return new ProfileResponse(
22:                 u.getId(),
23:                 u.getEmail(),
24:                 u.getFullName(),
25:                 u.isVerified(),
26:                 u.isEnabled(),
27:                 u.getRoles().stream().map(Role::getName).collect(Collectors.toSet()),
28:                 u.getCreatedAt(),
29:                 u.getUpdatedAt()
30:             );
31:         }
32:     }
33:     public record ProfileUpdateRequest(
34:         @NotBlank @Size(max = 255) String fullName
35:     ) {}
36:     public record AdminUpdateRequest(
37:         @Size(max = 255) String fullName,
38:         Boolean enabled,
39:         Boolean resetVerification
40:     ) {}
41: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/email/EmailService.java
````java
 1: package com.talorlik.javaapp.email;
 2: import com.fasterxml.jackson.databind.JsonNode;
 3: import com.fasterxml.jackson.databind.ObjectMapper;
 4: import com.talorlik.javaapp.config.AppProperties;
 5: import jakarta.annotation.PostConstruct;
 6: import org.slf4j.Logger;
 7: import org.slf4j.LoggerFactory;
 8: import org.springframework.stereotype.Service;
 9: import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
10: import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
11: import software.amazon.awssdk.services.sesv2.SesV2Client;
12: import software.amazon.awssdk.services.sesv2.model.*;
13: @Service
14: public class EmailService {
15:     private static final Logger log = LoggerFactory.getLogger(EmailService.class);
16:     private final SesV2Client ses;
17:     private final SecretsManagerClient sm;
18:     private final AppProperties props;
19:     private final ObjectMapper mapper = new ObjectMapper();
20:     private String fromAddress;
21:     public EmailService(SesV2Client ses, SecretsManagerClient sm, AppProperties props) {
22:         this.ses = ses;
23:         this.sm = sm;
24:         this.props = props;
25:     }
26:     @PostConstruct
27:     void init() throws Exception {
28:         if (!props.getSes().isEnabled()) {
29:             log.info("SES disabled - emails will be logged only");
30:             this.fromAddress = "no-reply@local";
31:             return;
32:         }
33:         var resp = sm.getSecretValue(GetSecretValueRequest.builder()
34:             .secretId(props.getSecrets().getSesSecretName())
35:             .build());
36:         JsonNode json = mapper.readTree(resp.secretString());
37:         this.fromAddress = json.get("from_address").asText();
38:     }
39:     public void sendVerificationCode(String to, String code) {
40:         String subject = "Your verification code";
41:         String body = """
42:             Hello,
43:             Your verification code is: %s
44:             This code expires in %d minutes. If you did not request this, ignore this email.
45:             """.formatted(code, props.getVerification().getTtlMinutes());
46:         if (!props.getSes().isEnabled()) {
47:             log.info("[email-fake] to={} subject={} bodyChars={}", to, subject, body.length());
48:             return;
49:         }
50:         try {
51:             ses.sendEmail(SendEmailRequest.builder()
52:                 .fromEmailAddress(fromAddress)
53:                 .destination(Destination.builder().toAddresses(to).build())
54:                 .content(EmailContent.builder()
55:                     .simple(Message.builder()
56:                         .subject(Content.builder().data(subject).build())
57:                         .body(Body.builder().text(Content.builder().data(body).build()).build())
58:                         .build())
59:                     .build())
60:                 .build());
61:         } catch (Exception e) {
62:             // Don't include 'code' in the error message - it's user-bound secret material.
63:             log.error("SES send failed for {}: {}", to, e.getClass().getSimpleName());
64:             throw e;
65:         }
66:     }
67: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/exception/ApiException.java
````java
1: package com.talorlik.javaapp.exception;
2: public class ApiException extends RuntimeException {
3:     private final int status;
4:     public ApiException(int status, String message) {
5:         super(message);
6:         this.status = status;
7:     }
8:     public int getStatus() { return status; }
9: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/exception/GlobalExceptionHandler.java
````java
 1: package com.talorlik.javaapp.exception;
 2: import com.talorlik.javaapp.dto.AuthDtos.GenericResponse;
 3: import org.springframework.http.HttpStatus;
 4: import org.springframework.http.ResponseEntity;
 5: import org.springframework.security.access.AccessDeniedException;
 6: import org.springframework.web.bind.MethodArgumentNotValidException;
 7: import org.springframework.web.bind.annotation.ExceptionHandler;
 8: import org.springframework.web.bind.annotation.RestControllerAdvice;
 9: @RestControllerAdvice
10: public class GlobalExceptionHandler {
11:     @ExceptionHandler(ApiException.class)
12:     public ResponseEntity<GenericResponse> api(ApiException e) {
13:         return ResponseEntity.status(e.getStatus()).body(new GenericResponse("error", e.getMessage()));
14:     }
15:     @ExceptionHandler(MethodArgumentNotValidException.class)
16:     public ResponseEntity<GenericResponse> validation(MethodArgumentNotValidException e) {
17:         return ResponseEntity.badRequest().body(new GenericResponse("error", "Invalid request."));
18:     }
19:     @ExceptionHandler(AccessDeniedException.class)
20:     public ResponseEntity<GenericResponse> denied(AccessDeniedException e) {
21:         return ResponseEntity.status(HttpStatus.FORBIDDEN).body(new GenericResponse("error", "Forbidden."));
22:     }
23:     @ExceptionHandler(Exception.class)
24:     public ResponseEntity<GenericResponse> unhandled(Exception e) {
25:         // Do not leak the message - return a generic 500.
26:         return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
27:             .body(new GenericResponse("error", "Internal server error."));
28:     }
29: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/repository/AuditEventRepository.java
````java
1: package com.talorlik.javaapp.repository;
2: import com.talorlik.javaapp.domain.AuditEvent;
3: import org.springframework.data.domain.Page;
4: import org.springframework.data.domain.Pageable;
5: import org.springframework.data.jpa.repository.JpaRepository;
6: public interface AuditEventRepository extends JpaRepository<AuditEvent, Long> {
7:     Page<AuditEvent> findAllByOrderByCreatedAtDesc(Pageable pageable);
8: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/repository/RoleRepository.java
````java
1: package com.talorlik.javaapp.repository;
2: import com.talorlik.javaapp.domain.Role;
3: import org.springframework.data.jpa.repository.JpaRepository;
4: import java.util.Optional;
5: public interface RoleRepository extends JpaRepository<Role, Long> {
6:     Optional<Role> findByName(String name);
7: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/repository/UserRepository.java
````java
 1: package com.talorlik.javaapp.repository;
 2: import com.talorlik.javaapp.domain.User;
 3: import org.springframework.data.domain.Page;
 4: import org.springframework.data.domain.Pageable;
 5: import org.springframework.data.jpa.repository.JpaRepository;
 6: import org.springframework.data.jpa.repository.Query;
 7: import org.springframework.data.repository.query.Param;
 8: import java.util.Optional;
 9: public interface UserRepository extends JpaRepository<User, Long> {
10:     Optional<User> findByEmailIgnoreCase(String email);
11:     boolean existsByEmailIgnoreCase(String email);
12:     @Query("""
13:         SELECT u FROM User u
14:         WHERE (:q IS NULL OR LOWER(u.email) LIKE LOWER(CONCAT('%', :q, '%'))
15:                           OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', :q, '%')))
16:           AND (:verified IS NULL OR u.verified = :verified)
17:     """)
18:     Page<User> search(@Param("q") String q,
19:                       @Param("verified") Boolean verified,
20:                       Pageable pageable);
21: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/repository/VerificationCodeRepository.java
````java
 1: package com.talorlik.javaapp.repository;
 2: import com.talorlik.javaapp.domain.User;
 3: import com.talorlik.javaapp.domain.VerificationCode;
 4: import org.springframework.data.jpa.repository.JpaRepository;
 5: import org.springframework.data.jpa.repository.Modifying;
 6: import org.springframework.data.jpa.repository.Query;
 7: import org.springframework.data.repository.query.Param;
 8: import java.time.Instant;
 9: import java.util.Optional;
10: public interface VerificationCodeRepository extends JpaRepository<VerificationCode, Long> {
11:     @Query("""
12:         SELECT v FROM VerificationCode v
13:         WHERE v.user = :user AND v.consumedAt IS NULL AND v.expiresAt > :now
14:         ORDER BY v.createdAt DESC
15:     """)
16:     Optional<VerificationCode> findActiveForUser(@Param("user") User user,
17:                                                  @Param("now") Instant now);
18:     @Modifying
19:     @Query("DELETE FROM VerificationCode v WHERE v.user = :user")
20:     void deleteAllForUser(@Param("user") User user);
21: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/security/InlineJwtSecretProvider.java
````java
 1: package com.talorlik.javaapp.security;
 2: import com.talorlik.javaapp.config.AppProperties;
 3: import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
 4: import org.springframework.stereotype.Component;
 5: import java.nio.charset.StandardCharsets;
 6: /**
 7:  * Inline JWT secret provider. Reads the signing key directly from
 8:  * {@code app.jwt.inline-key} and the issuer from {@code app.jwt.inline-issuer}.
 9:  * Intended for local development and hermetic CI smoke runs where reaching
10:  * AWS Secrets Manager is not appropriate.
11:  *
12:  * Active when {@code app.jwt.secret-source=inline}.
13:  *
14:  * Validation runs at construction (fail-fast) rather than in {@link #load()}:
15:  * a misconfigured local stack should refuse to start, not start with a weak
16:  * key. HS256 requires {@code >= 256 bits}, hence the 32-byte minimum.
17:  */
18: @Component
19: @ConditionalOnProperty(name = "app.jwt.secret-source", havingValue = "inline")
20: public class InlineJwtSecretProvider implements JwtSecretProvider {
21:     private static final int MIN_KEY_BYTES = 32;
22:     private final String signingKey;
23:     private final String issuer;
24:     public InlineJwtSecretProvider(AppProperties props) {
25:         AppProperties.Jwt j = props.getJwt();
26:         if (j.getInlineKey() == null || j.getInlineKey().isBlank()) {
27:             throw new IllegalStateException(
28:                 "app.jwt.secret-source=inline but app.jwt.inline-key is unset");
29:         }
30:         int len = j.getInlineKey().getBytes(StandardCharsets.UTF_8).length;
31:         if (len < MIN_KEY_BYTES) {
32:             throw new IllegalStateException(
33:                 "app.jwt.inline-key must be at least " + MIN_KEY_BYTES
34:                     + " bytes for HS256; got " + len);
35:         }
36:         this.signingKey = j.getInlineKey();
37:         this.issuer = (j.getInlineIssuer() != null && !j.getInlineIssuer().isBlank())
38:             ? j.getInlineIssuer()
39:             : "java-app";
40:     }
41:     @Override
42:     public JwtMaterial load() {
43:         return new JwtMaterial(signingKey, issuer);
44:     }
45: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/security/JwtAuthenticationFilter.java
````java
 1: package com.talorlik.javaapp.security;
 2: import io.jsonwebtoken.Claims;
 3: import io.jsonwebtoken.JwtException;
 4: import jakarta.servlet.FilterChain;
 5: import jakarta.servlet.ServletException;
 6: import jakarta.servlet.http.HttpServletRequest;
 7: import jakarta.servlet.http.HttpServletResponse;
 8: import org.springframework.lang.NonNull;
 9: import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
10: import org.springframework.security.core.authority.SimpleGrantedAuthority;
11: import org.springframework.security.core.context.SecurityContextHolder;
12: import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
13: import org.springframework.stereotype.Component;
14: import org.springframework.web.filter.OncePerRequestFilter;
15: import java.io.IOException;
16: import java.util.List;
17: @Component
18: public class JwtAuthenticationFilter extends OncePerRequestFilter {
19:     private final JwtService jwt;
20:     public JwtAuthenticationFilter(JwtService jwt) { this.jwt = jwt; }
21:     @Override
22:     protected void doFilterInternal(@NonNull HttpServletRequest request,
23:                                     @NonNull HttpServletResponse response,
24:                                     @NonNull FilterChain chain)
25:             throws ServletException, IOException {
26:         String header = request.getHeader("Authorization");
27:         if (header != null && header.startsWith("Bearer ") && SecurityContextHolder.getContext().getAuthentication() == null) {
28:             String token = header.substring(7);
29:             try {
30:                 Claims claims = jwt.parse(token);
31:                 @SuppressWarnings("unchecked")
32:                 List<String> roles = (List<String>) claims.get("roles", List.class);
33:                 if (roles == null) roles = List.of();
34:                 var auth = new UsernamePasswordAuthenticationToken(
35:                     claims.getSubject(),
36:                     null,
37:                     roles.stream().map(SimpleGrantedAuthority::new).toList()
38:                 );
39:                 auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
40:                 SecurityContextHolder.getContext().setAuthentication(auth);
41:             } catch (JwtException ignored) {
42:                 // Invalid token - leave context unauthenticated; downstream
43:                 // authorization will reject protected endpoints with 401/403.
44:             }
45:         }
46:         chain.doFilter(request, response);
47:     }
48: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/security/JwtSecretProvider.java
````java
 1: package com.talorlik.javaapp.security;
 2: /**
 3:  * Source of JWT signing material. Implementations are wired by Spring as
 4:  * mutually exclusive beans, selected by the {@code app.jwt.secret-source}
 5:  * property:
 6:  * <ul>
 7:  *   <li>{@code secrets-manager} (default, production): {@link SecretsManagerJwtSecretProvider}</li>
 8:  *   <li>{@code inline} (local dev / hermetic CI smoke): {@link InlineJwtSecretProvider}</li>
 9:  * </ul>
10:  *
11:  * Decoupling secret-sourcing from {@link JwtService} keeps token logic free
12:  * of credential-chain concerns and lets new sources (Vault, file, KMS) be
13:  * added by introducing a bean rather than editing JwtService.
14:  */
15: public interface JwtSecretProvider {
16:     JwtMaterial load();
17:     /** Carrier for the resolved signing key and (optional) issuer claim. */
18:     record JwtMaterial(String signingKey, String issuer) {}
19: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/security/SecretsManagerJwtSecretProvider.java
````java
 1: package com.talorlik.javaapp.security;
 2: import com.fasterxml.jackson.databind.JsonNode;
 3: import com.fasterxml.jackson.databind.ObjectMapper;
 4: import com.talorlik.javaapp.config.AppProperties;
 5: import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
 6: import org.springframework.stereotype.Component;
 7: import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
 8: import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
 9: /**
10:  * Default JWT secret provider. Reads a JSON-encoded secret from AWS Secrets
11:  * Manager at the path configured by {@code app.secrets.jwt-secret-name}.
12:  * Expected payload shape:
13:  * <pre>{ "signing_key": "...", "issuer": "java-app" }</pre>
14:  * The {@code issuer} field is optional and defaults to {@code java-app}.
15:  *
16:  * Active when {@code app.jwt.secret-source=secrets-manager} or unset, so
17:  * production behavior is unchanged from the pre-strategy implementation.
18:  */
19: @Component
20: @ConditionalOnProperty(name = "app.jwt.secret-source", havingValue = "secrets-manager", matchIfMissing = true)
21: public class SecretsManagerJwtSecretProvider implements JwtSecretProvider {
22:     private final SecretsManagerClient sm;
23:     private final AppProperties props;
24:     private final ObjectMapper mapper = new ObjectMapper();
25:     public SecretsManagerJwtSecretProvider(SecretsManagerClient sm, AppProperties props) {
26:         this.sm = sm;
27:         this.props = props;
28:     }
29:     @Override
30:     public JwtMaterial load() {
31:         try {
32:             var resp = sm.getSecretValue(GetSecretValueRequest.builder()
33:                 .secretId(props.getSecrets().getJwtSecretName())
34:                 .build());
35:             JsonNode json = mapper.readTree(resp.secretString());
36:             String signingKey = json.get("signing_key").asText();
37:             String issuer = json.has("issuer") ? json.get("issuer").asText() : "java-app";
38:             return new JwtMaterial(signingKey, issuer);
39:         } catch (Exception e) {
40:             // Wrap as IllegalStateException so Spring fails the bean lifecycle
41:             // with a clear root cause rather than the raw SDK exception.
42:             throw new IllegalStateException(
43:                 "Failed to load JWT signing material from Secrets Manager", e);
44:         }
45:     }
46: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/security/SecurityConfig.java
````java
 1: package com.talorlik.javaapp.security;
 2: import com.talorlik.javaapp.config.AppProperties;
 3: import org.springframework.context.annotation.Bean;
 4: import org.springframework.context.annotation.Configuration;
 5: import org.springframework.http.HttpMethod;
 6: import org.springframework.security.authentication.AuthenticationManager;
 7: import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
 8: import org.springframework.security.config.annotation.web.builders.HttpSecurity;
 9: import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
10: import org.springframework.security.config.http.SessionCreationPolicy;
11: import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
12: import org.springframework.security.crypto.password.PasswordEncoder;
13: import org.springframework.security.web.SecurityFilterChain;
14: import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
15: import org.springframework.web.cors.CorsConfiguration;
16: import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
17: import java.util.List;
18: @Configuration
19: public class SecurityConfig {
20:     @Bean
21:     public PasswordEncoder passwordEncoder() {
22:         // BCrypt is the Spring-Security default adaptive hash. Strength tuned
23:         // to ~250-500 ms verify time on production hardware.
24:         return new BCryptPasswordEncoder(12);
25:     }
26:     @Bean
27:     public SecurityFilterChain securityFilterChain(HttpSecurity http,
28:                                                    JwtAuthenticationFilter jwtFilter,
29:                                                    AppProperties props) throws Exception {
30:         http
31:             .csrf(AbstractHttpConfigurer::disable)
32:             .cors(c -> c.configurationSource(req -> {
33:                 CorsConfiguration cfg = new CorsConfiguration();
34:                 cfg.setAllowedOrigins(List.of(props.getCors().getAllowedOrigin()));
35:                 cfg.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
36:                 cfg.setAllowedHeaders(List.of("Authorization", "Content-Type"));
37:                 cfg.setAllowCredentials(false);
38:                 return cfg;
39:             }))
40:             .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
41:             .authorizeHttpRequests(reg -> reg
42:                 .requestMatchers(HttpMethod.GET, "/actuator/health/**", "/actuator/info").permitAll()
43:                 .requestMatchers("/api/auth/**").permitAll()
44:                 .requestMatchers("/api/admin/**").hasRole("ADMIN")
45:                 .anyRequest().authenticated()
46:             )
47:             .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
48:         return http.build();
49:     }
50:     @Bean
51:     public AuthenticationManager authenticationManager(AuthenticationConfiguration cfg) throws Exception {
52:         return cfg.getAuthenticationManager();
53:     }
54: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/service/AuditService.java
````java
 1: package com.talorlik.javaapp.service;
 2: import com.talorlik.javaapp.domain.AuditEvent;
 3: import com.talorlik.javaapp.repository.AuditEventRepository;
 4: import org.springframework.stereotype.Service;
 5: import org.springframework.transaction.annotation.Transactional;
 6: @Service
 7: public class AuditService {
 8:     private final AuditEventRepository repo;
 9:     public AuditService(AuditEventRepository repo) { this.repo = repo; }
10:     @Transactional
11:     public void record(String action, Long actorId, String actorEmail, String target, String metadataJson) {
12:         repo.save(AuditEvent.of(action, actorId, actorEmail, target, metadataJson));
13:     }
14: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/service/AuthService.java
````java
  1: package com.talorlik.javaapp.service;
  2: import com.talorlik.javaapp.config.AppProperties;
  3: import com.talorlik.javaapp.domain.Role;
  4: import com.talorlik.javaapp.domain.User;
  5: import com.talorlik.javaapp.domain.VerificationCode;
  6: import com.talorlik.javaapp.email.EmailService;
  7: import com.talorlik.javaapp.exception.ApiException;
  8: import com.talorlik.javaapp.repository.RoleRepository;
  9: import com.talorlik.javaapp.repository.UserRepository;
 10: import com.talorlik.javaapp.repository.VerificationCodeRepository;
 11: import com.talorlik.javaapp.security.JwtService;
 12: import com.talorlik.javaapp.util.RateLimiter;
 13: import jakarta.annotation.PostConstruct;
 14: import org.slf4j.Logger;
 15: import org.slf4j.LoggerFactory;
 16: import org.springframework.security.crypto.password.PasswordEncoder;
 17: import org.springframework.stereotype.Service;
 18: import org.springframework.transaction.annotation.Transactional;
 19: import java.security.SecureRandom;
 20: import java.time.Duration;
 21: import java.time.Instant;
 22: import java.util.HashSet;
 23: import java.util.List;
 24: @Service
 25: public class AuthService {
 26:     private static final Logger log = LoggerFactory.getLogger(AuthService.class);
 27:     private static final String DIGITS = "0123456789";
 28:     private static final SecureRandom RNG = new SecureRandom();
 29:     private final UserRepository users;
 30:     private final RoleRepository roles;
 31:     private final VerificationCodeRepository codes;
 32:     private final PasswordEncoder encoder;
 33:     private final EmailService email;
 34:     private final JwtService jwt;
 35:     private final AppProperties props;
 36:     private final AuditService audit;
 37:     private RateLimiter signupLimiter;
 38:     private RateLimiter loginLimiter;
 39:     private RateLimiter verifyLimiter;
 40:     public AuthService(UserRepository users,
 41:                        RoleRepository roles,
 42:                        VerificationCodeRepository codes,
 43:                        PasswordEncoder encoder,
 44:                        EmailService email,
 45:                        JwtService jwt,
 46:                        AppProperties props,
 47:                        AuditService audit) {
 48:         this.users = users;
 49:         this.roles = roles;
 50:         this.codes = codes;
 51:         this.encoder = encoder;
 52:         this.email = email;
 53:         this.jwt = jwt;
 54:         this.props = props;
 55:         this.audit = audit;
 56:     }
 57:     @PostConstruct
 58:     void initLimiters() {
 59:         signupLimiter = new RateLimiter(props.getRateLimit().getSignupPerHour(), Duration.ofHours(1));
 60:         loginLimiter  = new RateLimiter(props.getRateLimit().getLoginPerMinute(), Duration.ofMinutes(1));
 61:         verifyLimiter = new RateLimiter(props.getRateLimit().getVerifyPerMinute(), Duration.ofMinutes(1));
 62:     }
 63:     @Transactional
 64:     public void signup(String email, String password, String fullName) {
 65:         if (!signupLimiter.tryConsume("signup:" + email.toLowerCase())) {
 66:             throw new ApiException(429, "Too many signup attempts. Try again later.");
 67:         }
 68:         if (users.existsByEmailIgnoreCase(email)) {
 69:             // Generic response - same shape as success-but-already-pending.
 70:             // Do not enumerate users.
 71:             log.info("Signup attempt for existing email (suppressed)");
 72:             return;
 73:         }
 74:         User u = new User();
 75:         u.setEmail(email.toLowerCase());
 76:         u.setPasswordHash(encoder.encode(password));
 77:         u.setFullName(fullName);
 78:         u.setRoles(new HashSet<>(List.of(roles.findByName(Role.USER).orElseThrow())));
 79:         users.save(u);
 80:         String code = generateCode(props.getVerification().getCodeLength());
 81:         VerificationCode vc = new VerificationCode();
 82:         vc.setUser(u);
 83:         vc.setCodeHash(encoder.encode(code));
 84:         vc.setExpiresAt(Instant.now().plus(Duration.ofMinutes(props.getVerification().getTtlMinutes())));
 85:         codes.save(vc);
 86:         this.email.sendVerificationCode(u.getEmail(), code);
 87:         audit.record("USER_SIGNUP", u.getId(), u.getEmail(), null, null);
 88:     }
 89:     @Transactional
 90:     public void verify(String emailAddr, String code) {
 91:         if (!verifyLimiter.tryConsume("verify:" + emailAddr.toLowerCase())) {
 92:             throw new ApiException(429, "Too many verification attempts.");
 93:         }
 94:         User u = users.findByEmailIgnoreCase(emailAddr).orElseThrow(() -> generic());
 95:         VerificationCode vc = codes.findActiveForUser(u, Instant.now()).orElseThrow(() -> generic());
 96:         if (vc.getAttempts() >= props.getVerification().getMaxAttempts()) {
 97:             throw generic();
 98:         }
 99:         vc.setAttempts(vc.getAttempts() + 1);
100:         if (!encoder.matches(code, vc.getCodeHash())) {
101:             codes.save(vc);
102:             throw generic();
103:         }
104:         vc.setConsumedAt(Instant.now());
105:         codes.save(vc);
106:         u.setVerified(true);
107:         users.save(u);
108:         audit.record("USER_VERIFIED", u.getId(), u.getEmail(), null, null);
109:     }
110:     @Transactional
111:     public String login(String emailAddr, String password) {
112:         if (!loginLimiter.tryConsume("login:" + emailAddr.toLowerCase())) {
113:             throw new ApiException(429, "Too many login attempts.");
114:         }
115:         User u = users.findByEmailIgnoreCase(emailAddr).orElseThrow(this::genericAuth);
116:         if (!u.isEnabled() || !u.isVerified()) throw genericAuth();
117:         if (!encoder.matches(password, u.getPasswordHash())) throw genericAuth();
118:         List<String> roleNames = u.getRoles().stream().map(Role::getName).toList();
119:         audit.record("USER_LOGIN", u.getId(), u.getEmail(), null, null);
120:         return jwt.issueToken(u.getEmail(), roleNames);
121:     }
122:     private static String generateCode(int length) {
123:         StringBuilder b = new StringBuilder(length);
124:         for (int i = 0; i < length; i++) b.append(DIGITS.charAt(RNG.nextInt(10)));
125:         return b.toString();
126:     }
127:     private static ApiException generic() {
128:         return new ApiException(400, "Invalid or expired verification code.");
129:     }
130:     private ApiException genericAuth() {
131:         return new ApiException(401, "Invalid credentials.");
132:     }
133: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/util/RateLimiter.java
````java
 1: package com.talorlik.javaapp.util;
 2: import io.github.bucket4j.Bandwidth;
 3: import io.github.bucket4j.Bucket;
 4: import java.time.Duration;
 5: import java.util.concurrent.ConcurrentHashMap;
 6: /**
 7:  * In-memory token-bucket per (endpoint, key) pair. Sufficient for a small
 8:  * fleet (per-instance counters); behind an ALB the practical surface is
 9:  * still bounded by max instances. For a stricter global limit, swap to a
10:  * Redis-backed bucket or rely on the WAF rate-limit rule.
11:  */
12: public class RateLimiter {
13:     private final ConcurrentHashMap<String, Bucket> buckets = new ConcurrentHashMap<>();
14:     private final long limit;
15:     private final Duration window;
16:     public RateLimiter(long limit, Duration window) {
17:         this.limit = limit;
18:         this.window = window;
19:     }
20:     public boolean tryConsume(String key) {
21:         return buckets.computeIfAbsent(key, k -> Bucket.builder()
22:             .addLimit(Bandwidth.builder().capacity(limit).refillIntervally(limit, window).build())
23:             .build()
24:         ).tryConsume(1);
25:     }
26: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/JavaAppApplication.java
````java
1: package com.talorlik.javaapp;
2: import org.springframework.boot.SpringApplication;
3: import org.springframework.boot.autoconfigure.SpringBootApplication;
4: @SpringBootApplication
5: public class JavaAppApplication {
6:     public static void main(String[] args) {
7:         SpringApplication.run(JavaAppApplication.class, args);
8:     }
9: }
````

## File: app/backend/src/main/resources/db/migration/V1__create_users.sql
````sql
 1: -- V1__create_users.sql
 2: CREATE TABLE users (
 3:     id              BIGINT       NOT NULL AUTO_INCREMENT,
 4:     email           VARCHAR(255) NOT NULL,
 5:     password_hash   VARCHAR(255) NOT NULL,
 6:     full_name       VARCHAR(255) NOT NULL,
 7:     verified        TINYINT(1)   NOT NULL DEFAULT 0,
 8:     enabled         TINYINT(1)   NOT NULL DEFAULT 1,
 9:     created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
10:     updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
11:     PRIMARY KEY (id),
12:     UNIQUE KEY uq_users_email (email),
13:     KEY idx_users_created_at (created_at),
14:     KEY idx_users_verified (verified)
15: ) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
````

## File: app/backend/src/main/resources/db/migration/V2__create_roles.sql
````sql
 1: -- V2__create_roles.sql
 2: CREATE TABLE roles (
 3:     id    BIGINT       NOT NULL AUTO_INCREMENT,
 4:     name  VARCHAR(50)  NOT NULL,
 5:     PRIMARY KEY (id),
 6:     UNIQUE KEY uq_roles_name (name)
 7: ) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 8: CREATE TABLE user_roles (
 9:     user_id BIGINT NOT NULL,
10:     role_id BIGINT NOT NULL,
11:     PRIMARY KEY (user_id, role_id),
12:     CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
13:     CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
14: ) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
15: INSERT INTO roles (name) VALUES ('ROLE_USER'), ('ROLE_ADMIN');
````

## File: app/backend/src/main/resources/db/migration/V3__create_verification_codes.sql
````sql
 1: -- V3__create_verification_codes.sql
 2: CREATE TABLE verification_codes (
 3:     id          BIGINT       NOT NULL AUTO_INCREMENT,
 4:     user_id     BIGINT       NOT NULL,
 5:     code_hash   VARCHAR(255) NOT NULL,
 6:     attempts    INT          NOT NULL DEFAULT 0,
 7:     expires_at  DATETIME     NOT NULL,
 8:     consumed_at DATETIME     NULL,
 9:     created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
10:     PRIMARY KEY (id),
11:     KEY idx_vc_user (user_id),
12:     KEY idx_vc_expires (expires_at),
13:     CONSTRAINT fk_vc_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
14: ) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
````

## File: app/backend/src/main/resources/db/migration/V4__create_audit_events.sql
````sql
 1: -- V4__create_audit_events.sql
 2: CREATE TABLE audit_events (
 3:     id         BIGINT       NOT NULL AUTO_INCREMENT,
 4:     actor_id   BIGINT       NULL,
 5:     actor_email VARCHAR(255) NULL,
 6:     action     VARCHAR(100) NOT NULL,
 7:     target     VARCHAR(255) NULL,
 8:     metadata   JSON         NULL,
 9:     created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
10:     PRIMARY KEY (id),
11:     KEY idx_audit_action (action),
12:     KEY idx_audit_actor (actor_id),
13:     KEY idx_audit_created (created_at)
14: ) ENGINE=InnoDB CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
````

## File: app/backend/src/main/resources/application-local.yml
````yaml
 1: # Local / CI-smoke profile. Activated by SPRING_PROFILES_ACTIVE=local
 2: # (set in app/docker/docker-compose.local.yml).
 3: #
 4: # Goal: boot the backend without any AWS call. Combined with the existing
 5: # disabled SES path, this profile makes the local stack hermetic.
 6: #
 7: # Inline JWT key default below is a placeholder; override JWT_INLINE_KEY at
 8: # runtime if you need a stable value across runs. The InlineJwtSecretProvider
 9: # enforces a 32-byte minimum at construction.
10: app:
11:   jwt:
12:     secret-source: inline
13:     inline-key: ${JWT_INLINE_KEY:dev-only-not-a-real-key-32bytes-minimum-xx}
14:     inline-issuer: java-app-local
15:   admin:
16:     seed-enabled: false
17:   ses:
18:     enabled: false
````

## File: app/backend/src/test/java/com/talorlik/javaapp/unit/PasswordPolicyTest.java
````java
 1: package com.talorlik.javaapp.unit;
 2: import org.junit.jupiter.api.Test;
 3: import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
 4: import static org.assertj.core.api.Assertions.assertThat;
 5: class PasswordPolicyTest {
 6:     @Test
 7:     void bcrypt_hash_verifies() {
 8:         var encoder = new BCryptPasswordEncoder(10);
 9:         String hash = encoder.encode("CorrectHorseBatteryStaple");
10:         assertThat(encoder.matches("CorrectHorseBatteryStaple", hash)).isTrue();
11:         assertThat(encoder.matches("wrong", hash)).isFalse();
12:     }
13: }
````

## File: app/backend/.dockerignore
````
1: target/
2: .git/
3: .idea/
4: *.iml
5: node_modules/
6: .gradle/
7: .mvn/
````

## File: app/backend/Dockerfile
````
 1: ###############################################################################
 2: # Multi-stage Dockerfile for Java 21 Spring Boot backend.
 3: #
 4: # Stage 1: Maven build (with build cache layer).
 5: # Stage 2: Eclipse Temurin 21 JRE Alpine, non-root user.
 6: ###############################################################################
 7: 
 8: # ----- builder -----
 9: FROM maven:3.9-eclipse-temurin-21 AS builder
10: WORKDIR /build
11: 
12: # Cache dependencies first
13: COPY pom.xml ./
14: RUN mvn -B -q dependency:go-offline
15: 
16: COPY src ./src
17: RUN mvn -B -q -DskipTests package
18: 
19: # ----- runtime -----
20: FROM eclipse-temurin:21-jre-alpine AS runtime
21: 
22: # Non-root
23: RUN addgroup -S app && adduser -S -G app app
24: 
25: # curl for healthchecks
26: RUN apk add --no-cache curl
27: 
28: WORKDIR /app
29: COPY --from=builder /build/target/app.jar /app/app.jar
30: 
31: USER app
32: EXPOSE 8080
33: 
34: # Sane JVM defaults for containers (sized via cgroup, exit on OOM, UTF-8).
35: ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError -Dfile.encoding=UTF-8 -Duser.timezone=UTC"
36: 
37: HEALTHCHECK --interval=15s --timeout=3s --start-period=30s --retries=10 \
38:   CMD curl -fsS http://localhost:8080/actuator/health || exit 1
39: 
40: ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
````

## File: app/backend/mvnw
````
  1: #!/bin/sh
  2: # ----------------------------------------------------------------------------
  3: # Apache Maven Wrapper, script-only mode (no jar checked in).
  4: #
  5: # Resolves the Maven distribution declared in
  6: # .mvn/wrapper/maven-wrapper.properties (distributionUrl +
  7: # distributionSha256Sum), caches it under
  8: # ${MAVEN_USER_HOME:-$HOME/.m2}/wrapper/dists/<basename>/<urlhash>/, and
  9: # execs the cached mvn with all forwarded arguments.
 10: #
 11: # Behavior is intentionally close to the official Apache Maven Wrapper
 12: # (https://maven.apache.org/wrapper/) so existing CI and IDE integrations
 13: # work unchanged.
 14: # ----------------------------------------------------------------------------
 15: 
 16: set -euf
 17: 
 18: # ---- helpers ---------------------------------------------------------------
 19: die() { printf 'mvnw: %s\n' "$*" >&2; exit 1; }
 20: 
 21: # Resolve a sha256 of stdin, preferring shasum (BSD/macOS), falling back to
 22: # sha256sum (GNU/Linux). Either is universally available on the platforms
 23: # this wrapper targets.
 24: sha256_stdin() {
 25:   if command -v shasum >/dev/null 2>&1; then
 26:     shasum -a 256 | awk '{print $1}'
 27:   elif command -v sha256sum >/dev/null 2>&1; then
 28:     sha256sum | awk '{print $1}'
 29:   else
 30:     die "neither shasum nor sha256sum is available on PATH"
 31:   fi
 32: }
 33: 
 34: sha256_file() {
 35:   if command -v shasum >/dev/null 2>&1; then
 36:     shasum -a 256 "$1" | awk '{print $1}'
 37:   elif command -v sha256sum >/dev/null 2>&1; then
 38:     sha256sum "$1" | awk '{print $1}'
 39:   else
 40:     die "neither shasum nor sha256sum is available on PATH"
 41:   fi
 42: }
 43: 
 44: # ---- resolve project basedir (handle symlinks) -----------------------------
 45: PRG="$0"
 46: while [ -h "$PRG" ]; do
 47:   ls=$(ls -ld "$PRG")
 48:   link=$(expr "$ls" : '.*-> \(.*\)$' || true)
 49:   if expr "$link" : '/.*' >/dev/null; then
 50:     PRG="$link"
 51:   else
 52:     PRG="$(dirname "$PRG")/$link"
 53:   fi
 54: done
 55: PROJECT_BASEDIR=$(cd "$(dirname "$PRG")" >/dev/null 2>&1 && pwd)
 56: export MAVEN_PROJECTBASEDIR="$PROJECT_BASEDIR"
 57: 
 58: # ---- read wrapper properties ----------------------------------------------
 59: WRAPPER_PROPS="$PROJECT_BASEDIR/.mvn/wrapper/maven-wrapper.properties"
 60: [ -f "$WRAPPER_PROPS" ] || die "missing $WRAPPER_PROPS"
 61: 
 62: # Strip CRs so the wrapper tolerates Windows-edited properties files.
 63: distUrl=$(awk -F= '/^distributionUrl=/{ sub(/\r$/,""); print substr($0, index($0, "=")+1) }' "$WRAPPER_PROPS")
 64: distSha=$(awk -F= '/^distributionSha256Sum=/{ sub(/\r$/,""); print substr($0, index($0, "=")+1) }' "$WRAPPER_PROPS")
 65: [ -n "${distUrl:-}" ] || die "distributionUrl is empty in $WRAPPER_PROPS"
 66: 
 67: # Allow MVNW_REPOURL to override the distributionUrl host (mirror support).
 68: if [ -n "${MVNW_REPOURL:-}" ]; then
 69:   distUrl=$(printf '%s' "$distUrl" | awk -v repo="$MVNW_REPOURL" '{ sub(/^https?:\/\/[^\/]+/, repo); print }')
 70: fi
 71: 
 72: distArchive=$(basename "$distUrl")
 73: case "$distArchive" in
 74:   *-bin.zip) distName=${distArchive%-bin.zip} ;;
 75:   *) die "unsupported distribution archive name: $distArchive" ;;
 76: esac
 77: 
 78: # Per-URL hash so a re-pinned distribution gets a fresh cache directory.
 79: distUrlHash=$(printf '%s' "$distUrl" | sha256_stdin)
 80: 
 81: WRAPPER_HOME="${MAVEN_USER_HOME:-$HOME/.m2}/wrapper/dists"
 82: DIST_PARENT="$WRAPPER_HOME/$distName/$distUrlHash"
 83: MVN_HOME="$DIST_PARENT/$distName"
 84: 
 85: # ---- download + verify + extract on cache miss -----------------------------
 86: if [ ! -x "$MVN_HOME/bin/mvn" ]; then
 87:   mkdir -p "$DIST_PARENT"
 88:   archive="$DIST_PARENT/$distArchive"
 89: 
 90:   if [ ! -f "$archive" ]; then
 91:     printf 'mvnw: downloading %s ...\n' "$distUrl" >&2
 92:     if command -v curl >/dev/null 2>&1; then
 93:       curl -fsSL --retry 3 -o "$archive.part" "$distUrl"
 94:     elif command -v wget >/dev/null 2>&1; then
 95:       wget -q -O "$archive.part" "$distUrl"
 96:     else
 97:       die "neither curl nor wget is available on PATH"
 98:     fi
 99:     mv "$archive.part" "$archive"
100:   fi
101: 
102:   if [ -n "${distSha:-}" ]; then
103:     actualSha=$(sha256_file "$archive")
104:     if [ "$actualSha" != "$distSha" ]; then
105:       rm -f "$archive"
106:       die "checksum mismatch on $archive (expected $distSha got $actualSha)"
107:     fi
108:   fi
109: 
110:   if command -v unzip >/dev/null 2>&1; then
111:     (cd "$DIST_PARENT" && unzip -q "$distArchive")
112:   elif command -v jar >/dev/null 2>&1; then
113:     (cd "$DIST_PARENT" && jar xf "$distArchive")
114:   else
115:     die "neither unzip nor jar is available on PATH"
116:   fi
117:   rm -f "$archive"
118: fi
119: 
120: [ -x "$MVN_HOME/bin/mvn" ] || die "Maven not found at $MVN_HOME/bin/mvn after extraction"
121: 
122: exec "$MVN_HOME/bin/mvn" "$@"
````

## File: app/backend/mvnw.cmd
````batch
 1: @REM ---------------------------------------------------------------------------
 2: @REM Apache Maven Wrapper, script-only mode (no jar checked in) - Windows.
 3: @REM
 4: @REM Resolves the Maven distribution declared in
 5: @REM .mvn\wrapper\maven-wrapper.properties (distributionUrl +
 6: @REM distributionSha256Sum), caches it under
 7: @REM %MAVEN_USER_HOME%\wrapper\dists\<basename>\<urlhash>\, and runs the
 8: @REM cached mvn with all forwarded arguments.
 9: @REM ---------------------------------------------------------------------------
10: 
11: @echo off
12: setlocal EnableExtensions EnableDelayedExpansion
13: 
14: set "PROJECT_BASEDIR=%~dp0"
15: if "%PROJECT_BASEDIR:~-1%"=="\" set "PROJECT_BASEDIR=%PROJECT_BASEDIR:~0,-1%"
16: set "MAVEN_PROJECTBASEDIR=%PROJECT_BASEDIR%"
17: 
18: set "WRAPPER_PROPS=%PROJECT_BASEDIR%\.mvn\wrapper\maven-wrapper.properties"
19: if not exist "%WRAPPER_PROPS%" (
20:   echo mvnw: missing %WRAPPER_PROPS% 1>&2
21:   exit /b 1
22: )
23: 
24: set "DIST_URL="
25: set "DIST_SHA="
26: for /f "usebackq tokens=1,* delims==" %%A in ("%WRAPPER_PROPS%") do (
27:   if /i "%%A"=="distributionUrl"        set "DIST_URL=%%B"
28:   if /i "%%A"=="distributionSha256Sum"  set "DIST_SHA=%%B"
29: )
30: if "%DIST_URL%"=="" (
31:   echo mvnw: distributionUrl is empty in %WRAPPER_PROPS% 1>&2
32:   exit /b 1
33: )
34: 
35: if not "%MVNW_REPOURL%"=="" (
36:   for /f "tokens=1,2,* delims=/" %%a in ("%DIST_URL%") do set "DIST_URL=%MVNW_REPOURL%/%%c"
37: )
38: 
39: for %%I in ("%DIST_URL%") do set "DIST_ARCHIVE=%%~nxI"
40: set "DIST_NAME=%DIST_ARCHIVE:-bin.zip=%"
41: 
42: set "MAVEN_USER_HOME_DIR=%MAVEN_USER_HOME%"
43: if "%MAVEN_USER_HOME_DIR%"=="" set "MAVEN_USER_HOME_DIR=%USERPROFILE%\.m2"
44: 
45: REM Per-URL hash so a re-pinned distribution gets a fresh cache directory.
46: for /f "delims=" %%H in ('powershell -NoProfile -Command "$sha=[System.Security.Cryptography.SHA256]::Create(); $h=$sha.ComputeHash([Text.Encoding]::UTF8.GetBytes('%DIST_URL%')); ($h | ForEach-Object { $_.ToString('x2') }) -join ''"') do set "DIST_URL_HASH=%%H"
47: 
48: set "WRAPPER_HOME=%MAVEN_USER_HOME_DIR%\wrapper\dists"
49: set "DIST_PARENT=%WRAPPER_HOME%\%DIST_NAME%\%DIST_URL_HASH%"
50: set "MVN_HOME=%DIST_PARENT%\%DIST_NAME%"
51: 
52: if not exist "%MVN_HOME%\bin\mvn.cmd" (
53:   if not exist "%DIST_PARENT%" mkdir "%DIST_PARENT%"
54:   set "ARCHIVE=%DIST_PARENT%\%DIST_ARCHIVE%"
55: 
56:   if not exist "!ARCHIVE!" (
57:     echo mvnw: downloading %DIST_URL% ... 1>&2
58:     powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -Uri '%DIST_URL%' -OutFile '!ARCHIVE!.part'"
59:     if errorlevel 1 ( echo mvnw: download failed 1>&2 & exit /b 1 )
60:     move /y "!ARCHIVE!.part" "!ARCHIVE!" >nul
61:   )
62: 
63:   if not "%DIST_SHA%"=="" (
64:     for /f "delims=" %%S in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -Path '!ARCHIVE!').Hash.ToLower()"') do set "ACTUAL_SHA=%%S"
65:     if /i not "!ACTUAL_SHA!"=="%DIST_SHA%" (
66:       del /q "!ARCHIVE!" >nul 2>&1
67:       echo mvnw: checksum mismatch (expected %DIST_SHA% got !ACTUAL_SHA!) 1>&2
68:       exit /b 1
69:     )
70:   )
71: 
72:   powershell -NoProfile -Command "Expand-Archive -Force -LiteralPath '!ARCHIVE!' -DestinationPath '%DIST_PARENT%'"
73:   if errorlevel 1 ( echo mvnw: extraction failed 1>&2 & exit /b 1 )
74:   del /q "!ARCHIVE!" >nul 2>&1
75: )
76: 
77: if not exist "%MVN_HOME%\bin\mvn.cmd" (
78:   echo mvnw: Maven not found at %MVN_HOME%\bin\mvn.cmd after extraction 1>&2
79:   exit /b 1
80: )
81: 
82: call "%MVN_HOME%\bin\mvn.cmd" %*
83: exit /b %ERRORLEVEL%
````

## File: app/docker/docker-compose.prod.yml
````yaml
 1: ###############################################################################
 2: # Production compose file.
 3: #
 4: # - DB is external (RDS) - no mysql service here.
 5: # - Image references come from /opt/java-app/.env, written by EC2 user data.
 6: # - Backend reads runtime secrets from Secrets Manager via the instance role.
 7: #
 8: # This file is uploaded by CI to the S3 location pointed at by the
 9: # /java-app/prod/compose-object SSM parameter, and pulled by EC2 user-data.
10: ###############################################################################
11: services:
12:   backend:
13:     image: "${BACKEND_IMAGE}"
14:     restart: unless-stopped
15:     env_file:
16:       - /opt/java-app/.env
17:     expose:
18:       - "8080"
19:     healthcheck:
20:       test: ["CMD", "curl", "-fsS", "http://localhost:8080/actuator/health"]
21:       interval: 15s
22:       timeout: 5s
23:       retries: 10
24:       start_period: 60s
25:     logging:
26:       driver: json-file
27:       options:
28:         max-size: "10m"
29:         max-file: "5"
30:   frontend:
31:     image: "${FRONTEND_IMAGE}"
32:     restart: unless-stopped
33:     ports:
34:       - "8080:80"
35:     depends_on:
36:       backend:
37:         condition: service_healthy
38:     logging:
39:       driver: json-file
40:       options:
41:         max-size: "10m"
42:         max-file: "5"
````

## File: app/frontend/src/css/main.css
````css
 1: :root {
 2:   --bg: #0e1117;
 3:   --fg: #e6edf3;
 4:   --muted: #8b949e;
 5:   --accent: #58a6ff;
 6:   --danger: #f85149;
 7:   --ok: #3fb950;
 8:   --card: #161b22;
 9:   --border: #30363d;
10: }
11: * { box-sizing: border-box; }
12: html, body { margin: 0; padding: 0; background: var(--bg); color: var(--fg); font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
13: a { color: var(--accent); text-decoration: none; }
14: a:hover { text-decoration: underline; }
15: .topbar, .bottombar {
16:   display: flex; align-items: center; gap: 16px;
17:   padding: 12px 24px;
18:   border-bottom: 1px solid var(--border);
19:   background: #0a0d12;
20: }
21: .bottombar { border-top: 1px solid var(--border); border-bottom: none; color: var(--muted); }
22: .brand { font-weight: 700; }
23: main { padding: 32px 24px; max-width: 960px; margin: 0 auto; }
24: .card {
25:   background: var(--card);
26:   border: 1px solid var(--border);
27:   border-radius: 8px;
28:   padding: 24px;
29:   margin-bottom: 16px;
30: }
31: h1, h2 { margin-top: 0; }
32: .muted { color: var(--muted); }
33: label { display: block; margin-bottom: 6px; font-size: 14px; }
34: input, select, textarea, button {
35:   font-family: inherit;
36:   font-size: 14px;
37:   padding: 8px 10px;
38:   border-radius: 6px;
39:   border: 1px solid var(--border);
40:   background: #0d1117;
41:   color: var(--fg);
42:   width: 100%;
43:   margin-bottom: 12px;
44: }
45: button {
46:   cursor: pointer;
47:   background: var(--accent);
48:   color: #0e1117;
49:   font-weight: 600;
50:   border: none;
51: }
52: button.secondary { background: transparent; color: var(--fg); border: 1px solid var(--border); }
53: button:disabled { opacity: 0.6; cursor: not-allowed; }
54: .error { color: var(--danger); margin: 8px 0; }
55: .ok    { color: var(--ok); margin: 8px 0; }
56: table { width: 100%; border-collapse: collapse; }
57: th, td { padding: 8px; border-bottom: 1px solid var(--border); text-align: left; font-size: 14px; }
58: .toolbar { display: flex; gap: 8px; margin-bottom: 12px; align-items: center; }
59: .pager { display: flex; gap: 8px; align-items: center; margin-top: 12px; }
60: nav a { margin-left: 12px; }
````

## File: app/frontend/src/js/pages/admin_edit.js
````javascript
 1: import { api, getToken } from '/js/api.js';
 2: import { navigate } from '/js/router.js';
 3: export async function renderAdminEdit(out, ctx) {
 4:   if (!getToken()) { navigate('/login'); return; }
 5:   const id = ctx.params.id;
 6:   let u;
 7:   try { u = await api.adminGet(id); } catch (e) {
 8:     out.innerHTML = `<div class="card error">${escape(e.message)}</div>`; return;
 9:   }
10:   out.innerHTML = `
11:     <div class="card">
12:       <h2>User #${u.id}</h2>
13:       <p><b>Email</b>: ${escape(u.email)}</p>
14:       <form id="f">
15:         <label>Full name <input name="fullName" value="${escape(u.fullName)}"></label>
16:         <label><input type="checkbox" name="enabled" ${u.enabled ? 'checked' : ''}> Enabled</label>
17:         <label><input type="checkbox" name="resetVerification"> Reset verification status</label>
18:         <button type="submit">Save</button>
19:         <button type="button" id="del" class="secondary">Delete</button>
20:       </form>
21:       <p id="msg"></p>
22:     </div>`;
23:   out.querySelector('#f').addEventListener('submit', async e => {
24:     e.preventDefault();
25:     const fd = new FormData(e.target);
26:     try {
27:       await api.adminUpdate(id, {
28:         fullName: fd.get('fullName'),
29:         enabled: fd.get('enabled') === 'on',
30:         resetVerification: fd.get('resetVerification') === 'on',
31:       });
32:       out.querySelector('#msg').innerHTML = `<span class="ok">Saved.</span>`;
33:     } catch (err) {
34:       out.querySelector('#msg').innerHTML = `<span class="error">${escape(err.message)}</span>`;
35:     }
36:   });
37:   out.querySelector('#del').addEventListener('click', async () => {
38:     if (!confirm(`Delete user ${u.email}?`)) return;
39:     try { await api.adminDelete(id); navigate('/admin/users'); }
40:     catch (err) { out.querySelector('#msg').innerHTML = `<span class="error">${escape(err.message)}</span>`; }
41:   });
42: }
43: function escape(s) {
44:   return String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c]);
45: }
````

## File: app/frontend/src/js/pages/admin_list.js
````javascript
 1: import { api, getToken } from '/js/api.js';
 2: import { navigate } from '/js/router.js';
 3: export async function renderAdminList(out, ctx) {
 4:   if (!getToken()) { navigate('/login'); return; }
 5:   const params = {
 6:     page: ctx.query.page || 0,
 7:     size: ctx.query.size || 20,
 8:     sort: ctx.query.sort || 'createdAt',
 9:     dir:  ctx.query.dir  || 'desc',
10:     q:    ctx.query.q    || '',
11:     verified: ctx.query.verified || ''
12:   };
13:   let data;
14:   try {
15:     data = await api.adminList(stripEmpty(params));
16:   } catch (e) {
17:     out.innerHTML = `<div class="card error">${escape(e.message)}</div>`;
18:     return;
19:   }
20:   out.innerHTML = `
21:     <div class="card">
22:       <div class="toolbar">
23:         <input id="q" placeholder="search" value="${escape(params.q)}">
24:         <select id="verified">
25:           <option value="">all</option>
26:           <option value="true"  ${params.verified==='true'  ? 'selected':''}>verified</option>
27:           <option value="false" ${params.verified==='false' ? 'selected':''}>unverified</option>
28:         </select>
29:         <button id="apply">Apply</button>
30:         <a href="${api.adminCsvUrl()}" download><button class="secondary">Export CSV</button></a>
31:       </div>
32:       <table>
33:         <thead>
34:           <tr><th>id</th><th>email</th><th>name</th><th>verified</th><th>enabled</th><th>created</th><th></th></tr>
35:         </thead>
36:         <tbody>
37:           ${data.items.map(rowHtml).join('')}
38:         </tbody>
39:       </table>
40:       <div class="pager">
41:         <button class="secondary" id="prev" ${data.page<=0?'disabled':''}>Prev</button>
42:         <span class="muted">page ${data.page+1} / ${data.totalPages}</span>
43:         <button class="secondary" id="next" ${data.page+1>=data.totalPages?'disabled':''}>Next</button>
44:       </div>
45:     </div>`;
46:   out.querySelector('#apply').onclick = () => {
47:     const q = out.querySelector('#q').value;
48:     const verified = out.querySelector('#verified').value;
49:     navigate(`/admin/users?q=${encodeURIComponent(q)}&verified=${verified}`);
50:   };
51:   out.querySelector('#prev').onclick = () => navigate(buildUrl(params, +params.page-1));
52:   out.querySelector('#next').onclick = () => navigate(buildUrl(params, +params.page+1));
53: }
54: function rowHtml(u) {
55:   return `<tr>
56:     <td>${u.id}</td>
57:     <td>${escape(u.email)}</td>
58:     <td>${escape(u.fullName)}</td>
59:     <td>${u.verified}</td>
60:     <td>${u.enabled}</td>
61:     <td>${escape(u.createdAt)}</td>
62:     <td><a href="/admin/users/${u.id}" data-link>edit</a></td>
63:   </tr>`;
64: }
65: function buildUrl(p, page) {
66:   const o = { ...p, page };
67:   return `/admin/users?${new URLSearchParams(stripEmpty(o)).toString()}`;
68: }
69: function stripEmpty(o) { return Object.fromEntries(Object.entries(o).filter(([,v]) => v !== '' && v !== null && v !== undefined)); }
70: function escape(s) {
71:   return String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c]);
72: }
````

## File: app/frontend/src/js/pages/login.js
````javascript
 1: import { api, setToken } from '/js/api.js';
 2: import { navigate } from '/js/router.js';
 3: export function renderLogin(out) {
 4:   out.innerHTML = `
 5:     <div class="card">
 6:       <h2>Login</h2>
 7:       <form id="f">
 8:         <label>Email <input name="email" type="email" required></label>
 9:         <label>Password <input name="password" type="password" required></label>
10:         <button type="submit">Login</button>
11:       </form>
12:       <p id="msg"></p>
13:     </div>`;
14:   out.querySelector('#f').addEventListener('submit', async e => {
15:     e.preventDefault();
16:     const fd = new FormData(e.target);
17:     try {
18:       const res = await api.login(fd.get('email'), fd.get('password'));
19:       setToken(res.token);
20:       navigate('/profile');
21:     } catch (err) {
22:       out.querySelector('#msg').innerHTML = `<span class="error">${err.message}</span>`;
23:     }
24:   });
25: }
````

## File: app/frontend/src/js/pages/profile.js
````javascript
 1: import { api, getToken } from '/js/api.js';
 2: import { navigate } from '/js/router.js';
 3: export async function renderProfile(out) {
 4:   if (!getToken()) { navigate('/login'); return; }
 5:   let me;
 6:   try {
 7:     me = await api.me();
 8:   } catch (e) {
 9:     navigate('/login'); return;
10:   }
11:   out.innerHTML = `
12:     <div class="card">
13:       <h2>Your profile</h2>
14:       <p><b>Email</b>: <span class="muted">${escape(me.email)}</span> <span class="muted">(read-only)</span></p>
15:       <form id="f">
16:         <label>Full name <input name="fullName" value="${escape(me.fullName)}" required></label>
17:         <button type="submit">Save</button>
18:       </form>
19:       <p id="msg"></p>
20:     </div>`;
21:   out.querySelector('#f').addEventListener('submit', async e => {
22:     e.preventDefault();
23:     const fd = new FormData(e.target);
24:     try {
25:       await api.updateMe({ fullName: fd.get('fullName') });
26:       out.querySelector('#msg').innerHTML = `<span class="ok">Saved.</span>`;
27:     } catch (err) {
28:       out.querySelector('#msg').innerHTML = `<span class="error">${escape(err.message)}</span>`;
29:     }
30:   });
31: }
32: function escape(s) {
33:   return String(s).replace(/[&<>"']/g, c => ({
34:     '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'
35:   })[c]);
36: }
````

## File: app/frontend/src/js/pages/signup.js
````javascript
 1: import { api } from '/js/api.js';
 2: import { navigate } from '/js/router.js';
 3: export function renderSignup(out) {
 4:   out.innerHTML = `
 5:     <div class="card">
 6:       <h2>Sign up</h2>
 7:       <form id="f">
 8:         <label>Email <input name="email" type="email" required></label>
 9:         <label>Full name <input name="fullName" required></label>
10:         <label>Password (min 12) <input name="password" type="password" minlength="12" required></label>
11:         <button type="submit">Create account</button>
12:       </form>
13:       <p id="msg"></p>
14:     </div>`;
15:   out.querySelector('#f').addEventListener('submit', async e => {
16:     e.preventDefault();
17:     const fd = new FormData(e.target);
18:     try {
19:       await api.signup(fd.get('email'), fd.get('password'), fd.get('fullName'));
20:       sessionStorageSafe('pendingEmail', fd.get('email'));
21:       navigate('/verify');
22:     } catch (err) {
23:       out.querySelector('#msg').innerHTML = `<span class="error">${err.message}</span>`;
24:     }
25:   });
26: }
27: function sessionStorageSafe(k, v) {
28:   try { sessionStorage.setItem(k, v); } catch (_) {}
29: }
````

## File: app/frontend/src/js/pages/thanks.js
````javascript
1: export function renderThanks(out) {
2:   out.innerHTML = `
3:     <div class="card">
4:       <h2>Thanks for signing up</h2>
5:       <p>Your account is verified.</p>
6:       <p><a href="/login" data-link><button>Continue to login</button></a></p>
7:     </div>`;
8: }
````

## File: app/frontend/src/js/pages/verify.js
````javascript
 1: import { api } from '/js/api.js';
 2: import { navigate } from '/js/router.js';
 3: export function renderVerify(out) {
 4:   let pending = '';
 5:   try { pending = sessionStorage.getItem('pendingEmail') || ''; } catch (_) {}
 6:   out.innerHTML = `
 7:     <div class="card">
 8:       <h2>Verify your email</h2>
 9:       <p class="muted">Enter the code we sent to your email.</p>
10:       <form id="f">
11:         <label>Email <input name="email" type="email" required value="${pending}"></label>
12:         <label>Verification code <input name="code" required></label>
13:         <button type="submit">Verify</button>
14:       </form>
15:       <p id="msg"></p>
16:     </div>`;
17:   out.querySelector('#f').addEventListener('submit', async e => {
18:     e.preventDefault();
19:     const fd = new FormData(e.target);
20:     try {
21:       await api.verify(fd.get('email'), fd.get('code'));
22:       navigate('/thank-you');
23:     } catch (err) {
24:       out.querySelector('#msg').innerHTML = `<span class="error">${err.message}</span>`;
25:     }
26:   });
27: }
````

## File: app/frontend/src/js/api.js
````javascript
 1: // Thin fetch wrapper. JWT is kept in memory only (page-scoped). Reload = logout.
 2: const TOKEN = { value: null };
 3: export function setToken(t)  { TOKEN.value = t; }
 4: export function getToken()   { return TOKEN.value; }
 5: export function clearToken() { TOKEN.value = null; }
 6: async function call(path, { method = 'GET', body, auth = false } = {}) {
 7:   const headers = { 'Content-Type': 'application/json' };
 8:   if (auth && TOKEN.value) headers['Authorization'] = `Bearer ${TOKEN.value}`;
 9:   const res = await fetch(path, {
10:     method,
11:     headers,
12:     body: body ? JSON.stringify(body) : undefined,
13:     credentials: 'omit',
14:   });
15:   let data = null;
16:   const ct = res.headers.get('content-type') || '';
17:   if (ct.includes('application/json')) {
18:     data = await res.json().catch(() => null);
19:   } else if (ct.startsWith('text/')) {
20:     data = await res.text().catch(() => null);
21:   }
22:   if (!res.ok) {
23:     const msg = (data && data.message) || `Request failed (${res.status})`;
24:     const err = new Error(msg);
25:     err.status = res.status;
26:     throw err;
27:   }
28:   return data;
29: }
30: export const api = {
31:   signup: (email, password, fullName) => call('/api/auth/signup', { method: 'POST', body: { email, password, fullName } }),
32:   verify: (email, code)               => call('/api/auth/verify', { method: 'POST', body: { email, code } }),
33:   login:  (email, password)           => call('/api/auth/login',  { method: 'POST', body: { email, password } }),
34:   me:           ()        => call('/api/profile', { auth: true }),
35:   updateMe:     (payload) => call('/api/profile', { method: 'PUT', body: payload, auth: true }),
36:   adminList:    (params)  => call(`/api/admin/users?${new URLSearchParams(params).toString()}`, { auth: true }),
37:   adminGet:     (id)      => call(`/api/admin/users/${id}`, { auth: true }),
38:   adminUpdate:  (id, p)   => call(`/api/admin/users/${id}`, { method: 'PUT', body: p, auth: true }),
39:   adminDelete:  (id)      => call(`/api/admin/users/${id}`, { method: 'DELETE', auth: true }),
40:   adminCsvUrl:  ()        => '/api/admin/users.csv',
41: };
````

## File: app/frontend/src/js/app.js
````javascript
 1: import { route, start, navigate } from '/js/router.js';
 2: import { getToken, clearToken } from '/js/api.js';
 3: import { renderSignup }   from '/js/pages/signup.js';
 4: import { renderVerify }   from '/js/pages/verify.js';
 5: import { renderThanks }   from '/js/pages/thanks.js';
 6: import { renderLogin }    from '/js/pages/login.js';
 7: import { renderProfile }  from '/js/pages/profile.js';
 8: import { renderAdminList } from '/js/pages/admin_list.js';
 9: import { renderAdminEdit } from '/js/pages/admin_edit.js';
10: route('/',                renderLanding);
11: route('/signup',          renderSignup);
12: route('/verify',          renderVerify);
13: route('/thank-you',       renderThanks);
14: route('/login',           renderLogin);
15: route('/profile',         renderProfile,    { auth: true });
16: route('/admin/users',     renderAdminList);
17: route('/admin/users/:id', renderAdminEdit);
18: start({
19:   mount: document.getElementById('app'),
20:   nav:   document.getElementById('nav'),
21:   navBuilder: () => {
22:     if (getToken()) {
23:       return `
24:         <a href="/profile" data-link>Profile</a>
25:         <a href="/admin/users" data-link>Admin</a>
26:         <a href="#" id="logout">Logout</a>`;
27:     }
28:     return `
29:       <a href="/login"  data-link>Login</a>
30:       <a href="/signup" data-link>Sign up</a>`;
31:   },
32: });
33: document.addEventListener('click', e => {
34:   if (e.target?.id === 'logout') {
35:     e.preventDefault();
36:     clearToken();
37:     navigate('/');
38:   }
39: });
40: function renderLanding(out) {
41:   out.innerHTML = `
42:     <div class="card">
43:       <h1>Welcome</h1>
44:       <p>Create an account or log in.</p>
45:       <p>
46:         <a href="/signup" data-link><button>Sign up</button></a>
47:         <a href="/login"  data-link><button class="secondary">Login</button></a>
48:       </p>
49:     </div>`;
50: }
````

## File: app/frontend/src/js/router.js
````javascript
 1: // Tiny hash-free path router (works with the Nginx SPA fallback).
 2: const routes = [];
 3: let outlet, navEl, getNav;
 4: export function route(path, render, opts = {}) {
 5:   routes.push({ path, render, ...opts });
 6: }
 7: export function start({ mount, nav, navBuilder }) {
 8:   outlet = mount;
 9:   navEl = nav;
10:   getNav = navBuilder;
11:   window.addEventListener('popstate', render);
12:   document.addEventListener('click', e => {
13:     const a = e.target.closest('a[data-link]');
14:     if (!a) return;
15:     e.preventDefault();
16:     navigate(a.getAttribute('href'));
17:   });
18:   render();
19: }
20: export function navigate(path) {
21:   history.pushState(null, '', path);
22:   render();
23: }
24: function paramsFor(routePath, urlPath) {
25:   const r = routePath.split('/').filter(Boolean);
26:   const u = urlPath.split('/').filter(Boolean);
27:   if (r.length !== u.length) return null;
28:   const p = {};
29:   for (let i = 0; i < r.length; i++) {
30:     if (r[i].startsWith(':')) p[r[i].slice(1)] = decodeURIComponent(u[i]);
31:     else if (r[i] !== u[i]) return null;
32:   }
33:   return p;
34: }
35: function render() {
36:   const url = new URL(window.location.href);
37:   let matched = null, params = null;
38:   for (const r of routes) {
39:     const p = paramsFor(r.path, url.pathname);
40:     if (p) { matched = r; params = p; break; }
41:   }
42:   navEl.innerHTML = getNav();
43:   if (!matched) {
44:     outlet.innerHTML = `<div class="card"><h2>Not found</h2></div>`;
45:     return;
46:   }
47:   outlet.innerHTML = '';
48:   matched.render(outlet, { params, query: Object.fromEntries(url.searchParams.entries()) });
49: }
````

## File: app/frontend/Dockerfile
````
 1: ###############################################################################
 2: # Frontend Dockerfile - static site + reverse proxy via Nginx Alpine.
 3: ###############################################################################
 4: 
 5: FROM nginx:1.27-alpine
 6: 
 7: RUN apk add --no-cache curl
 8: 
 9: # Custom config replaces the default
10: RUN rm -f /etc/nginx/conf.d/default.conf
11: COPY nginx.conf /etc/nginx/nginx.conf
12: COPY src/ /usr/share/nginx/html/
13: 
14: EXPOSE 80
15: 
16: HEALTHCHECK --interval=15s --timeout=3s --retries=5 \
17:   CMD curl -fsS http://localhost/healthz || exit 1
````

## File: app/frontend/nginx.conf
````ini
 1: ###############################################################################
 2: # nginx.conf
 3: #
 4: # - Serves static SPA from /usr/share/nginx/html.
 5: # - Proxies /api/* to the backend service on 8080 (compose service name
 6: #   "backend").
 7: # - Adds standard security headers + gzip + long cache for assets.
 8: ###############################################################################
 9: 
10: worker_processes auto;
11: error_log /var/log/nginx/error.log warn;
12: pid       /var/run/nginx.pid;
13: 
14: events {
15:     worker_connections 1024;
16: }
17: 
18: http {
19:     include       /etc/nginx/mime.types;
20:     default_type  application/octet-stream;
21: 
22:     log_format main '$remote_addr - $remote_user [$time_local] "$request" '
23:                     '$status $body_bytes_sent "$http_referer" "$http_user_agent"';
24:     access_log /var/log/nginx/access.log main;
25: 
26:     sendfile        on;
27:     keepalive_timeout 65;
28: 
29:     # gzip
30:     gzip on;
31:     gzip_min_length 1024;
32:     gzip_types text/plain text/css application/javascript application/json image/svg+xml;
33:     gzip_vary on;
34: 
35:     # security headers (TR-HARD-010)
36:     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
37:     add_header X-Content-Type-Options    "nosniff" always;
38:     add_header X-Frame-Options           "DENY" always;
39:     add_header Referrer-Policy           "strict-origin-when-cross-origin" always;
40:     add_header Content-Security-Policy   "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'" always;
41: 
42:     upstream backend {
43:         server backend:8080;
44:         keepalive 32;
45:     }
46: 
47:     server {
48:         listen 80 default_server;
49:         listen [::]:80 default_server;
50: 
51:         root /usr/share/nginx/html;
52:         index index.html;
53: 
54:         # Liveness for the container itself
55:         location = /healthz {
56:             access_log off;
57:             add_header Content-Type text/plain;
58:             return 200 "ok\n";
59:         }
60: 
61:         # Reverse-proxy backend health for the ALB target group probe
62:         location = /actuator/health {
63:             proxy_pass http://backend/actuator/health;
64:             proxy_set_header Host $host;
65:             access_log off;
66:         }
67: 
68:         # API
69:         location /api/ {
70:             proxy_pass http://backend;
71:             proxy_http_version 1.1;
72:             proxy_set_header Host              $host;
73:             proxy_set_header Connection        "";
74:             proxy_set_header X-Real-IP         $remote_addr;
75:             proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
76:             proxy_set_header X-Forwarded-Proto $scheme;
77:             proxy_read_timeout 30s;
78:         }
79: 
80:         # Static assets - long cache, fingerprinted filenames recommended
81:         location /assets/ {
82:             expires 30d;
83:             add_header Cache-Control "public, immutable";
84:         }
85: 
86:         # SPA fallback
87:         location / {
88:             try_files $uri /index.html;
89:         }
90:     }
91: }
````

## File: docs/auxiliary/architecture-diagrams/requirements.txt
````
1: # Architecture diagram generation (SETUP.md)
2: # Install: pip install -r requirements.txt
3: # macOS: install pygraphviz separately with brew paths (see SETUP.md)
4: 
5: pygraphviz>=1.11
6: diagrams>=0.25
7: graphviz>=0.20
8: graphviz2drawio>=1.1
````

## File: docs/main.js
````javascript
  1: // Theme management
  2: const themeStylesheet = document.getElementById('theme-stylesheet');
  3: const themeToggle = document.getElementById('themeToggle');
  4: const sunIcon = document.getElementById('sunIcon');
  5: const moonIcon = document.getElementById('moonIcon');
  6: const currentTheme = localStorage.getItem('theme') || 'light';
  7: function setTheme(theme) {
  8:   if (theme === 'dark') {
  9:     themeStylesheet.href = 'dark-theme.css';
 10:     sunIcon.classList.remove('hidden');
 11:     moonIcon.classList.add('hidden');
 12:     themeToggle.setAttribute('aria-label', 'Switch to light theme');
 13:     themeToggle.setAttribute('title', 'Switch to light theme');
 14:     localStorage.setItem('theme', 'dark');
 15:   } else {
 16:     themeStylesheet.href = 'light-theme.css';
 17:     sunIcon.classList.add('hidden');
 18:     moonIcon.classList.remove('hidden');
 19:     themeToggle.setAttribute('aria-label', 'Switch to dark theme');
 20:     themeToggle.setAttribute('title', 'Switch to dark theme');
 21:     localStorage.setItem('theme', 'light');
 22:   }
 23: }
 24: setTheme(currentTheme);
 25: themeToggle.addEventListener('click', () => {
 26:   const newTheme = themeStylesheet.href.includes('dark-theme.css') ? 'light' : 'dark';
 27:   setTheme(newTheme);
 28: });
 29: // Mobile menu toggle
 30: const mobileMenuToggle = document.getElementById('mobileMenuToggle');
 31: const navMenu = document.getElementById('navMenu');
 32: mobileMenuToggle.addEventListener('click', () => {
 33:   navMenu.classList.toggle('active');
 34: });
 35: // Close mobile menu when clicking on a link
 36: const navLinks = document.querySelectorAll('.nav-menu a');
 37: navLinks.forEach((link) => {
 38:   link.addEventListener('click', () => {
 39:     navMenu.classList.remove('active');
 40:   });
 41: });
 42: // Active section highlighting
 43: const sections = document.querySelectorAll('section[id]');
 44: const navLinksArray = Array.from(navLinks);
 45: function highlightActiveSection() {
 46:   const scrollY = window.pageYOffset;
 47:   sections.forEach((section) => {
 48:     const sectionHeight = section.offsetHeight;
 49:     const sectionTop = section.offsetTop - 150;
 50:     const sectionId = section.getAttribute('id');
 51:     if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
 52:       navLinksArray.forEach((link) => {
 53:         link.classList.remove('active');
 54:         if (link.getAttribute('href') === `#${sectionId}`) {
 55:           link.classList.add('active');
 56:         }
 57:       });
 58:     }
 59:   });
 60: }
 61: window.addEventListener('scroll', highlightActiveSection);
 62: window.addEventListener('load', highlightActiveSection);
 63: // Scroll to top button
 64: function initScrollToTop() {
 65:   const scrollToTopButton = document.getElementById('scrollToTopButton');
 66:   if (!scrollToTopButton) {
 67:     return;
 68:   }
 69:   function checkScroll() {
 70:     if (window.pageYOffset > 100 || document.documentElement.scrollTop > 100) {
 71:       scrollToTopButton.classList.add('visible');
 72:     } else {
 73:       scrollToTopButton.classList.remove('visible');
 74:     }
 75:   }
 76:   checkScroll();
 77:   window.addEventListener('scroll', checkScroll);
 78:   scrollToTopButton.addEventListener('click', (e) => {
 79:     e.preventDefault();
 80:     window.scrollTo({
 81:       top: 0,
 82:       behavior: 'smooth',
 83:     });
 84:   });
 85: }
 86: if (document.readyState === 'loading') {
 87:   document.addEventListener('DOMContentLoaded', initScrollToTop);
 88: } else {
 89:   initScrollToTop();
 90: }
 91: // Smooth scroll for anchor links
 92: document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
 93:   anchor.addEventListener('click', function (e) {
 94:     e.preventDefault();
 95:     const target = document.querySelector(this.getAttribute('href'));
 96:     if (target) {
 97:       target.scrollIntoView({
 98:         behavior: 'smooth',
 99:         block: 'start',
100:       });
101:     }
102:   });
103: });
````

## File: docs/robots.txt
````
1: User-agent: *
2: Allow: /
3: 
4: Sitemap: https://github.com/talorlik/dockerized-java-app-on-ec2/raw/main/docs/sitemap.xml
````

## File: docs/sitemap.xml
````xml
1: <?xml version="1.0" encoding="UTF-8"?>
2: <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
3:   <url>
4:     <loc>https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/index.html</loc>
5:     <lastmod>2026-05-06</lastmod>
6:     <changefreq>weekly</changefreq>
7:     <priority>1.0</priority>
8:   </url>
9: </urlset>
````

## File: infra/bootstrap/providers.tf
````hcl
 1: # Default provider targets the DEPLOYMENT account.
 2: # Bootstrap is run with credentials that already point at the deployment account
 3: # (typically by the operator with admin access on first run).
 4: 
 5: provider "aws" {
 6:   region = var.aws_region
 7: 
 8:   default_tags {
 9:     tags = {
10:       Project     = var.project
11:       Environment = "bootstrap"
12:       ManagedBy   = "terraform"
13:       Owner       = var.owner
14:     }
15:   }
16: }
````

## File: infra/bootstrap/variables.tf
````hcl
 1: variable "aws_region" {
 2:   description = "AWS region in which to create the Terraform state bucket."
 3:   type        = string
 4:   default     = "us-east-1"
 5: }
 6: 
 7: variable "project" {
 8:   description = "Short project tag applied to all resources."
 9:   type        = string
10:   default     = "java-app"
11: }
12: 
13: variable "owner" {
14:   description = "Owner tag applied to bootstrap resources."
15:   type        = string
16:   default     = "platform"
17: }
18: 
19: variable "state_bucket_name" {
20:   description = <<EOT
21: Globally-unique S3 bucket name for the Terraform state.
22: Recommended pattern: <project>-tfstate-<deployment_account_id>-<region>.
23: EOT
24:   type        = string
25: }
26: 
27: variable "kms_alias" {
28:   description = "Alias for the KMS key used to encrypt state."
29:   type        = string
30:   default     = "alias/java-app-tfstate"
31: }
32: 
33: variable "enable_access_logging" {
34:   description = "Whether to provision an access-log bucket and enable S3 access logs."
35:   type        = bool
36:   default     = true
37: }
````

## File: infra/bootstrap/versions.tf
````hcl
 1: # Pin tooling versions for the bootstrap module.
 2: # Bootstrap creates the remote state bucket only - it intentionally uses
 3: # local state (no backend block) since it must run before the backend exists.
 4: 
 5: terraform {
 6:   required_version = ">= 1.7.0, < 2.0.0"
 7: 
 8:   required_providers {
 9:     aws = {
10:       source  = "hashicorp/aws"
11:       version = "~> 5.70"
12:     }
13:     random = {
14:       source  = "hashicorp/random"
15:       version = "~> 3.6"
16:     }
17:   }
18: }
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/constants/__init__.py
````python
1: 
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/constants/CLIENT.py
````python
 1: # https://dev.mysql.com/doc/internals/en/capability-flags.html#packet-Protocol::CapabilityFlags
 2: LONG_PASSWORD = 1
 3: FOUND_ROWS = 1 << 1
 4: LONG_FLAG = 1 << 2
 5: CONNECT_WITH_DB = 1 << 3
 6: NO_SCHEMA = 1 << 4
 7: COMPRESS = 1 << 5
 8: ODBC = 1 << 6
 9: LOCAL_FILES = 1 << 7
10: IGNORE_SPACE = 1 << 8
11: PROTOCOL_41 = 1 << 9
12: INTERACTIVE = 1 << 10
13: SSL = 1 << 11
14: IGNORE_SIGPIPE = 1 << 12
15: TRANSACTIONS = 1 << 13
16: SECURE_CONNECTION = 1 << 15
17: MULTI_STATEMENTS = 1 << 16
18: MULTI_RESULTS = 1 << 17
19: PS_MULTI_RESULTS = 1 << 18
20: PLUGIN_AUTH = 1 << 19
21: CONNECT_ATTRS = 1 << 20
22: PLUGIN_AUTH_LENENC_CLIENT_DATA = 1 << 21
23: CAPABILITIES = (
24:     LONG_PASSWORD
25:     | LONG_FLAG
26:     | PROTOCOL_41
27:     | TRANSACTIONS
28:     | SECURE_CONNECTION
29:     | MULTI_RESULTS
30:     | PLUGIN_AUTH
31:     | PLUGIN_AUTH_LENENC_CLIENT_DATA
32:     | CONNECT_ATTRS
33: )
34: # Not done yet
35: HANDLE_EXPIRED_PASSWORDS = 1 << 22
36: SESSION_TRACK = 1 << 23
37: DEPRECATE_EOF = 1 << 24
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/constants/COMMAND.py
````python
 1: COM_SLEEP = 0x00
 2: COM_QUIT = 0x01
 3: COM_INIT_DB = 0x02
 4: COM_QUERY = 0x03
 5: COM_FIELD_LIST = 0x04
 6: COM_CREATE_DB = 0x05
 7: COM_DROP_DB = 0x06
 8: COM_REFRESH = 0x07
 9: COM_SHUTDOWN = 0x08
10: COM_STATISTICS = 0x09
11: COM_PROCESS_INFO = 0x0A
12: COM_CONNECT = 0x0B
13: COM_PROCESS_KILL = 0x0C
14: COM_DEBUG = 0x0D
15: COM_PING = 0x0E
16: COM_TIME = 0x0F
17: COM_DELAYED_INSERT = 0x10
18: COM_CHANGE_USER = 0x11
19: COM_BINLOG_DUMP = 0x12
20: COM_TABLE_DUMP = 0x13
21: COM_CONNECT_OUT = 0x14
22: COM_REGISTER_SLAVE = 0x15
23: COM_STMT_PREPARE = 0x16
24: COM_STMT_EXECUTE = 0x17
25: COM_STMT_SEND_LONG_DATA = 0x18
26: COM_STMT_CLOSE = 0x19
27: COM_STMT_RESET = 0x1A
28: COM_SET_OPTION = 0x1B
29: COM_STMT_FETCH = 0x1C
30: COM_DAEMON = 0x1D
31: COM_BINLOG_DUMP_GTID = 0x1E
32: COM_END = 0x1F
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/constants/CR.py
````python
 1: # flake8: noqa
 2: # errmsg.h
 3: CR_ERROR_FIRST = 2000
 4: CR_UNKNOWN_ERROR = 2000
 5: CR_SOCKET_CREATE_ERROR = 2001
 6: CR_CONNECTION_ERROR = 2002
 7: CR_CONN_HOST_ERROR = 2003
 8: CR_IPSOCK_ERROR = 2004
 9: CR_UNKNOWN_HOST = 2005
10: CR_SERVER_GONE_ERROR = 2006
11: CR_VERSION_ERROR = 2007
12: CR_OUT_OF_MEMORY = 2008
13: CR_WRONG_HOST_INFO = 2009
14: CR_LOCALHOST_CONNECTION = 2010
15: CR_TCP_CONNECTION = 2011
16: CR_SERVER_HANDSHAKE_ERR = 2012
17: CR_SERVER_LOST = 2013
18: CR_COMMANDS_OUT_OF_SYNC = 2014
19: CR_NAMEDPIPE_CONNECTION = 2015
20: CR_NAMEDPIPEWAIT_ERROR = 2016
21: CR_NAMEDPIPEOPEN_ERROR = 2017
22: CR_NAMEDPIPESETSTATE_ERROR = 2018
23: CR_CANT_READ_CHARSET = 2019
24: CR_NET_PACKET_TOO_LARGE = 2020
25: CR_EMBEDDED_CONNECTION = 2021
26: CR_PROBE_SLAVE_STATUS = 2022
27: CR_PROBE_SLAVE_HOSTS = 2023
28: CR_PROBE_SLAVE_CONNECT = 2024
29: CR_PROBE_MASTER_CONNECT = 2025
30: CR_SSL_CONNECTION_ERROR = 2026
31: CR_MALFORMED_PACKET = 2027
32: CR_WRONG_LICENSE = 2028
33: CR_NULL_POINTER = 2029
34: CR_NO_PREPARE_STMT = 2030
35: CR_PARAMS_NOT_BOUND = 2031
36: CR_DATA_TRUNCATED = 2032
37: CR_NO_PARAMETERS_EXISTS = 2033
38: CR_INVALID_PARAMETER_NO = 2034
39: CR_INVALID_BUFFER_USE = 2035
40: CR_UNSUPPORTED_PARAM_TYPE = 2036
41: CR_SHARED_MEMORY_CONNECTION = 2037
42: CR_SHARED_MEMORY_CONNECT_REQUEST_ERROR = 2038
43: CR_SHARED_MEMORY_CONNECT_ANSWER_ERROR = 2039
44: CR_SHARED_MEMORY_CONNECT_FILE_MAP_ERROR = 2040
45: CR_SHARED_MEMORY_CONNECT_MAP_ERROR = 2041
46: CR_SHARED_MEMORY_FILE_MAP_ERROR = 2042
47: CR_SHARED_MEMORY_MAP_ERROR = 2043
48: CR_SHARED_MEMORY_EVENT_ERROR = 2044
49: CR_SHARED_MEMORY_CONNECT_ABANDONED_ERROR = 2045
50: CR_SHARED_MEMORY_CONNECT_SET_ERROR = 2046
51: CR_CONN_UNKNOW_PROTOCOL = 2047
52: CR_INVALID_CONN_HANDLE = 2048
53: CR_SECURE_AUTH = 2049
54: CR_FETCH_CANCELED = 2050
55: CR_NO_DATA = 2051
56: CR_NO_STMT_METADATA = 2052
57: CR_NO_RESULT_SET = 2053
58: CR_NOT_IMPLEMENTED = 2054
59: CR_SERVER_LOST_EXTENDED = 2055
60: CR_STMT_CLOSED = 2056
61: CR_NEW_STMT_METADATA = 2057
62: CR_ALREADY_CONNECTED = 2058
63: CR_AUTH_PLUGIN_CANNOT_LOAD = 2059
64: CR_DUPLICATE_CONNECTION_ATTR = 2060
65: CR_AUTH_PLUGIN_ERR = 2061
66: CR_INSECURE_API_ERR = 2062
67: CR_FILE_NAME_TOO_LONG = 2063
68: CR_SSL_FIPS_MODE_ERR = 2064
69: CR_DEPRECATED_COMPRESSION_NOT_SUPPORTED = 2065
70: CR_COMPRESSION_WRONGLY_CONFIGURED = 2066
71: CR_KERBEROS_USER_NOT_FOUND = 2067
72: CR_LOAD_DATA_LOCAL_INFILE_REJECTED = 2068
73: CR_LOAD_DATA_LOCAL_INFILE_REALPATH_FAIL = 2069
74: CR_DNS_SRV_LOOKUP_FAILED = 2070
75: CR_MANDATORY_TRACKER_NOT_FOUND = 2071
76: CR_INVALID_FACTOR_NO = 2072
77: CR_ERROR_LAST = 2072
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/constants/ER.py
````python
  1: ERROR_FIRST = 1000
  2: HASHCHK = 1000
  3: NISAMCHK = 1001
  4: NO = 1002
  5: YES = 1003
  6: CANT_CREATE_FILE = 1004
  7: CANT_CREATE_TABLE = 1005
  8: CANT_CREATE_DB = 1006
  9: DB_CREATE_EXISTS = 1007
 10: DB_DROP_EXISTS = 1008
 11: DB_DROP_DELETE = 1009
 12: DB_DROP_RMDIR = 1010
 13: CANT_DELETE_FILE = 1011
 14: CANT_FIND_SYSTEM_REC = 1012
 15: CANT_GET_STAT = 1013
 16: CANT_GET_WD = 1014
 17: CANT_LOCK = 1015
 18: CANT_OPEN_FILE = 1016
 19: FILE_NOT_FOUND = 1017
 20: CANT_READ_DIR = 1018
 21: CANT_SET_WD = 1019
 22: CHECKREAD = 1020
 23: DISK_FULL = 1021
 24: DUP_KEY = 1022
 25: ERROR_ON_CLOSE = 1023
 26: ERROR_ON_READ = 1024
 27: ERROR_ON_RENAME = 1025
 28: ERROR_ON_WRITE = 1026
 29: FILE_USED = 1027
 30: FILSORT_ABORT = 1028
 31: FORM_NOT_FOUND = 1029
 32: GET_ERRNO = 1030
 33: ILLEGAL_HA = 1031
 34: KEY_NOT_FOUND = 1032
 35: NOT_FORM_FILE = 1033
 36: NOT_KEYFILE = 1034
 37: OLD_KEYFILE = 1035
 38: OPEN_AS_READONLY = 1036
 39: OUTOFMEMORY = 1037
 40: OUT_OF_SORTMEMORY = 1038
 41: UNEXPECTED_EOF = 1039
 42: CON_COUNT_ERROR = 1040
 43: OUT_OF_RESOURCES = 1041
 44: BAD_HOST_ERROR = 1042
 45: HANDSHAKE_ERROR = 1043
 46: DBACCESS_DENIED_ERROR = 1044
 47: ACCESS_DENIED_ERROR = 1045
 48: NO_DB_ERROR = 1046
 49: UNKNOWN_COM_ERROR = 1047
 50: BAD_NULL_ERROR = 1048
 51: BAD_DB_ERROR = 1049
 52: TABLE_EXISTS_ERROR = 1050
 53: BAD_TABLE_ERROR = 1051
 54: NON_UNIQ_ERROR = 1052
 55: SERVER_SHUTDOWN = 1053
 56: BAD_FIELD_ERROR = 1054
 57: WRONG_FIELD_WITH_GROUP = 1055
 58: WRONG_GROUP_FIELD = 1056
 59: WRONG_SUM_SELECT = 1057
 60: WRONG_VALUE_COUNT = 1058
 61: TOO_LONG_IDENT = 1059
 62: DUP_FIELDNAME = 1060
 63: DUP_KEYNAME = 1061
 64: DUP_ENTRY = 1062
 65: WRONG_FIELD_SPEC = 1063
 66: PARSE_ERROR = 1064
 67: EMPTY_QUERY = 1065
 68: NONUNIQ_TABLE = 1066
 69: INVALID_DEFAULT = 1067
 70: MULTIPLE_PRI_KEY = 1068
 71: TOO_MANY_KEYS = 1069
 72: TOO_MANY_KEY_PARTS = 1070
 73: TOO_LONG_KEY = 1071
 74: KEY_COLUMN_DOES_NOT_EXITS = 1072
 75: BLOB_USED_AS_KEY = 1073
 76: TOO_BIG_FIELDLENGTH = 1074
 77: WRONG_AUTO_KEY = 1075
 78: READY = 1076
 79: NORMAL_SHUTDOWN = 1077
 80: GOT_SIGNAL = 1078
 81: SHUTDOWN_COMPLETE = 1079
 82: FORCING_CLOSE = 1080
 83: IPSOCK_ERROR = 1081
 84: NO_SUCH_INDEX = 1082
 85: WRONG_FIELD_TERMINATORS = 1083
 86: BLOBS_AND_NO_TERMINATED = 1084
 87: TEXTFILE_NOT_READABLE = 1085
 88: FILE_EXISTS_ERROR = 1086
 89: LOAD_INFO = 1087
 90: ALTER_INFO = 1088
 91: WRONG_SUB_KEY = 1089
 92: CANT_REMOVE_ALL_FIELDS = 1090
 93: CANT_DROP_FIELD_OR_KEY = 1091
 94: INSERT_INFO = 1092
 95: UPDATE_TABLE_USED = 1093
 96: NO_SUCH_THREAD = 1094
 97: KILL_DENIED_ERROR = 1095
 98: NO_TABLES_USED = 1096
 99: TOO_BIG_SET = 1097
100: NO_UNIQUE_LOGFILE = 1098
101: TABLE_NOT_LOCKED_FOR_WRITE = 1099
102: TABLE_NOT_LOCKED = 1100
103: BLOB_CANT_HAVE_DEFAULT = 1101
104: WRONG_DB_NAME = 1102
105: WRONG_TABLE_NAME = 1103
106: TOO_BIG_SELECT = 1104
107: UNKNOWN_ERROR = 1105
108: UNKNOWN_PROCEDURE = 1106
109: WRONG_PARAMCOUNT_TO_PROCEDURE = 1107
110: WRONG_PARAMETERS_TO_PROCEDURE = 1108
111: UNKNOWN_TABLE = 1109
112: FIELD_SPECIFIED_TWICE = 1110
113: INVALID_GROUP_FUNC_USE = 1111
114: UNSUPPORTED_EXTENSION = 1112
115: TABLE_MUST_HAVE_COLUMNS = 1113
116: RECORD_FILE_FULL = 1114
117: UNKNOWN_CHARACTER_SET = 1115
118: TOO_MANY_TABLES = 1116
119: TOO_MANY_FIELDS = 1117
120: TOO_BIG_ROWSIZE = 1118
121: STACK_OVERRUN = 1119
122: WRONG_OUTER_JOIN = 1120
123: NULL_COLUMN_IN_INDEX = 1121
124: CANT_FIND_UDF = 1122
125: CANT_INITIALIZE_UDF = 1123
126: UDF_NO_PATHS = 1124
127: UDF_EXISTS = 1125
128: CANT_OPEN_LIBRARY = 1126
129: CANT_FIND_DL_ENTRY = 1127
130: FUNCTION_NOT_DEFINED = 1128
131: HOST_IS_BLOCKED = 1129
132: HOST_NOT_PRIVILEGED = 1130
133: PASSWORD_ANONYMOUS_USER = 1131
134: PASSWORD_NOT_ALLOWED = 1132
135: PASSWORD_NO_MATCH = 1133
136: UPDATE_INFO = 1134
137: CANT_CREATE_THREAD = 1135
138: WRONG_VALUE_COUNT_ON_ROW = 1136
139: CANT_REOPEN_TABLE = 1137
140: INVALID_USE_OF_NULL = 1138
141: REGEXP_ERROR = 1139
142: MIX_OF_GROUP_FUNC_AND_FIELDS = 1140
143: NONEXISTING_GRANT = 1141
144: TABLEACCESS_DENIED_ERROR = 1142
145: COLUMNACCESS_DENIED_ERROR = 1143
146: ILLEGAL_GRANT_FOR_TABLE = 1144
147: GRANT_WRONG_HOST_OR_USER = 1145
148: NO_SUCH_TABLE = 1146
149: NONEXISTING_TABLE_GRANT = 1147
150: NOT_ALLOWED_COMMAND = 1148
151: SYNTAX_ERROR = 1149
152: DELAYED_CANT_CHANGE_LOCK = 1150
153: TOO_MANY_DELAYED_THREADS = 1151
154: ABORTING_CONNECTION = 1152
155: NET_PACKET_TOO_LARGE = 1153
156: NET_READ_ERROR_FROM_PIPE = 1154
157: NET_FCNTL_ERROR = 1155
158: NET_PACKETS_OUT_OF_ORDER = 1156
159: NET_UNCOMPRESS_ERROR = 1157
160: NET_READ_ERROR = 1158
161: NET_READ_INTERRUPTED = 1159
162: NET_ERROR_ON_WRITE = 1160
163: NET_WRITE_INTERRUPTED = 1161
164: TOO_LONG_STRING = 1162
165: TABLE_CANT_HANDLE_BLOB = 1163
166: TABLE_CANT_HANDLE_AUTO_INCREMENT = 1164
167: DELAYED_INSERT_TABLE_LOCKED = 1165
168: WRONG_COLUMN_NAME = 1166
169: WRONG_KEY_COLUMN = 1167
170: WRONG_MRG_TABLE = 1168
171: DUP_UNIQUE = 1169
172: BLOB_KEY_WITHOUT_LENGTH = 1170
173: PRIMARY_CANT_HAVE_NULL = 1171
174: TOO_MANY_ROWS = 1172
175: REQUIRES_PRIMARY_KEY = 1173
176: NO_RAID_COMPILED = 1174
177: UPDATE_WITHOUT_KEY_IN_SAFE_MODE = 1175
178: KEY_DOES_NOT_EXITS = 1176
179: CHECK_NO_SUCH_TABLE = 1177
180: CHECK_NOT_IMPLEMENTED = 1178
181: CANT_DO_THIS_DURING_AN_TRANSACTION = 1179
182: ERROR_DURING_COMMIT = 1180
183: ERROR_DURING_ROLLBACK = 1181
184: ERROR_DURING_FLUSH_LOGS = 1182
185: ERROR_DURING_CHECKPOINT = 1183
186: NEW_ABORTING_CONNECTION = 1184
187: DUMP_NOT_IMPLEMENTED = 1185
188: FLUSH_MASTER_BINLOG_CLOSED = 1186
189: INDEX_REBUILD = 1187
190: MASTER = 1188
191: MASTER_NET_READ = 1189
192: MASTER_NET_WRITE = 1190
193: FT_MATCHING_KEY_NOT_FOUND = 1191
194: LOCK_OR_ACTIVE_TRANSACTION = 1192
195: UNKNOWN_SYSTEM_VARIABLE = 1193
196: CRASHED_ON_USAGE = 1194
197: CRASHED_ON_REPAIR = 1195
198: WARNING_NOT_COMPLETE_ROLLBACK = 1196
199: TRANS_CACHE_FULL = 1197
200: SLAVE_MUST_STOP = 1198
201: SLAVE_NOT_RUNNING = 1199
202: BAD_SLAVE = 1200
203: MASTER_INFO = 1201
204: SLAVE_THREAD = 1202
205: TOO_MANY_USER_CONNECTIONS = 1203
206: SET_CONSTANTS_ONLY = 1204
207: LOCK_WAIT_TIMEOUT = 1205
208: LOCK_TABLE_FULL = 1206
209: READ_ONLY_TRANSACTION = 1207
210: DROP_DB_WITH_READ_LOCK = 1208
211: CREATE_DB_WITH_READ_LOCK = 1209
212: WRONG_ARGUMENTS = 1210
213: NO_PERMISSION_TO_CREATE_USER = 1211
214: UNION_TABLES_IN_DIFFERENT_DIR = 1212
215: LOCK_DEADLOCK = 1213
216: TABLE_CANT_HANDLE_FT = 1214
217: CANNOT_ADD_FOREIGN = 1215
218: NO_REFERENCED_ROW = 1216
219: ROW_IS_REFERENCED = 1217
220: CONNECT_TO_MASTER = 1218
221: QUERY_ON_MASTER = 1219
222: ERROR_WHEN_EXECUTING_COMMAND = 1220
223: WRONG_USAGE = 1221
224: WRONG_NUMBER_OF_COLUMNS_IN_SELECT = 1222
225: CANT_UPDATE_WITH_READLOCK = 1223
226: MIXING_NOT_ALLOWED = 1224
227: DUP_ARGUMENT = 1225
228: USER_LIMIT_REACHED = 1226
229: SPECIFIC_ACCESS_DENIED_ERROR = 1227
230: LOCAL_VARIABLE = 1228
231: GLOBAL_VARIABLE = 1229
232: NO_DEFAULT = 1230
233: WRONG_VALUE_FOR_VAR = 1231
234: WRONG_TYPE_FOR_VAR = 1232
235: VAR_CANT_BE_READ = 1233
236: CANT_USE_OPTION_HERE = 1234
237: NOT_SUPPORTED_YET = 1235
238: MASTER_FATAL_ERROR_READING_BINLOG = 1236
239: SLAVE_IGNORED_TABLE = 1237
240: INCORRECT_GLOBAL_LOCAL_VAR = 1238
241: WRONG_FK_DEF = 1239
242: KEY_REF_DO_NOT_MATCH_TABLE_REF = 1240
243: OPERAND_COLUMNS = 1241
244: SUBQUERY_NO_1_ROW = 1242
245: UNKNOWN_STMT_HANDLER = 1243
246: CORRUPT_HELP_DB = 1244
247: CYCLIC_REFERENCE = 1245
248: AUTO_CONVERT = 1246
249: ILLEGAL_REFERENCE = 1247
250: DERIVED_MUST_HAVE_ALIAS = 1248
251: SELECT_REDUCED = 1249
252: TABLENAME_NOT_ALLOWED_HERE = 1250
253: NOT_SUPPORTED_AUTH_MODE = 1251
254: SPATIAL_CANT_HAVE_NULL = 1252
255: COLLATION_CHARSET_MISMATCH = 1253
256: SLAVE_WAS_RUNNING = 1254
257: SLAVE_WAS_NOT_RUNNING = 1255
258: TOO_BIG_FOR_UNCOMPRESS = 1256
259: ZLIB_Z_MEM_ERROR = 1257
260: ZLIB_Z_BUF_ERROR = 1258
261: ZLIB_Z_DATA_ERROR = 1259
262: CUT_VALUE_GROUP_CONCAT = 1260
263: WARN_TOO_FEW_RECORDS = 1261
264: WARN_TOO_MANY_RECORDS = 1262
265: WARN_NULL_TO_NOTNULL = 1263
266: WARN_DATA_OUT_OF_RANGE = 1264
267: WARN_DATA_TRUNCATED = 1265
268: WARN_USING_OTHER_HANDLER = 1266
269: CANT_AGGREGATE_2COLLATIONS = 1267
270: DROP_USER = 1268
271: REVOKE_GRANTS = 1269
272: CANT_AGGREGATE_3COLLATIONS = 1270
273: CANT_AGGREGATE_NCOLLATIONS = 1271
274: VARIABLE_IS_NOT_STRUCT = 1272
275: UNKNOWN_COLLATION = 1273
276: SLAVE_IGNORED_SSL_PARAMS = 1274
277: SERVER_IS_IN_SECURE_AUTH_MODE = 1275
278: WARN_FIELD_RESOLVED = 1276
279: BAD_SLAVE_UNTIL_COND = 1277
280: MISSING_SKIP_SLAVE = 1278
281: UNTIL_COND_IGNORED = 1279
282: WRONG_NAME_FOR_INDEX = 1280
283: WRONG_NAME_FOR_CATALOG = 1281
284: WARN_QC_RESIZE = 1282
285: BAD_FT_COLUMN = 1283
286: UNKNOWN_KEY_CACHE = 1284
287: WARN_HOSTNAME_WONT_WORK = 1285
288: UNKNOWN_STORAGE_ENGINE = 1286
289: WARN_DEPRECATED_SYNTAX = 1287
290: NON_UPDATABLE_TABLE = 1288
291: FEATURE_DISABLED = 1289
292: OPTION_PREVENTS_STATEMENT = 1290
293: DUPLICATED_VALUE_IN_TYPE = 1291
294: TRUNCATED_WRONG_VALUE = 1292
295: TOO_MUCH_AUTO_TIMESTAMP_COLS = 1293
296: INVALID_ON_UPDATE = 1294
297: UNSUPPORTED_PS = 1295
298: GET_ERRMSG = 1296
299: GET_TEMPORARY_ERRMSG = 1297
300: UNKNOWN_TIME_ZONE = 1298
301: WARN_INVALID_TIMESTAMP = 1299
302: INVALID_CHARACTER_STRING = 1300
303: WARN_ALLOWED_PACKET_OVERFLOWED = 1301
304: CONFLICTING_DECLARATIONS = 1302
305: SP_NO_RECURSIVE_CREATE = 1303
306: SP_ALREADY_EXISTS = 1304
307: SP_DOES_NOT_EXIST = 1305
308: SP_DROP_FAILED = 1306
309: SP_STORE_FAILED = 1307
310: SP_LILABEL_MISMATCH = 1308
311: SP_LABEL_REDEFINE = 1309
312: SP_LABEL_MISMATCH = 1310
313: SP_UNINIT_VAR = 1311
314: SP_BADSELECT = 1312
315: SP_BADRETURN = 1313
316: SP_BADSTATEMENT = 1314
317: UPDATE_LOG_DEPRECATED_IGNORED = 1315
318: UPDATE_LOG_DEPRECATED_TRANSLATED = 1316
319: QUERY_INTERRUPTED = 1317
320: SP_WRONG_NO_OF_ARGS = 1318
321: SP_COND_MISMATCH = 1319
322: SP_NORETURN = 1320
323: SP_NORETURNEND = 1321
324: SP_BAD_CURSOR_QUERY = 1322
325: SP_BAD_CURSOR_SELECT = 1323
326: SP_CURSOR_MISMATCH = 1324
327: SP_CURSOR_ALREADY_OPEN = 1325
328: SP_CURSOR_NOT_OPEN = 1326
329: SP_UNDECLARED_VAR = 1327
330: SP_WRONG_NO_OF_FETCH_ARGS = 1328
331: SP_FETCH_NO_DATA = 1329
332: SP_DUP_PARAM = 1330
333: SP_DUP_VAR = 1331
334: SP_DUP_COND = 1332
335: SP_DUP_CURS = 1333
336: SP_CANT_ALTER = 1334
337: SP_SUBSELECT_NYI = 1335
338: STMT_NOT_ALLOWED_IN_SF_OR_TRG = 1336
339: SP_VARCOND_AFTER_CURSHNDLR = 1337
340: SP_CURSOR_AFTER_HANDLER = 1338
341: SP_CASE_NOT_FOUND = 1339
342: FPARSER_TOO_BIG_FILE = 1340
343: FPARSER_BAD_HEADER = 1341
344: FPARSER_EOF_IN_COMMENT = 1342
345: FPARSER_ERROR_IN_PARAMETER = 1343
346: FPARSER_EOF_IN_UNKNOWN_PARAMETER = 1344
347: VIEW_NO_EXPLAIN = 1345
348: FRM_UNKNOWN_TYPE = 1346
349: WRONG_OBJECT = 1347
350: NONUPDATEABLE_COLUMN = 1348
351: VIEW_SELECT_DERIVED = 1349
352: VIEW_SELECT_CLAUSE = 1350
353: VIEW_SELECT_VARIABLE = 1351
354: VIEW_SELECT_TMPTABLE = 1352
355: VIEW_WRONG_LIST = 1353
356: WARN_VIEW_MERGE = 1354
357: WARN_VIEW_WITHOUT_KEY = 1355
358: VIEW_INVALID = 1356
359: SP_NO_DROP_SP = 1357
360: SP_GOTO_IN_HNDLR = 1358
361: TRG_ALREADY_EXISTS = 1359
362: TRG_DOES_NOT_EXIST = 1360
363: TRG_ON_VIEW_OR_TEMP_TABLE = 1361
364: TRG_CANT_CHANGE_ROW = 1362
365: TRG_NO_SUCH_ROW_IN_TRG = 1363
366: NO_DEFAULT_FOR_FIELD = 1364
367: DIVISION_BY_ZERO = 1365
368: TRUNCATED_WRONG_VALUE_FOR_FIELD = 1366
369: ILLEGAL_VALUE_FOR_TYPE = 1367
370: VIEW_NONUPD_CHECK = 1368
371: VIEW_CHECK_FAILED = 1369
372: PROCACCESS_DENIED_ERROR = 1370
373: RELAY_LOG_FAIL = 1371
374: PASSWD_LENGTH = 1372
375: UNKNOWN_TARGET_BINLOG = 1373
376: IO_ERR_LOG_INDEX_READ = 1374
377: BINLOG_PURGE_PROHIBITED = 1375
378: FSEEK_FAIL = 1376
379: BINLOG_PURGE_FATAL_ERR = 1377
380: LOG_IN_USE = 1378
381: LOG_PURGE_UNKNOWN_ERR = 1379
382: RELAY_LOG_INIT = 1380
383: NO_BINARY_LOGGING = 1381
384: RESERVED_SYNTAX = 1382
385: WSAS_FAILED = 1383
386: DIFF_GROUPS_PROC = 1384
387: NO_GROUP_FOR_PROC = 1385
388: ORDER_WITH_PROC = 1386
389: LOGGING_PROHIBIT_CHANGING_OF = 1387
390: NO_FILE_MAPPING = 1388
391: WRONG_MAGIC = 1389
392: PS_MANY_PARAM = 1390
393: KEY_PART_0 = 1391
394: VIEW_CHECKSUM = 1392
395: VIEW_MULTIUPDATE = 1393
396: VIEW_NO_INSERT_FIELD_LIST = 1394
397: VIEW_DELETE_MERGE_VIEW = 1395
398: CANNOT_USER = 1396
399: XAER_NOTA = 1397
400: XAER_INVAL = 1398
401: XAER_RMFAIL = 1399
402: XAER_OUTSIDE = 1400
403: XAER_RMERR = 1401
404: XA_RBROLLBACK = 1402
405: NONEXISTING_PROC_GRANT = 1403
406: PROC_AUTO_GRANT_FAIL = 1404
407: PROC_AUTO_REVOKE_FAIL = 1405
408: DATA_TOO_LONG = 1406
409: SP_BAD_SQLSTATE = 1407
410: STARTUP = 1408
411: LOAD_FROM_FIXED_SIZE_ROWS_TO_VAR = 1409
412: CANT_CREATE_USER_WITH_GRANT = 1410
413: WRONG_VALUE_FOR_TYPE = 1411
414: TABLE_DEF_CHANGED = 1412
415: SP_DUP_HANDLER = 1413
416: SP_NOT_VAR_ARG = 1414
417: SP_NO_RETSET = 1415
418: CANT_CREATE_GEOMETRY_OBJECT = 1416
419: FAILED_ROUTINE_BREAK_BINLOG = 1417
420: BINLOG_UNSAFE_ROUTINE = 1418
421: BINLOG_CREATE_ROUTINE_NEED_SUPER = 1419
422: EXEC_STMT_WITH_OPEN_CURSOR = 1420
423: STMT_HAS_NO_OPEN_CURSOR = 1421
424: COMMIT_NOT_ALLOWED_IN_SF_OR_TRG = 1422
425: NO_DEFAULT_FOR_VIEW_FIELD = 1423
426: SP_NO_RECURSION = 1424
427: TOO_BIG_SCALE = 1425
428: TOO_BIG_PRECISION = 1426
429: M_BIGGER_THAN_D = 1427
430: WRONG_LOCK_OF_SYSTEM_TABLE = 1428
431: CONNECT_TO_FOREIGN_DATA_SOURCE = 1429
432: QUERY_ON_FOREIGN_DATA_SOURCE = 1430
433: FOREIGN_DATA_SOURCE_DOESNT_EXIST = 1431
434: FOREIGN_DATA_STRING_INVALID_CANT_CREATE = 1432
435: FOREIGN_DATA_STRING_INVALID = 1433
436: CANT_CREATE_FEDERATED_TABLE = 1434
437: TRG_IN_WRONG_SCHEMA = 1435
438: STACK_OVERRUN_NEED_MORE = 1436
439: TOO_LONG_BODY = 1437
440: WARN_CANT_DROP_DEFAULT_KEYCACHE = 1438
441: TOO_BIG_DISPLAYWIDTH = 1439
442: XAER_DUPID = 1440
443: DATETIME_FUNCTION_OVERFLOW = 1441
444: CANT_UPDATE_USED_TABLE_IN_SF_OR_TRG = 1442
445: VIEW_PREVENT_UPDATE = 1443
446: PS_NO_RECURSION = 1444
447: SP_CANT_SET_AUTOCOMMIT = 1445
448: MALFORMED_DEFINER = 1446
449: VIEW_FRM_NO_USER = 1447
450: VIEW_OTHER_USER = 1448
451: NO_SUCH_USER = 1449
452: FORBID_SCHEMA_CHANGE = 1450
453: ROW_IS_REFERENCED_2 = 1451
454: NO_REFERENCED_ROW_2 = 1452
455: SP_BAD_VAR_SHADOW = 1453
456: TRG_NO_DEFINER = 1454
457: OLD_FILE_FORMAT = 1455
458: SP_RECURSION_LIMIT = 1456
459: SP_PROC_TABLE_CORRUPT = 1457
460: SP_WRONG_NAME = 1458
461: TABLE_NEEDS_UPGRADE = 1459
462: SP_NO_AGGREGATE = 1460
463: MAX_PREPARED_STMT_COUNT_REACHED = 1461
464: VIEW_RECURSIVE = 1462
465: NON_GROUPING_FIELD_USED = 1463
466: TABLE_CANT_HANDLE_SPKEYS = 1464
467: NO_TRIGGERS_ON_SYSTEM_SCHEMA = 1465
468: USERNAME = 1466
469: HOSTNAME = 1467
470: WRONG_STRING_LENGTH = 1468
471: ERROR_LAST = 1468
472: # MariaDB only
473: STATEMENT_TIMEOUT = 1969
474: QUERY_TIMEOUT = 3024
475: # https://github.com/PyMySQL/PyMySQL/issues/607
476: CONSTRAINT_FAILED = 4025
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/constants/FIELD_TYPE.py
````python
 1: DECIMAL = 0
 2: TINY = 1
 3: SHORT = 2
 4: LONG = 3
 5: FLOAT = 4
 6: DOUBLE = 5
 7: NULL = 6
 8: TIMESTAMP = 7
 9: LONGLONG = 8
10: INT24 = 9
11: DATE = 10
12: TIME = 11
13: DATETIME = 12
14: YEAR = 13
15: NEWDATE = 14
16: VARCHAR = 15
17: BIT = 16
18: JSON = 245
19: NEWDECIMAL = 246
20: ENUM = 247
21: SET = 248
22: TINY_BLOB = 249
23: MEDIUM_BLOB = 250
24: LONG_BLOB = 251
25: BLOB = 252
26: VAR_STRING = 253
27: STRING = 254
28: GEOMETRY = 255
29: CHAR = TINY
30: INTERVAL = ENUM
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/constants/FLAG.py
````python
 1: NOT_NULL = 1
 2: PRI_KEY = 2
 3: UNIQUE_KEY = 4
 4: MULTIPLE_KEY = 8
 5: BLOB = 16
 6: UNSIGNED = 32
 7: ZEROFILL = 64
 8: BINARY = 128
 9: ENUM = 256
10: AUTO_INCREMENT = 512
11: TIMESTAMP = 1024
12: SET = 2048
13: PART_KEY = 16384
14: GROUP = 32767
15: UNIQUE = 65536
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/constants/SERVER_STATUS.py
````python
 1: SERVER_STATUS_IN_TRANS = 1
 2: SERVER_STATUS_AUTOCOMMIT = 2
 3: SERVER_MORE_RESULTS_EXISTS = 8
 4: SERVER_QUERY_NO_GOOD_INDEX_USED = 16
 5: SERVER_QUERY_NO_INDEX_USED = 32
 6: SERVER_STATUS_CURSOR_EXISTS = 64
 7: SERVER_STATUS_LAST_ROW_SENT = 128
 8: SERVER_STATUS_DB_DROPPED = 256
 9: SERVER_STATUS_NO_BACKSLASH_ESCAPES = 512
10: SERVER_STATUS_METADATA_CHANGED = 1024
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/__init__.py
````python
  1: """
  2: PyMySQL: A pure-Python MySQL client library.
  3: Copyright (c) 2010-2016 PyMySQL contributors
  4: Permission is hereby granted, free of charge, to any person obtaining a copy
  5: of this software and associated documentation files (the "Software"), to deal
  6: in the Software without restriction, including without limitation the rights
  7: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  8: copies of the Software, and to permit persons to whom the Software is
  9: furnished to do so, subject to the following conditions:
 10: The above copyright notice and this permission notice shall be included in
 11: all copies or substantial portions of the Software.
 12: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 13: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 14: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 15: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 16: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 17: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 18: THE SOFTWARE.
 19: """
 20: import sys
 21: from .constants import FIELD_TYPE
 22: from .err import (
 23:     Warning,
 24:     Error,
 25:     InterfaceError,
 26:     DataError,
 27:     DatabaseError,
 28:     OperationalError,
 29:     IntegrityError,
 30:     InternalError,
 31:     NotSupportedError,
 32:     ProgrammingError,
 33:     MySQLError,
 34: )
 35: from .times import (
 36:     Date,
 37:     Time,
 38:     Timestamp,
 39:     DateFromTicks,
 40:     TimeFromTicks,
 41:     TimestampFromTicks,
 42: )
 43: # PyMySQL version.
 44: # Used by setuptools and connection_attrs
 45: VERSION = (1, 1, 1, "final", 1)
 46: VERSION_STRING = "1.1.1"
 47: ### for mysqlclient compatibility
 48: ### Django checks mysqlclient version.
 49: version_info = (1, 4, 6, "final", 1)
 50: __version__ = "1.4.6"
 51: def get_client_info():  # for MySQLdb compatibility
 52:     return __version__
 53: def install_as_MySQLdb():
 54:     """
 55:     After this function is called, any application that imports MySQLdb
 56:     will unwittingly actually use pymysql.
 57:     """
 58:     sys.modules["MySQLdb"] = sys.modules["pymysql"]
 59: # end of mysqlclient compatibility code
 60: threadsafety = 1
 61: apilevel = "2.0"
 62: paramstyle = "pyformat"
 63: from . import connections  # noqa: E402
 64: class DBAPISet(frozenset):
 65:     def __ne__(self, other):
 66:         if isinstance(other, set):
 67:             return frozenset.__ne__(self, other)
 68:         else:
 69:             return other not in self
 70:     def __eq__(self, other):
 71:         if isinstance(other, frozenset):
 72:             return frozenset.__eq__(self, other)
 73:         else:
 74:             return other in self
 75:     def __hash__(self):
 76:         return frozenset.__hash__(self)
 77: STRING = DBAPISet([FIELD_TYPE.ENUM, FIELD_TYPE.STRING, FIELD_TYPE.VAR_STRING])
 78: BINARY = DBAPISet(
 79:     [
 80:         FIELD_TYPE.BLOB,
 81:         FIELD_TYPE.LONG_BLOB,
 82:         FIELD_TYPE.MEDIUM_BLOB,
 83:         FIELD_TYPE.TINY_BLOB,
 84:     ]
 85: )
 86: NUMBER = DBAPISet(
 87:     [
 88:         FIELD_TYPE.DECIMAL,
 89:         FIELD_TYPE.DOUBLE,
 90:         FIELD_TYPE.FLOAT,
 91:         FIELD_TYPE.INT24,
 92:         FIELD_TYPE.LONG,
 93:         FIELD_TYPE.LONGLONG,
 94:         FIELD_TYPE.TINY,
 95:         FIELD_TYPE.YEAR,
 96:     ]
 97: )
 98: DATE = DBAPISet([FIELD_TYPE.DATE, FIELD_TYPE.NEWDATE])
 99: TIME = DBAPISet([FIELD_TYPE.TIME])
100: TIMESTAMP = DBAPISet([FIELD_TYPE.TIMESTAMP, FIELD_TYPE.DATETIME])
101: DATETIME = TIMESTAMP
102: ROWID = DBAPISet()
103: def Binary(x):
104:     """Return x as a binary type."""
105:     return bytes(x)
106: def thread_safe():
107:     return True  # match MySQLdb.thread_safe()
108: Connect = connect = Connection = connections.Connection
109: NULL = "NULL"
110: __all__ = [
111:     "BINARY",
112:     "Binary",
113:     "Connect",
114:     "Connection",
115:     "DATE",
116:     "Date",
117:     "Time",
118:     "Timestamp",
119:     "DateFromTicks",
120:     "TimeFromTicks",
121:     "TimestampFromTicks",
122:     "DataError",
123:     "DatabaseError",
124:     "Error",
125:     "FIELD_TYPE",
126:     "IntegrityError",
127:     "InterfaceError",
128:     "InternalError",
129:     "MySQLError",
130:     "NULL",
131:     "NUMBER",
132:     "NotSupportedError",
133:     "DBAPISet",
134:     "OperationalError",
135:     "ProgrammingError",
136:     "ROWID",
137:     "STRING",
138:     "TIME",
139:     "TIMESTAMP",
140:     "Warning",
141:     "apilevel",
142:     "connect",
143:     "connections",
144:     "constants",
145:     "converters",
146:     "cursors",
147:     "get_client_info",
148:     "paramstyle",
149:     "threadsafety",
150:     "version_info",
151:     "install_as_MySQLdb",
152:     "__version__",
153: ]
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/_auth.py
````python
  1: """
  2: Implements auth methods
  3: """
  4: from .err import OperationalError
  5: try:
  6:     from cryptography.hazmat.backends import default_backend
  7:     from cryptography.hazmat.primitives import serialization, hashes
  8:     from cryptography.hazmat.primitives.asymmetric import padding
  9:     _have_cryptography = True
 10: except ImportError:
 11:     _have_cryptography = False
 12: from functools import partial
 13: import hashlib
 14: DEBUG = False
 15: SCRAMBLE_LENGTH = 20
 16: sha1_new = partial(hashlib.new, "sha1")
 17: # mysql_native_password
 18: # https://dev.mysql.com/doc/internals/en/secure-password-authentication.html#packet-Authentication::Native41
 19: def scramble_native_password(password, message):
 20:     """Scramble used for mysql_native_password"""
 21:     if not password:
 22:         return b""
 23:     stage1 = sha1_new(password).digest()
 24:     stage2 = sha1_new(stage1).digest()
 25:     s = sha1_new()
 26:     s.update(message[:SCRAMBLE_LENGTH])
 27:     s.update(stage2)
 28:     result = s.digest()
 29:     return _my_crypt(result, stage1)
 30: def _my_crypt(message1, message2):
 31:     result = bytearray(message1)
 32:     for i in range(len(result)):
 33:         result[i] ^= message2[i]
 34:     return bytes(result)
 35: # MariaDB's client_ed25519-plugin
 36: # https://mariadb.com/kb/en/library/connection/#client_ed25519-plugin
 37: _nacl_bindings = False
 38: def _init_nacl():
 39:     global _nacl_bindings
 40:     try:
 41:         from nacl import bindings
 42:         _nacl_bindings = bindings
 43:     except ImportError:
 44:         raise RuntimeError(
 45:             "'pynacl' package is required for ed25519_password auth method"
 46:         )
 47: def _scalar_clamp(s32):
 48:     ba = bytearray(s32)
 49:     ba0 = bytes(bytearray([ba[0] & 248]))
 50:     ba31 = bytes(bytearray([(ba[31] & 127) | 64]))
 51:     return ba0 + bytes(s32[1:31]) + ba31
 52: def ed25519_password(password, scramble):
 53:     """Sign a random scramble with elliptic curve Ed25519.
 54:     Secret and public key are derived from password.
 55:     """
 56:     # variable names based on rfc8032 section-5.1.6
 57:     #
 58:     if not _nacl_bindings:
 59:         _init_nacl()
 60:     # h = SHA512(password)
 61:     h = hashlib.sha512(password).digest()
 62:     # s = prune(first_half(h))
 63:     s = _scalar_clamp(h[:32])
 64:     # r = SHA512(second_half(h) || M)
 65:     r = hashlib.sha512(h[32:] + scramble).digest()
 66:     # R = encoded point [r]B
 67:     r = _nacl_bindings.crypto_core_ed25519_scalar_reduce(r)
 68:     R = _nacl_bindings.crypto_scalarmult_ed25519_base_noclamp(r)
 69:     # A = encoded point [s]B
 70:     A = _nacl_bindings.crypto_scalarmult_ed25519_base_noclamp(s)
 71:     # k = SHA512(R || A || M)
 72:     k = hashlib.sha512(R + A + scramble).digest()
 73:     # S = (k * s + r) mod L
 74:     k = _nacl_bindings.crypto_core_ed25519_scalar_reduce(k)
 75:     ks = _nacl_bindings.crypto_core_ed25519_scalar_mul(k, s)
 76:     S = _nacl_bindings.crypto_core_ed25519_scalar_add(ks, r)
 77:     # signature = R || S
 78:     return R + S
 79: # sha256_password
 80: def _roundtrip(conn, send_data):
 81:     conn.write_packet(send_data)
 82:     pkt = conn._read_packet()
 83:     pkt.check_error()
 84:     return pkt
 85: def _xor_password(password, salt):
 86:     # Trailing NUL character will be added in Auth Switch Request.
 87:     # See https://github.com/mysql/mysql-server/blob/7d10c82196c8e45554f27c00681474a9fb86d137/sql/auth/sha2_password.cc#L939-L945
 88:     salt = salt[:SCRAMBLE_LENGTH]
 89:     password_bytes = bytearray(password)
 90:     # salt = bytearray(salt)  # for PY2 compat.
 91:     salt_len = len(salt)
 92:     for i in range(len(password_bytes)):
 93:         password_bytes[i] ^= salt[i % salt_len]
 94:     return bytes(password_bytes)
 95: def sha2_rsa_encrypt(password, salt, public_key):
 96:     """Encrypt password with salt and public_key.
 97:     Used for sha256_password and caching_sha2_password.
 98:     """
 99:     if not _have_cryptography:
100:         raise RuntimeError(
101:             "'cryptography' package is required for sha256_password or"
102:             + " caching_sha2_password auth methods"
103:         )
104:     message = _xor_password(password + b"\0", salt)
105:     rsa_key = serialization.load_pem_public_key(public_key, default_backend())
106:     return rsa_key.encrypt(
107:         message,
108:         padding.OAEP(
109:             mgf=padding.MGF1(algorithm=hashes.SHA1()),
110:             algorithm=hashes.SHA1(),
111:             label=None,
112:         ),
113:     )
114: def sha256_password_auth(conn, pkt):
115:     if conn._secure:
116:         if DEBUG:
117:             print("sha256: Sending plain password")
118:         data = conn.password + b"\0"
119:         return _roundtrip(conn, data)
120:     if pkt.is_auth_switch_request():
121:         conn.salt = pkt.read_all()
122:         if not conn.server_public_key and conn.password:
123:             # Request server public key
124:             if DEBUG:
125:                 print("sha256: Requesting server public key")
126:             pkt = _roundtrip(conn, b"\1")
127:     if pkt.is_extra_auth_data():
128:         conn.server_public_key = pkt._data[1:]
129:         if DEBUG:
130:             print("Received public key:\n", conn.server_public_key.decode("ascii"))
131:     if conn.password:
132:         if not conn.server_public_key:
133:             raise OperationalError("Couldn't receive server's public key")
134:         data = sha2_rsa_encrypt(conn.password, conn.salt, conn.server_public_key)
135:     else:
136:         data = b""
137:     return _roundtrip(conn, data)
138: def scramble_caching_sha2(password, nonce):
139:     # (bytes, bytes) -> bytes
140:     """Scramble algorithm used in cached_sha2_password fast path.
141:     XOR(SHA256(password), SHA256(SHA256(SHA256(password)), nonce))
142:     """
143:     if not password:
144:         return b""
145:     p1 = hashlib.sha256(password).digest()
146:     p2 = hashlib.sha256(p1).digest()
147:     p3 = hashlib.sha256(p2 + nonce).digest()
148:     res = bytearray(p1)
149:     for i in range(len(p3)):
150:         res[i] ^= p3[i]
151:     return bytes(res)
152: def caching_sha2_password_auth(conn, pkt):
153:     # No password fast path
154:     if not conn.password:
155:         return _roundtrip(conn, b"")
156:     if pkt.is_auth_switch_request():
157:         # Try from fast auth
158:         if DEBUG:
159:             print("caching sha2: Trying fast path")
160:         conn.salt = pkt.read_all()
161:         scrambled = scramble_caching_sha2(conn.password, conn.salt)
162:         pkt = _roundtrip(conn, scrambled)
163:     # else: fast auth is tried in initial handshake
164:     if not pkt.is_extra_auth_data():
165:         raise OperationalError(
166:             "caching sha2: Unknown packet for fast auth: %s" % pkt._data[:1]
167:         )
168:     # magic numbers:
169:     # 2 - request public key
170:     # 3 - fast auth succeeded
171:     # 4 - need full auth
172:     pkt.advance(1)
173:     n = pkt.read_uint8()
174:     if n == 3:
175:         if DEBUG:
176:             print("caching sha2: succeeded by fast path.")
177:         pkt = conn._read_packet()
178:         pkt.check_error()  # pkt must be OK packet
179:         return pkt
180:     if n != 4:
181:         raise OperationalError("caching sha2: Unknown result for fast auth: %s" % n)
182:     if DEBUG:
183:         print("caching sha2: Trying full auth...")
184:     if conn._secure:
185:         if DEBUG:
186:             print("caching sha2: Sending plain password via secure connection")
187:         return _roundtrip(conn, conn.password + b"\0")
188:     if not conn.server_public_key:
189:         pkt = _roundtrip(conn, b"\x02")  # Request public key
190:         if not pkt.is_extra_auth_data():
191:             raise OperationalError(
192:                 "caching sha2: Unknown packet for public key: %s" % pkt._data[:1]
193:             )
194:         conn.server_public_key = pkt._data[1:]
195:         if DEBUG:
196:             print(conn.server_public_key.decode("ascii"))
197:     data = sha2_rsa_encrypt(conn.password, conn.salt, conn.server_public_key)
198:     pkt = _roundtrip(conn, data)
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/charset.py
````python
  1: # Internal use only. Do not use directly.
  2: MBLENGTH = {8: 1, 33: 3, 88: 2, 91: 2}
  3: class Charset:
  4:     def __init__(self, id, name, collation, is_default=False):
  5:         self.id, self.name, self.collation = id, name, collation
  6:         self.is_default = is_default
  7:     def __repr__(self):
  8:         return (
  9:             f"Charset(id={self.id}, name={self.name!r}, collation={self.collation!r})"
 10:         )
 11:     @property
 12:     def encoding(self):
 13:         name = self.name
 14:         if name in ("utf8mb4", "utf8mb3"):
 15:             return "utf8"
 16:         if name == "latin1":
 17:             return "cp1252"
 18:         if name == "koi8r":
 19:             return "koi8_r"
 20:         if name == "koi8u":
 21:             return "koi8_u"
 22:         return name
 23:     @property
 24:     def is_binary(self):
 25:         return self.id == 63
 26: class Charsets:
 27:     def __init__(self):
 28:         self._by_id = {}
 29:         self._by_name = {}
 30:     def add(self, c):
 31:         self._by_id[c.id] = c
 32:         if c.is_default:
 33:             self._by_name[c.name] = c
 34:     def by_id(self, id):
 35:         return self._by_id[id]
 36:     def by_name(self, name):
 37:         if name == "utf8":
 38:             name = "utf8mb4"
 39:         return self._by_name.get(name.lower())
 40: _charsets = Charsets()
 41: charset_by_name = _charsets.by_name
 42: charset_by_id = _charsets.by_id
 43: """
 44: TODO: update this script.
 45: Generated with:
 46: mysql -N -s -e "select id, character_set_name, collation_name, is_default
 47: from information_schema.collations order by id;" | python -c "import sys
 48: for l in sys.stdin.readlines():
 49:     id, name, collation, is_default  = l.split(chr(9))
 50:     if is_default.strip() == "Yes":
 51:         print('_charsets.add(Charset(%s, \'%s\', \'%s\', True))' \
 52:               % (id, name, collation))
 53:     else:
 54:         print('_charsets.add(Charset(%s, \'%s\', \'%s\'))' \
 55:               % (id, name, collation, bool(is_default.strip()))
 56: """
 57: _charsets.add(Charset(1, "big5", "big5_chinese_ci", True))
 58: _charsets.add(Charset(2, "latin2", "latin2_czech_cs"))
 59: _charsets.add(Charset(3, "dec8", "dec8_swedish_ci", True))
 60: _charsets.add(Charset(4, "cp850", "cp850_general_ci", True))
 61: _charsets.add(Charset(5, "latin1", "latin1_german1_ci"))
 62: _charsets.add(Charset(6, "hp8", "hp8_english_ci", True))
 63: _charsets.add(Charset(7, "koi8r", "koi8r_general_ci", True))
 64: _charsets.add(Charset(8, "latin1", "latin1_swedish_ci", True))
 65: _charsets.add(Charset(9, "latin2", "latin2_general_ci", True))
 66: _charsets.add(Charset(10, "swe7", "swe7_swedish_ci", True))
 67: _charsets.add(Charset(11, "ascii", "ascii_general_ci", True))
 68: _charsets.add(Charset(12, "ujis", "ujis_japanese_ci", True))
 69: _charsets.add(Charset(13, "sjis", "sjis_japanese_ci", True))
 70: _charsets.add(Charset(14, "cp1251", "cp1251_bulgarian_ci"))
 71: _charsets.add(Charset(15, "latin1", "latin1_danish_ci"))
 72: _charsets.add(Charset(16, "hebrew", "hebrew_general_ci", True))
 73: _charsets.add(Charset(18, "tis620", "tis620_thai_ci", True))
 74: _charsets.add(Charset(19, "euckr", "euckr_korean_ci", True))
 75: _charsets.add(Charset(20, "latin7", "latin7_estonian_cs"))
 76: _charsets.add(Charset(21, "latin2", "latin2_hungarian_ci"))
 77: _charsets.add(Charset(22, "koi8u", "koi8u_general_ci", True))
 78: _charsets.add(Charset(23, "cp1251", "cp1251_ukrainian_ci"))
 79: _charsets.add(Charset(24, "gb2312", "gb2312_chinese_ci", True))
 80: _charsets.add(Charset(25, "greek", "greek_general_ci", True))
 81: _charsets.add(Charset(26, "cp1250", "cp1250_general_ci", True))
 82: _charsets.add(Charset(27, "latin2", "latin2_croatian_ci"))
 83: _charsets.add(Charset(28, "gbk", "gbk_chinese_ci", True))
 84: _charsets.add(Charset(29, "cp1257", "cp1257_lithuanian_ci"))
 85: _charsets.add(Charset(30, "latin5", "latin5_turkish_ci", True))
 86: _charsets.add(Charset(31, "latin1", "latin1_german2_ci"))
 87: _charsets.add(Charset(32, "armscii8", "armscii8_general_ci", True))
 88: _charsets.add(Charset(33, "utf8mb3", "utf8mb3_general_ci", True))
 89: _charsets.add(Charset(34, "cp1250", "cp1250_czech_cs"))
 90: _charsets.add(Charset(36, "cp866", "cp866_general_ci", True))
 91: _charsets.add(Charset(37, "keybcs2", "keybcs2_general_ci", True))
 92: _charsets.add(Charset(38, "macce", "macce_general_ci", True))
 93: _charsets.add(Charset(39, "macroman", "macroman_general_ci", True))
 94: _charsets.add(Charset(40, "cp852", "cp852_general_ci", True))
 95: _charsets.add(Charset(41, "latin7", "latin7_general_ci", True))
 96: _charsets.add(Charset(42, "latin7", "latin7_general_cs"))
 97: _charsets.add(Charset(43, "macce", "macce_bin"))
 98: _charsets.add(Charset(44, "cp1250", "cp1250_croatian_ci"))
 99: _charsets.add(Charset(45, "utf8mb4", "utf8mb4_general_ci", True))
100: _charsets.add(Charset(46, "utf8mb4", "utf8mb4_bin"))
101: _charsets.add(Charset(47, "latin1", "latin1_bin"))
102: _charsets.add(Charset(48, "latin1", "latin1_general_ci"))
103: _charsets.add(Charset(49, "latin1", "latin1_general_cs"))
104: _charsets.add(Charset(50, "cp1251", "cp1251_bin"))
105: _charsets.add(Charset(51, "cp1251", "cp1251_general_ci", True))
106: _charsets.add(Charset(52, "cp1251", "cp1251_general_cs"))
107: _charsets.add(Charset(53, "macroman", "macroman_bin"))
108: _charsets.add(Charset(57, "cp1256", "cp1256_general_ci", True))
109: _charsets.add(Charset(58, "cp1257", "cp1257_bin"))
110: _charsets.add(Charset(59, "cp1257", "cp1257_general_ci", True))
111: _charsets.add(Charset(63, "binary", "binary", True))
112: _charsets.add(Charset(64, "armscii8", "armscii8_bin"))
113: _charsets.add(Charset(65, "ascii", "ascii_bin"))
114: _charsets.add(Charset(66, "cp1250", "cp1250_bin"))
115: _charsets.add(Charset(67, "cp1256", "cp1256_bin"))
116: _charsets.add(Charset(68, "cp866", "cp866_bin"))
117: _charsets.add(Charset(69, "dec8", "dec8_bin"))
118: _charsets.add(Charset(70, "greek", "greek_bin"))
119: _charsets.add(Charset(71, "hebrew", "hebrew_bin"))
120: _charsets.add(Charset(72, "hp8", "hp8_bin"))
121: _charsets.add(Charset(73, "keybcs2", "keybcs2_bin"))
122: _charsets.add(Charset(74, "koi8r", "koi8r_bin"))
123: _charsets.add(Charset(75, "koi8u", "koi8u_bin"))
124: _charsets.add(Charset(76, "utf8mb3", "utf8mb3_tolower_ci"))
125: _charsets.add(Charset(77, "latin2", "latin2_bin"))
126: _charsets.add(Charset(78, "latin5", "latin5_bin"))
127: _charsets.add(Charset(79, "latin7", "latin7_bin"))
128: _charsets.add(Charset(80, "cp850", "cp850_bin"))
129: _charsets.add(Charset(81, "cp852", "cp852_bin"))
130: _charsets.add(Charset(82, "swe7", "swe7_bin"))
131: _charsets.add(Charset(83, "utf8mb3", "utf8mb3_bin"))
132: _charsets.add(Charset(84, "big5", "big5_bin"))
133: _charsets.add(Charset(85, "euckr", "euckr_bin"))
134: _charsets.add(Charset(86, "gb2312", "gb2312_bin"))
135: _charsets.add(Charset(87, "gbk", "gbk_bin"))
136: _charsets.add(Charset(88, "sjis", "sjis_bin"))
137: _charsets.add(Charset(89, "tis620", "tis620_bin"))
138: _charsets.add(Charset(91, "ujis", "ujis_bin"))
139: _charsets.add(Charset(92, "geostd8", "geostd8_general_ci", True))
140: _charsets.add(Charset(93, "geostd8", "geostd8_bin"))
141: _charsets.add(Charset(94, "latin1", "latin1_spanish_ci"))
142: _charsets.add(Charset(95, "cp932", "cp932_japanese_ci", True))
143: _charsets.add(Charset(96, "cp932", "cp932_bin"))
144: _charsets.add(Charset(97, "eucjpms", "eucjpms_japanese_ci", True))
145: _charsets.add(Charset(98, "eucjpms", "eucjpms_bin"))
146: _charsets.add(Charset(99, "cp1250", "cp1250_polish_ci"))
147: _charsets.add(Charset(192, "utf8mb3", "utf8mb3_unicode_ci"))
148: _charsets.add(Charset(193, "utf8mb3", "utf8mb3_icelandic_ci"))
149: _charsets.add(Charset(194, "utf8mb3", "utf8mb3_latvian_ci"))
150: _charsets.add(Charset(195, "utf8mb3", "utf8mb3_romanian_ci"))
151: _charsets.add(Charset(196, "utf8mb3", "utf8mb3_slovenian_ci"))
152: _charsets.add(Charset(197, "utf8mb3", "utf8mb3_polish_ci"))
153: _charsets.add(Charset(198, "utf8mb3", "utf8mb3_estonian_ci"))
154: _charsets.add(Charset(199, "utf8mb3", "utf8mb3_spanish_ci"))
155: _charsets.add(Charset(200, "utf8mb3", "utf8mb3_swedish_ci"))
156: _charsets.add(Charset(201, "utf8mb3", "utf8mb3_turkish_ci"))
157: _charsets.add(Charset(202, "utf8mb3", "utf8mb3_czech_ci"))
158: _charsets.add(Charset(203, "utf8mb3", "utf8mb3_danish_ci"))
159: _charsets.add(Charset(204, "utf8mb3", "utf8mb3_lithuanian_ci"))
160: _charsets.add(Charset(205, "utf8mb3", "utf8mb3_slovak_ci"))
161: _charsets.add(Charset(206, "utf8mb3", "utf8mb3_spanish2_ci"))
162: _charsets.add(Charset(207, "utf8mb3", "utf8mb3_roman_ci"))
163: _charsets.add(Charset(208, "utf8mb3", "utf8mb3_persian_ci"))
164: _charsets.add(Charset(209, "utf8mb3", "utf8mb3_esperanto_ci"))
165: _charsets.add(Charset(210, "utf8mb3", "utf8mb3_hungarian_ci"))
166: _charsets.add(Charset(211, "utf8mb3", "utf8mb3_sinhala_ci"))
167: _charsets.add(Charset(212, "utf8mb3", "utf8mb3_german2_ci"))
168: _charsets.add(Charset(213, "utf8mb3", "utf8mb3_croatian_ci"))
169: _charsets.add(Charset(214, "utf8mb3", "utf8mb3_unicode_520_ci"))
170: _charsets.add(Charset(215, "utf8mb3", "utf8mb3_vietnamese_ci"))
171: _charsets.add(Charset(223, "utf8mb3", "utf8mb3_general_mysql500_ci"))
172: _charsets.add(Charset(224, "utf8mb4", "utf8mb4_unicode_ci"))
173: _charsets.add(Charset(225, "utf8mb4", "utf8mb4_icelandic_ci"))
174: _charsets.add(Charset(226, "utf8mb4", "utf8mb4_latvian_ci"))
175: _charsets.add(Charset(227, "utf8mb4", "utf8mb4_romanian_ci"))
176: _charsets.add(Charset(228, "utf8mb4", "utf8mb4_slovenian_ci"))
177: _charsets.add(Charset(229, "utf8mb4", "utf8mb4_polish_ci"))
178: _charsets.add(Charset(230, "utf8mb4", "utf8mb4_estonian_ci"))
179: _charsets.add(Charset(231, "utf8mb4", "utf8mb4_spanish_ci"))
180: _charsets.add(Charset(232, "utf8mb4", "utf8mb4_swedish_ci"))
181: _charsets.add(Charset(233, "utf8mb4", "utf8mb4_turkish_ci"))
182: _charsets.add(Charset(234, "utf8mb4", "utf8mb4_czech_ci"))
183: _charsets.add(Charset(235, "utf8mb4", "utf8mb4_danish_ci"))
184: _charsets.add(Charset(236, "utf8mb4", "utf8mb4_lithuanian_ci"))
185: _charsets.add(Charset(237, "utf8mb4", "utf8mb4_slovak_ci"))
186: _charsets.add(Charset(238, "utf8mb4", "utf8mb4_spanish2_ci"))
187: _charsets.add(Charset(239, "utf8mb4", "utf8mb4_roman_ci"))
188: _charsets.add(Charset(240, "utf8mb4", "utf8mb4_persian_ci"))
189: _charsets.add(Charset(241, "utf8mb4", "utf8mb4_esperanto_ci"))
190: _charsets.add(Charset(242, "utf8mb4", "utf8mb4_hungarian_ci"))
191: _charsets.add(Charset(243, "utf8mb4", "utf8mb4_sinhala_ci"))
192: _charsets.add(Charset(244, "utf8mb4", "utf8mb4_german2_ci"))
193: _charsets.add(Charset(245, "utf8mb4", "utf8mb4_croatian_ci"))
194: _charsets.add(Charset(246, "utf8mb4", "utf8mb4_unicode_520_ci"))
195: _charsets.add(Charset(247, "utf8mb4", "utf8mb4_vietnamese_ci"))
196: _charsets.add(Charset(248, "gb18030", "gb18030_chinese_ci", True))
197: _charsets.add(Charset(249, "gb18030", "gb18030_bin"))
198: _charsets.add(Charset(250, "gb18030", "gb18030_unicode_520_ci"))
199: _charsets.add(Charset(255, "utf8mb4", "utf8mb4_0900_ai_ci"))
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/connections.py
````python
   1: # Python implementation of the MySQL client-server protocol
   2: # http://dev.mysql.com/doc/internals/en/client-server-protocol.html
   3: # Error codes:
   4: # https://dev.mysql.com/doc/refman/5.5/en/error-handling.html
   5: import errno
   6: import os
   7: import socket
   8: import struct
   9: import sys
  10: import traceback
  11: import warnings
  12: from . import _auth
  13: from .charset import charset_by_name, charset_by_id
  14: from .constants import CLIENT, COMMAND, CR, ER, FIELD_TYPE, SERVER_STATUS
  15: from . import converters
  16: from .cursors import Cursor
  17: from .optionfile import Parser
  18: from .protocol import (
  19:     dump_packet,
  20:     MysqlPacket,
  21:     FieldDescriptorPacket,
  22:     OKPacketWrapper,
  23:     EOFPacketWrapper,
  24:     LoadLocalPacketWrapper,
  25: )
  26: from . import err, VERSION_STRING
  27: try:
  28:     import ssl
  29:     SSL_ENABLED = True
  30: except ImportError:
  31:     ssl = None
  32:     SSL_ENABLED = False
  33: try:
  34:     import getpass
  35:     DEFAULT_USER = getpass.getuser()
  36:     del getpass
  37: except (ImportError, KeyError):
  38:     # KeyError occurs when there's no entry in OS database for a current user.
  39:     DEFAULT_USER = None
  40: DEBUG = False
  41: TEXT_TYPES = {
  42:     FIELD_TYPE.BIT,
  43:     FIELD_TYPE.BLOB,
  44:     FIELD_TYPE.LONG_BLOB,
  45:     FIELD_TYPE.MEDIUM_BLOB,
  46:     FIELD_TYPE.STRING,
  47:     FIELD_TYPE.TINY_BLOB,
  48:     FIELD_TYPE.VAR_STRING,
  49:     FIELD_TYPE.VARCHAR,
  50:     FIELD_TYPE.GEOMETRY,
  51: }
  52: DEFAULT_CHARSET = "utf8mb4"
  53: MAX_PACKET_LEN = 2**24 - 1
  54: def _pack_int24(n):
  55:     return struct.pack("<I", n)[:3]
  56: # https://dev.mysql.com/doc/internals/en/integer.html#packet-Protocol::LengthEncodedInteger
  57: def _lenenc_int(i):
  58:     if i < 0:
  59:         raise ValueError(
  60:             "Encoding %d is less than 0 - no representation in LengthEncodedInteger" % i
  61:         )
  62:     elif i < 0xFB:
  63:         return bytes([i])
  64:     elif i < (1 << 16):
  65:         return b"\xfc" + struct.pack("<H", i)
  66:     elif i < (1 << 24):
  67:         return b"\xfd" + struct.pack("<I", i)[:3]
  68:     elif i < (1 << 64):
  69:         return b"\xfe" + struct.pack("<Q", i)
  70:     else:
  71:         raise ValueError(
  72:             f"Encoding {i:x} is larger than {1 << 64:x} - no representation in LengthEncodedInteger"
  73:         )
  74: class Connection:
  75:     """
  76:     Representation of a socket with a mysql server.
  77:     The proper way to get an instance of this class is to call
  78:     connect().
  79:     Establish a connection to the MySQL database. Accepts several
  80:     arguments:
  81:     :param host: Host where the database server is located.
  82:     :param user: Username to log in as.
  83:     :param password: Password to use.
  84:     :param database: Database to use, None to not use a particular one.
  85:     :param port: MySQL port to use, default is usually OK. (default: 3306)
  86:     :param bind_address: When the client has multiple network interfaces, specify
  87:         the interface from which to connect to the host. Argument can be
  88:         a hostname or an IP address.
  89:     :param unix_socket: Use a unix socket rather than TCP/IP.
  90:     :param read_timeout: The timeout for reading from the connection in seconds.
  91:         (default: None - no timeout)
  92:     :param write_timeout: The timeout for writing to the connection in seconds.
  93:         (default: None - no timeout)
  94:     :param str charset: Charset to use.
  95:     :param str collation: Collation name to use.
  96:     :param sql_mode: Default SQL_MODE to use.
  97:     :param read_default_file:
  98:         Specifies  my.cnf file to read these parameters from under the [client] section.
  99:     :param conv:
 100:         Conversion dictionary to use instead of the default one.
 101:         This is used to provide custom marshalling and unmarshalling of types.
 102:         See converters.
 103:     :param use_unicode:
 104:         Whether or not to default to unicode strings.
 105:         This option defaults to true.
 106:     :param client_flag: Custom flags to send to MySQL. Find potential values in constants.CLIENT.
 107:     :param cursorclass: Custom cursor class to use.
 108:     :param init_command: Initial SQL statement to run when connection is established.
 109:     :param connect_timeout: The timeout for connecting to the database in seconds.
 110:         (default: 10, min: 1, max: 31536000)
 111:     :param ssl: A dict of arguments similar to mysql_ssl_set()'s parameters or an ssl.SSLContext.
 112:     :param ssl_ca: Path to the file that contains a PEM-formatted CA certificate.
 113:     :param ssl_cert: Path to the file that contains a PEM-formatted client certificate.
 114:     :param ssl_disabled: A boolean value that disables usage of TLS.
 115:     :param ssl_key: Path to the file that contains a PEM-formatted private key for
 116:         the client certificate.
 117:     :param ssl_key_password: The password for the client certificate private key.
 118:     :param ssl_verify_cert: Set to true to check the server certificate's validity.
 119:     :param ssl_verify_identity: Set to true to check the server's identity.
 120:     :param read_default_group: Group to read from in the configuration file.
 121:     :param autocommit: Autocommit mode. None means use server default. (default: False)
 122:     :param local_infile: Boolean to enable the use of LOAD DATA LOCAL command. (default: False)
 123:     :param max_allowed_packet: Max size of packet sent to server in bytes. (default: 16MB)
 124:         Only used to limit size of "LOAD LOCAL INFILE" data packet smaller than default (16KB).
 125:     :param defer_connect: Don't explicitly connect on construction - wait for connect call.
 126:         (default: False)
 127:     :param auth_plugin_map: A dict of plugin names to a class that processes that plugin.
 128:         The class will take the Connection object as the argument to the constructor.
 129:         The class needs an authenticate method taking an authentication packet as
 130:         an argument.  For the dialog plugin, a prompt(echo, prompt) method can be used
 131:         (if no authenticate method) for returning a string from the user. (experimental)
 132:     :param server_public_key: SHA256 authentication plugin public key value. (default: None)
 133:     :param binary_prefix: Add _binary prefix on bytes and bytearray. (default: False)
 134:     :param compress: Not supported.
 135:     :param named_pipe: Not supported.
 136:     :param db: **DEPRECATED** Alias for database.
 137:     :param passwd: **DEPRECATED** Alias for password.
 138:     See `Connection <https://www.python.org/dev/peps/pep-0249/#connection-objects>`_ in the
 139:     specification.
 140:     """
 141:     _sock = None
 142:     _auth_plugin_name = ""
 143:     _closed = False
 144:     _secure = False
 145:     def __init__(
 146:         self,
 147:         *,
 148:         user=None,  # The first four arguments is based on DB-API 2.0 recommendation.
 149:         password="",
 150:         host=None,
 151:         database=None,
 152:         unix_socket=None,
 153:         port=0,
 154:         charset="",
 155:         collation=None,
 156:         sql_mode=None,
 157:         read_default_file=None,
 158:         conv=None,
 159:         use_unicode=True,
 160:         client_flag=0,
 161:         cursorclass=Cursor,
 162:         init_command=None,
 163:         connect_timeout=10,
 164:         read_default_group=None,
 165:         autocommit=False,
 166:         local_infile=False,
 167:         max_allowed_packet=16 * 1024 * 1024,
 168:         defer_connect=False,
 169:         auth_plugin_map=None,
 170:         read_timeout=None,
 171:         write_timeout=None,
 172:         bind_address=None,
 173:         binary_prefix=False,
 174:         program_name=None,
 175:         server_public_key=None,
 176:         ssl=None,
 177:         ssl_ca=None,
 178:         ssl_cert=None,
 179:         ssl_disabled=None,
 180:         ssl_key=None,
 181:         ssl_key_password=None,
 182:         ssl_verify_cert=None,
 183:         ssl_verify_identity=None,
 184:         compress=None,  # not supported
 185:         named_pipe=None,  # not supported
 186:         passwd=None,  # deprecated
 187:         db=None,  # deprecated
 188:     ):
 189:         if db is not None and database is None:
 190:             # We will raise warning in 2022 or later.
 191:             # See https://github.com/PyMySQL/PyMySQL/issues/939
 192:             # warnings.warn("'db' is deprecated, use 'database'", DeprecationWarning, 3)
 193:             database = db
 194:         if passwd is not None and not password:
 195:             # We will raise warning in 2022 or later.
 196:             # See https://github.com/PyMySQL/PyMySQL/issues/939
 197:             # warnings.warn(
 198:             #    "'passwd' is deprecated, use 'password'", DeprecationWarning, 3
 199:             # )
 200:             password = passwd
 201:         if compress or named_pipe:
 202:             raise NotImplementedError(
 203:                 "compress and named_pipe arguments are not supported"
 204:             )
 205:         self._local_infile = bool(local_infile)
 206:         if self._local_infile:
 207:             client_flag |= CLIENT.LOCAL_FILES
 208:         if read_default_group and not read_default_file:
 209:             if sys.platform.startswith("win"):
 210:                 read_default_file = "c:\\my.ini"
 211:             else:
 212:                 read_default_file = "/etc/my.cnf"
 213:         if read_default_file:
 214:             if not read_default_group:
 215:                 read_default_group = "client"
 216:             cfg = Parser()
 217:             cfg.read(os.path.expanduser(read_default_file))
 218:             def _config(key, arg):
 219:                 if arg:
 220:                     return arg
 221:                 try:
 222:                     return cfg.get(read_default_group, key)
 223:                 except Exception:
 224:                     return arg
 225:             user = _config("user", user)
 226:             password = _config("password", password)
 227:             host = _config("host", host)
 228:             database = _config("database", database)
 229:             unix_socket = _config("socket", unix_socket)
 230:             port = int(_config("port", port))
 231:             bind_address = _config("bind-address", bind_address)
 232:             charset = _config("default-character-set", charset)
 233:             if not ssl:
 234:                 ssl = {}
 235:             if isinstance(ssl, dict):
 236:                 for key in ["ca", "capath", "cert", "key", "password", "cipher"]:
 237:                     value = _config("ssl-" + key, ssl.get(key))
 238:                     if value:
 239:                         ssl[key] = value
 240:         self.ssl = False
 241:         if not ssl_disabled:
 242:             if ssl_ca or ssl_cert or ssl_key or ssl_verify_cert or ssl_verify_identity:
 243:                 ssl = {
 244:                     "ca": ssl_ca,
 245:                     "check_hostname": bool(ssl_verify_identity),
 246:                     "verify_mode": ssl_verify_cert
 247:                     if ssl_verify_cert is not None
 248:                     else False,
 249:                 }
 250:                 if ssl_cert is not None:
 251:                     ssl["cert"] = ssl_cert
 252:                 if ssl_key is not None:
 253:                     ssl["key"] = ssl_key
 254:                 if ssl_key_password is not None:
 255:                     ssl["password"] = ssl_key_password
 256:             if ssl:
 257:                 if not SSL_ENABLED:
 258:                     raise NotImplementedError("ssl module not found")
 259:                 self.ssl = True
 260:                 client_flag |= CLIENT.SSL
 261:                 self.ctx = self._create_ssl_ctx(ssl)
 262:         self.host = host or "localhost"
 263:         self.port = port or 3306
 264:         if type(self.port) is not int:
 265:             raise ValueError("port should be of type int")
 266:         self.user = user or DEFAULT_USER
 267:         self.password = password or b""
 268:         if isinstance(self.password, str):
 269:             self.password = self.password.encode("latin1")
 270:         self.db = database
 271:         self.unix_socket = unix_socket
 272:         self.bind_address = bind_address
 273:         if not (0 < connect_timeout <= 31536000):
 274:             raise ValueError("connect_timeout should be >0 and <=31536000")
 275:         self.connect_timeout = connect_timeout or None
 276:         if read_timeout is not None and read_timeout <= 0:
 277:             raise ValueError("read_timeout should be > 0")
 278:         self._read_timeout = read_timeout
 279:         if write_timeout is not None and write_timeout <= 0:
 280:             raise ValueError("write_timeout should be > 0")
 281:         self._write_timeout = write_timeout
 282:         self.charset = charset or DEFAULT_CHARSET
 283:         self.collation = collation
 284:         self.use_unicode = use_unicode
 285:         self.encoding = charset_by_name(self.charset).encoding
 286:         client_flag |= CLIENT.CAPABILITIES
 287:         if self.db:
 288:             client_flag |= CLIENT.CONNECT_WITH_DB
 289:         self.client_flag = client_flag
 290:         self.cursorclass = cursorclass
 291:         self._result = None
 292:         self._affected_rows = 0
 293:         self.host_info = "Not connected"
 294:         # specified autocommit mode. None means use server default.
 295:         self.autocommit_mode = autocommit
 296:         if conv is None:
 297:             conv = converters.conversions
 298:         # Need for MySQLdb compatibility.
 299:         self.encoders = {k: v for (k, v) in conv.items() if type(k) is not int}
 300:         self.decoders = {k: v for (k, v) in conv.items() if type(k) is int}
 301:         self.sql_mode = sql_mode
 302:         self.init_command = init_command
 303:         self.max_allowed_packet = max_allowed_packet
 304:         self._auth_plugin_map = auth_plugin_map or {}
 305:         self._binary_prefix = binary_prefix
 306:         self.server_public_key = server_public_key
 307:         self._connect_attrs = {
 308:             "_client_name": "pymysql",
 309:             "_client_version": VERSION_STRING,
 310:             "_pid": str(os.getpid()),
 311:         }
 312:         if program_name:
 313:             self._connect_attrs["program_name"] = program_name
 314:         if defer_connect:
 315:             self._sock = None
 316:         else:
 317:             self.connect()
 318:     def __enter__(self):
 319:         return self
 320:     def __exit__(self, *exc_info):
 321:         del exc_info
 322:         self.close()
 323:     def _create_ssl_ctx(self, sslp):
 324:         if isinstance(sslp, ssl.SSLContext):
 325:             return sslp
 326:         ca = sslp.get("ca")
 327:         capath = sslp.get("capath")
 328:         hasnoca = ca is None and capath is None
 329:         ctx = ssl.create_default_context(cafile=ca, capath=capath)
 330:         ctx.check_hostname = not hasnoca and sslp.get("check_hostname", True)
 331:         verify_mode_value = sslp.get("verify_mode")
 332:         if verify_mode_value is None:
 333:             ctx.verify_mode = ssl.CERT_NONE if hasnoca else ssl.CERT_REQUIRED
 334:         elif isinstance(verify_mode_value, bool):
 335:             ctx.verify_mode = ssl.CERT_REQUIRED if verify_mode_value else ssl.CERT_NONE
 336:         else:
 337:             if isinstance(verify_mode_value, str):
 338:                 verify_mode_value = verify_mode_value.lower()
 339:             if verify_mode_value in ("none", "0", "false", "no"):
 340:                 ctx.verify_mode = ssl.CERT_NONE
 341:             elif verify_mode_value == "optional":
 342:                 ctx.verify_mode = ssl.CERT_OPTIONAL
 343:             elif verify_mode_value in ("required", "1", "true", "yes"):
 344:                 ctx.verify_mode = ssl.CERT_REQUIRED
 345:             else:
 346:                 ctx.verify_mode = ssl.CERT_NONE if hasnoca else ssl.CERT_REQUIRED
 347:         if "cert" in sslp:
 348:             ctx.load_cert_chain(
 349:                 sslp["cert"], keyfile=sslp.get("key"), password=sslp.get("password")
 350:             )
 351:         if "cipher" in sslp:
 352:             ctx.set_ciphers(sslp["cipher"])
 353:         ctx.options |= ssl.OP_NO_SSLv2
 354:         ctx.options |= ssl.OP_NO_SSLv3
 355:         return ctx
 356:     def close(self):
 357:         """
 358:         Send the quit message and close the socket.
 359:         See `Connection.close() <https://www.python.org/dev/peps/pep-0249/#Connection.close>`_
 360:         in the specification.
 361:         :raise Error: If the connection is already closed.
 362:         """
 363:         if self._closed:
 364:             raise err.Error("Already closed")
 365:         self._closed = True
 366:         if self._sock is None:
 367:             return
 368:         send_data = struct.pack("<iB", 1, COMMAND.COM_QUIT)
 369:         try:
 370:             self._write_bytes(send_data)
 371:         except Exception:
 372:             pass
 373:         finally:
 374:             self._force_close()
 375:     @property
 376:     def open(self):
 377:         """Return True if the connection is open."""
 378:         return self._sock is not None
 379:     def _force_close(self):
 380:         """Close connection without QUIT message."""
 381:         if self._sock:
 382:             try:
 383:                 self._sock.close()
 384:             except:  # noqa
 385:                 pass
 386:         self._sock = None
 387:         self._rfile = None
 388:     __del__ = _force_close
 389:     def autocommit(self, value):
 390:         self.autocommit_mode = bool(value)
 391:         current = self.get_autocommit()
 392:         if value != current:
 393:             self._send_autocommit_mode()
 394:     def get_autocommit(self):
 395:         return bool(self.server_status & SERVER_STATUS.SERVER_STATUS_AUTOCOMMIT)
 396:     def _read_ok_packet(self):
 397:         pkt = self._read_packet()
 398:         if not pkt.is_ok_packet():
 399:             raise err.OperationalError(
 400:                 CR.CR_COMMANDS_OUT_OF_SYNC,
 401:                 "Command Out of Sync",
 402:             )
 403:         ok = OKPacketWrapper(pkt)
 404:         self.server_status = ok.server_status
 405:         return ok
 406:     def _send_autocommit_mode(self):
 407:         """Set whether or not to commit after every execute()."""
 408:         self._execute_command(
 409:             COMMAND.COM_QUERY, "SET AUTOCOMMIT = %s" % self.escape(self.autocommit_mode)
 410:         )
 411:         self._read_ok_packet()
 412:     def begin(self):
 413:         """Begin transaction."""
 414:         self._execute_command(COMMAND.COM_QUERY, "BEGIN")
 415:         self._read_ok_packet()
 416:     def commit(self):
 417:         """
 418:         Commit changes to stable storage.
 419:         See `Connection.commit() <https://www.python.org/dev/peps/pep-0249/#commit>`_
 420:         in the specification.
 421:         """
 422:         self._execute_command(COMMAND.COM_QUERY, "COMMIT")
 423:         self._read_ok_packet()
 424:     def rollback(self):
 425:         """
 426:         Roll back the current transaction.
 427:         See `Connection.rollback() <https://www.python.org/dev/peps/pep-0249/#rollback>`_
 428:         in the specification.
 429:         """
 430:         self._execute_command(COMMAND.COM_QUERY, "ROLLBACK")
 431:         self._read_ok_packet()
 432:     def show_warnings(self):
 433:         """Send the "SHOW WARNINGS" SQL command."""
 434:         self._execute_command(COMMAND.COM_QUERY, "SHOW WARNINGS")
 435:         result = MySQLResult(self)
 436:         result.read()
 437:         return result.rows
 438:     def select_db(self, db):
 439:         """
 440:         Set current db.
 441:         :param db: The name of the db.
 442:         """
 443:         self._execute_command(COMMAND.COM_INIT_DB, db)
 444:         self._read_ok_packet()
 445:     def escape(self, obj, mapping=None):
 446:         """Escape whatever value is passed.
 447:         Non-standard, for internal use; do not use this in your applications.
 448:         """
 449:         if isinstance(obj, str):
 450:             return "'" + self.escape_string(obj) + "'"
 451:         if isinstance(obj, (bytes, bytearray)):
 452:             ret = self._quote_bytes(obj)
 453:             if self._binary_prefix:
 454:                 ret = "_binary" + ret
 455:             return ret
 456:         return converters.escape_item(obj, self.charset, mapping=mapping)
 457:     def literal(self, obj):
 458:         """Alias for escape().
 459:         Non-standard, for internal use; do not use this in your applications.
 460:         """
 461:         return self.escape(obj, self.encoders)
 462:     def escape_string(self, s):
 463:         if self.server_status & SERVER_STATUS.SERVER_STATUS_NO_BACKSLASH_ESCAPES:
 464:             return s.replace("'", "''")
 465:         return converters.escape_string(s)
 466:     def _quote_bytes(self, s):
 467:         if self.server_status & SERVER_STATUS.SERVER_STATUS_NO_BACKSLASH_ESCAPES:
 468:             return "'{}'".format(
 469:                 s.replace(b"'", b"''").decode("ascii", "surrogateescape")
 470:             )
 471:         return converters.escape_bytes(s)
 472:     def cursor(self, cursor=None):
 473:         """
 474:         Create a new cursor to execute queries with.
 475:         :param cursor: The type of cursor to create. None means use Cursor.
 476:         :type cursor: :py:class:`Cursor`, :py:class:`SSCursor`, :py:class:`DictCursor`,
 477:             or :py:class:`SSDictCursor`.
 478:         """
 479:         if cursor:
 480:             return cursor(self)
 481:         return self.cursorclass(self)
 482:     # The following methods are INTERNAL USE ONLY (called from Cursor)
 483:     def query(self, sql, unbuffered=False):
 484:         # if DEBUG:
 485:         #     print("DEBUG: sending query:", sql)
 486:         if isinstance(sql, str):
 487:             sql = sql.encode(self.encoding, "surrogateescape")
 488:         self._execute_command(COMMAND.COM_QUERY, sql)
 489:         self._affected_rows = self._read_query_result(unbuffered=unbuffered)
 490:         return self._affected_rows
 491:     def next_result(self, unbuffered=False):
 492:         self._affected_rows = self._read_query_result(unbuffered=unbuffered)
 493:         return self._affected_rows
 494:     def affected_rows(self):
 495:         return self._affected_rows
 496:     def kill(self, thread_id):
 497:         arg = struct.pack("<I", thread_id)
 498:         self._execute_command(COMMAND.COM_PROCESS_KILL, arg)
 499:         return self._read_ok_packet()
 500:     def ping(self, reconnect=True):
 501:         """
 502:         Check if the server is alive.
 503:         :param reconnect: If the connection is closed, reconnect.
 504:         :type reconnect: boolean
 505:         :raise Error: If the connection is closed and reconnect=False.
 506:         """
 507:         if self._sock is None:
 508:             if reconnect:
 509:                 self.connect()
 510:                 reconnect = False
 511:             else:
 512:                 raise err.Error("Already closed")
 513:         try:
 514:             self._execute_command(COMMAND.COM_PING, "")
 515:             self._read_ok_packet()
 516:         except Exception:
 517:             if reconnect:
 518:                 self.connect()
 519:                 self.ping(False)
 520:             else:
 521:                 raise
 522:     def set_charset(self, charset):
 523:         """Deprecated. Use set_character_set() instead."""
 524:         # This function has been implemented in old PyMySQL.
 525:         # But this name is different from MySQLdb.
 526:         # So we keep this function for compatibility and add
 527:         # new set_character_set() function.
 528:         self.set_character_set(charset)
 529:     def set_character_set(self, charset, collation=None):
 530:         """
 531:         Set charaset (and collation)
 532:         Send "SET NAMES charset [COLLATE collation]" query.
 533:         Update Connection.encoding based on charset.
 534:         """
 535:         # Make sure charset is supported.
 536:         encoding = charset_by_name(charset).encoding
 537:         if collation:
 538:             query = f"SET NAMES {charset} COLLATE {collation}"
 539:         else:
 540:             query = f"SET NAMES {charset}"
 541:         self._execute_command(COMMAND.COM_QUERY, query)
 542:         self._read_packet()
 543:         self.charset = charset
 544:         self.encoding = encoding
 545:         self.collation = collation
 546:     def connect(self, sock=None):
 547:         self._closed = False
 548:         try:
 549:             if sock is None:
 550:                 if self.unix_socket:
 551:                     sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
 552:                     sock.settimeout(self.connect_timeout)
 553:                     sock.connect(self.unix_socket)
 554:                     self.host_info = "Localhost via UNIX socket"
 555:                     self._secure = True
 556:                     if DEBUG:
 557:                         print("connected using unix_socket")
 558:                 else:
 559:                     kwargs = {}
 560:                     if self.bind_address is not None:
 561:                         kwargs["source_address"] = (self.bind_address, 0)
 562:                     while True:
 563:                         try:
 564:                             sock = socket.create_connection(
 565:                                 (self.host, self.port), self.connect_timeout, **kwargs
 566:                             )
 567:                             break
 568:                         except OSError as e:
 569:                             if e.errno == errno.EINTR:
 570:                                 continue
 571:                             raise
 572:                     self.host_info = "socket %s:%d" % (self.host, self.port)
 573:                     if DEBUG:
 574:                         print("connected using socket")
 575:                     sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
 576:                     sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
 577:                 sock.settimeout(None)
 578:             self._sock = sock
 579:             self._rfile = sock.makefile("rb")
 580:             self._next_seq_id = 0
 581:             self._get_server_information()
 582:             self._request_authentication()
 583:             # Send "SET NAMES" query on init for:
 584:             # - Ensure charaset (and collation) is set to the server.
 585:             #   - collation_id in handshake packet may be ignored.
 586:             # - If collation is not specified, we don't know what is server's
 587:             #   default collation for the charset. For example, default collation
 588:             #   of utf8mb4 is:
 589:             #   - MySQL 5.7, MariaDB 10.x: utf8mb4_general_ci
 590:             #   - MySQL 8.0: utf8mb4_0900_ai_ci
 591:             #
 592:             # Reference:
 593:             # - https://github.com/PyMySQL/PyMySQL/issues/1092
 594:             # - https://github.com/wagtail/wagtail/issues/9477
 595:             # - https://zenn.dev/methane/articles/2023-mysql-collation (Japanese)
 596:             self.set_character_set(self.charset, self.collation)
 597:             if self.sql_mode is not None:
 598:                 c = self.cursor()
 599:                 c.execute("SET sql_mode=%s", (self.sql_mode,))
 600:                 c.close()
 601:             if self.init_command is not None:
 602:                 c = self.cursor()
 603:                 c.execute(self.init_command)
 604:                 c.close()
 605:             if self.autocommit_mode is not None:
 606:                 self.autocommit(self.autocommit_mode)
 607:         except BaseException as e:
 608:             self._rfile = None
 609:             if sock is not None:
 610:                 try:
 611:                     sock.close()
 612:                 except:  # noqa
 613:                     pass
 614:             if isinstance(e, (OSError, IOError)):
 615:                 exc = err.OperationalError(
 616:                     CR.CR_CONN_HOST_ERROR,
 617:                     f"Can't connect to MySQL server on {self.host!r} ({e})",
 618:                 )
 619:                 # Keep original exception and traceback to investigate error.
 620:                 exc.original_exception = e
 621:                 exc.traceback = traceback.format_exc()
 622:                 if DEBUG:
 623:                     print(exc.traceback)
 624:                 raise exc
 625:             # If e is neither DatabaseError or IOError, It's a bug.
 626:             # But raising AssertionError hides original error.
 627:             # So just reraise it.
 628:             raise
 629:     def write_packet(self, payload):
 630:         """Writes an entire "mysql packet" in its entirety to the network
 631:         adding its length and sequence number.
 632:         """
 633:         # Internal note: when you build packet manually and calls _write_bytes()
 634:         # directly, you should set self._next_seq_id properly.
 635:         data = _pack_int24(len(payload)) + bytes([self._next_seq_id]) + payload
 636:         if DEBUG:
 637:             dump_packet(data)
 638:         self._write_bytes(data)
 639:         self._next_seq_id = (self._next_seq_id + 1) % 256
 640:     def _read_packet(self, packet_type=MysqlPacket):
 641:         """Read an entire "mysql packet" in its entirety from the network
 642:         and return a MysqlPacket type that represents the results.
 643:         :raise OperationalError: If the connection to the MySQL server is lost.
 644:         :raise InternalError: If the packet sequence number is wrong.
 645:         """
 646:         buff = bytearray()
 647:         while True:
 648:             packet_header = self._read_bytes(4)
 649:             # if DEBUG: dump_packet(packet_header)
 650:             btrl, btrh, packet_number = struct.unpack("<HBB", packet_header)
 651:             bytes_to_read = btrl + (btrh << 16)
 652:             if packet_number != self._next_seq_id:
 653:                 self._force_close()
 654:                 if packet_number == 0:
 655:                     # MariaDB sends error packet with seqno==0 when shutdown
 656:                     raise err.OperationalError(
 657:                         CR.CR_SERVER_LOST,
 658:                         "Lost connection to MySQL server during query",
 659:                     )
 660:                 raise err.InternalError(
 661:                     "Packet sequence number wrong - got %d expected %d"
 662:                     % (packet_number, self._next_seq_id)
 663:                 )
 664:             self._next_seq_id = (self._next_seq_id + 1) % 256
 665:             recv_data = self._read_bytes(bytes_to_read)
 666:             if DEBUG:
 667:                 dump_packet(recv_data)
 668:             buff += recv_data
 669:             # https://dev.mysql.com/doc/internals/en/sending-more-than-16mbyte.html
 670:             if bytes_to_read < MAX_PACKET_LEN:
 671:                 break
 672:         packet = packet_type(bytes(buff), self.encoding)
 673:         if packet.is_error_packet():
 674:             if self._result is not None and self._result.unbuffered_active is True:
 675:                 self._result.unbuffered_active = False
 676:             packet.raise_for_error()
 677:         return packet
 678:     def _read_bytes(self, num_bytes):
 679:         self._sock.settimeout(self._read_timeout)
 680:         while True:
 681:             try:
 682:                 data = self._rfile.read(num_bytes)
 683:                 break
 684:             except OSError as e:
 685:                 if e.errno == errno.EINTR:
 686:                     continue
 687:                 self._force_close()
 688:                 raise err.OperationalError(
 689:                     CR.CR_SERVER_LOST,
 690:                     f"Lost connection to MySQL server during query ({e})",
 691:                 )
 692:             except BaseException:
 693:                 # Don't convert unknown exception to MySQLError.
 694:                 self._force_close()
 695:                 raise
 696:         if len(data) < num_bytes:
 697:             self._force_close()
 698:             raise err.OperationalError(
 699:                 CR.CR_SERVER_LOST, "Lost connection to MySQL server during query"
 700:             )
 701:         return data
 702:     def _write_bytes(self, data):
 703:         self._sock.settimeout(self._write_timeout)
 704:         try:
 705:             self._sock.sendall(data)
 706:         except OSError as e:
 707:             self._force_close()
 708:             raise err.OperationalError(
 709:                 CR.CR_SERVER_GONE_ERROR, f"MySQL server has gone away ({e!r})"
 710:             )
 711:     def _read_query_result(self, unbuffered=False):
 712:         self._result = None
 713:         if unbuffered:
 714:             try:
 715:                 result = MySQLResult(self)
 716:                 result.init_unbuffered_query()
 717:             except:
 718:                 result.unbuffered_active = False
 719:                 result.connection = None
 720:                 raise
 721:         else:
 722:             result = MySQLResult(self)
 723:             result.read()
 724:         self._result = result
 725:         if result.server_status is not None:
 726:             self.server_status = result.server_status
 727:         return result.affected_rows
 728:     def insert_id(self):
 729:         if self._result:
 730:             return self._result.insert_id
 731:         else:
 732:             return 0
 733:     def _execute_command(self, command, sql):
 734:         """
 735:         :raise InterfaceError: If the connection is closed.
 736:         :raise ValueError: If no username was specified.
 737:         """
 738:         if not self._sock:
 739:             raise err.InterfaceError(0, "")
 740:         # If the last query was unbuffered, make sure it finishes before
 741:         # sending new commands
 742:         if self._result is not None:
 743:             if self._result.unbuffered_active:
 744:                 warnings.warn("Previous unbuffered result was left incomplete")
 745:                 self._result._finish_unbuffered_query()
 746:             while self._result.has_next:
 747:                 self.next_result()
 748:             self._result = None
 749:         if isinstance(sql, str):
 750:             sql = sql.encode(self.encoding)
 751:         packet_size = min(MAX_PACKET_LEN, len(sql) + 1)  # +1 is for command
 752:         # tiny optimization: build first packet manually instead of
 753:         # calling self..write_packet()
 754:         prelude = struct.pack("<iB", packet_size, command)
 755:         packet = prelude + sql[: packet_size - 1]
 756:         self._write_bytes(packet)
 757:         if DEBUG:
 758:             dump_packet(packet)
 759:         self._next_seq_id = 1
 760:         if packet_size < MAX_PACKET_LEN:
 761:             return
 762:         sql = sql[packet_size - 1 :]
 763:         while True:
 764:             packet_size = min(MAX_PACKET_LEN, len(sql))
 765:             self.write_packet(sql[:packet_size])
 766:             sql = sql[packet_size:]
 767:             if not sql and packet_size < MAX_PACKET_LEN:
 768:                 break
 769:     def _request_authentication(self):
 770:         # https://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::HandshakeResponse
 771:         if int(self.server_version.split(".", 1)[0]) >= 5:
 772:             self.client_flag |= CLIENT.MULTI_RESULTS
 773:         if self.user is None:
 774:             raise ValueError("Did not specify a username")
 775:         charset_id = charset_by_name(self.charset).id
 776:         if isinstance(self.user, str):
 777:             self.user = self.user.encode(self.encoding)
 778:         data_init = struct.pack(
 779:             "<iIB23s", self.client_flag, MAX_PACKET_LEN, charset_id, b""
 780:         )
 781:         if self.ssl and self.server_capabilities & CLIENT.SSL:
 782:             self.write_packet(data_init)
 783:             self._sock = self.ctx.wrap_socket(self._sock, server_hostname=self.host)
 784:             self._rfile = self._sock.makefile("rb")
 785:             self._secure = True
 786:         data = data_init + self.user + b"\0"
 787:         authresp = b""
 788:         plugin_name = None
 789:         if self._auth_plugin_name == "":
 790:             plugin_name = b""
 791:             authresp = _auth.scramble_native_password(self.password, self.salt)
 792:         elif self._auth_plugin_name == "mysql_native_password":
 793:             plugin_name = b"mysql_native_password"
 794:             authresp = _auth.scramble_native_password(self.password, self.salt)
 795:         elif self._auth_plugin_name == "caching_sha2_password":
 796:             plugin_name = b"caching_sha2_password"
 797:             if self.password:
 798:                 if DEBUG:
 799:                     print("caching_sha2: trying fast path")
 800:                 authresp = _auth.scramble_caching_sha2(self.password, self.salt)
 801:             else:
 802:                 if DEBUG:
 803:                     print("caching_sha2: empty password")
 804:         elif self._auth_plugin_name == "sha256_password":
 805:             plugin_name = b"sha256_password"
 806:             if self.ssl and self.server_capabilities & CLIENT.SSL:
 807:                 authresp = self.password + b"\0"
 808:             elif self.password:
 809:                 authresp = b"\1"  # request public key
 810:             else:
 811:                 authresp = b"\0"  # empty password
 812:         if self.server_capabilities & CLIENT.PLUGIN_AUTH_LENENC_CLIENT_DATA:
 813:             data += _lenenc_int(len(authresp)) + authresp
 814:         elif self.server_capabilities & CLIENT.SECURE_CONNECTION:
 815:             data += struct.pack("B", len(authresp)) + authresp
 816:         else:  # pragma: no cover - not testing against servers without secure auth (>=5.0)
 817:             data += authresp + b"\0"
 818:         if self.db and self.server_capabilities & CLIENT.CONNECT_WITH_DB:
 819:             if isinstance(self.db, str):
 820:                 self.db = self.db.encode(self.encoding)
 821:             data += self.db + b"\0"
 822:         if self.server_capabilities & CLIENT.PLUGIN_AUTH:
 823:             data += (plugin_name or b"") + b"\0"
 824:         if self.server_capabilities & CLIENT.CONNECT_ATTRS:
 825:             connect_attrs = b""
 826:             for k, v in self._connect_attrs.items():
 827:                 k = k.encode("utf-8")
 828:                 connect_attrs += _lenenc_int(len(k)) + k
 829:                 v = v.encode("utf-8")
 830:                 connect_attrs += _lenenc_int(len(v)) + v
 831:             data += _lenenc_int(len(connect_attrs)) + connect_attrs
 832:         self.write_packet(data)
 833:         auth_packet = self._read_packet()
 834:         # if authentication method isn't accepted the first byte
 835:         # will have the octet 254
 836:         if auth_packet.is_auth_switch_request():
 837:             if DEBUG:
 838:                 print("received auth switch")
 839:             # https://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::AuthSwitchRequest
 840:             auth_packet.read_uint8()  # 0xfe packet identifier
 841:             plugin_name = auth_packet.read_string()
 842:             if (
 843:                 self.server_capabilities & CLIENT.PLUGIN_AUTH
 844:                 and plugin_name is not None
 845:             ):
 846:                 auth_packet = self._process_auth(plugin_name, auth_packet)
 847:             else:
 848:                 raise err.OperationalError("received unknown auth switch request")
 849:         elif auth_packet.is_extra_auth_data():
 850:             if DEBUG:
 851:                 print("received extra data")
 852:             # https://dev.mysql.com/doc/internals/en/successful-authentication.html
 853:             if self._auth_plugin_name == "caching_sha2_password":
 854:                 auth_packet = _auth.caching_sha2_password_auth(self, auth_packet)
 855:             elif self._auth_plugin_name == "sha256_password":
 856:                 auth_packet = _auth.sha256_password_auth(self, auth_packet)
 857:             else:
 858:                 raise err.OperationalError(
 859:                     "Received extra packet for auth method %r", self._auth_plugin_name
 860:                 )
 861:         if DEBUG:
 862:             print("Succeed to auth")
 863:     def _process_auth(self, plugin_name, auth_packet):
 864:         handler = self._get_auth_plugin_handler(plugin_name)
 865:         if handler:
 866:             try:
 867:                 return handler.authenticate(auth_packet)
 868:             except AttributeError:
 869:                 if plugin_name != b"dialog":
 870:                     raise err.OperationalError(
 871:                         CR.CR_AUTH_PLUGIN_CANNOT_LOAD,
 872:                         f"Authentication plugin '{plugin_name}'"
 873:                         f" not loaded: - {type(handler)!r} missing authenticate method",
 874:                     )
 875:         if plugin_name == b"caching_sha2_password":
 876:             return _auth.caching_sha2_password_auth(self, auth_packet)
 877:         elif plugin_name == b"sha256_password":
 878:             return _auth.sha256_password_auth(self, auth_packet)
 879:         elif plugin_name == b"mysql_native_password":
 880:             data = _auth.scramble_native_password(self.password, auth_packet.read_all())
 881:         elif plugin_name == b"client_ed25519":
 882:             data = _auth.ed25519_password(self.password, auth_packet.read_all())
 883:         elif plugin_name == b"mysql_old_password":
 884:             data = (
 885:                 _auth.scramble_old_password(self.password, auth_packet.read_all())
 886:                 + b"\0"
 887:             )
 888:         elif plugin_name == b"mysql_clear_password":
 889:             # https://dev.mysql.com/doc/internals/en/clear-text-authentication.html
 890:             data = self.password + b"\0"
 891:         elif plugin_name == b"dialog":
 892:             pkt = auth_packet
 893:             while True:
 894:                 flag = pkt.read_uint8()
 895:                 echo = (flag & 0x06) == 0x02
 896:                 last = (flag & 0x01) == 0x01
 897:                 prompt = pkt.read_all()
 898:                 if prompt == b"Password: ":
 899:                     self.write_packet(self.password + b"\0")
 900:                 elif handler:
 901:                     resp = "no response - TypeError within plugin.prompt method"
 902:                     try:
 903:                         resp = handler.prompt(echo, prompt)
 904:                         self.write_packet(resp + b"\0")
 905:                     except AttributeError:
 906:                         raise err.OperationalError(
 907:                             CR.CR_AUTH_PLUGIN_CANNOT_LOAD,
 908:                             f"Authentication plugin '{plugin_name}'"
 909:                             f" not loaded: - {handler!r} missing prompt method",
 910:                         )
 911:                     except TypeError:
 912:                         raise err.OperationalError(
 913:                             CR.CR_AUTH_PLUGIN_ERR,
 914:                             f"Authentication plugin '{plugin_name}'"
 915:                             f" {handler!r} didn't respond with string. Returned '{resp!r}' to prompt {prompt!r}",
 916:                         )
 917:                 else:
 918:                     raise err.OperationalError(
 919:                         CR.CR_AUTH_PLUGIN_CANNOT_LOAD,
 920:                         f"Authentication plugin '{plugin_name}' not configured",
 921:                     )
 922:                 pkt = self._read_packet()
 923:                 pkt.check_error()
 924:                 if pkt.is_ok_packet() or last:
 925:                     break
 926:             return pkt
 927:         else:
 928:             raise err.OperationalError(
 929:                 CR.CR_AUTH_PLUGIN_CANNOT_LOAD,
 930:                 "Authentication plugin '%s' not configured" % plugin_name,
 931:             )
 932:         self.write_packet(data)
 933:         pkt = self._read_packet()
 934:         pkt.check_error()
 935:         return pkt
 936:     def _get_auth_plugin_handler(self, plugin_name):
 937:         plugin_class = self._auth_plugin_map.get(plugin_name)
 938:         if not plugin_class and isinstance(plugin_name, bytes):
 939:             plugin_class = self._auth_plugin_map.get(plugin_name.decode("ascii"))
 940:         if plugin_class:
 941:             try:
 942:                 handler = plugin_class(self)
 943:             except TypeError:
 944:                 raise err.OperationalError(
 945:                     CR.CR_AUTH_PLUGIN_CANNOT_LOAD,
 946:                     f"Authentication plugin '{plugin_name}'"
 947:                     f" not loaded: - {plugin_class!r} cannot be constructed with connection object",
 948:                 )
 949:         else:
 950:             handler = None
 951:         return handler
 952:     # _mysql support
 953:     def thread_id(self):
 954:         return self.server_thread_id[0]
 955:     def character_set_name(self):
 956:         return self.charset
 957:     def get_host_info(self):
 958:         return self.host_info
 959:     def get_proto_info(self):
 960:         return self.protocol_version
 961:     def _get_server_information(self):
 962:         i = 0
 963:         packet = self._read_packet()
 964:         data = packet.get_all_data()
 965:         self.protocol_version = data[i]
 966:         i += 1
 967:         server_end = data.find(b"\0", i)
 968:         self.server_version = data[i:server_end].decode("latin1")
 969:         i = server_end + 1
 970:         self.server_thread_id = struct.unpack("<I", data[i : i + 4])
 971:         i += 4
 972:         self.salt = data[i : i + 8]
 973:         i += 9  # 8 + 1(filler)
 974:         self.server_capabilities = struct.unpack("<H", data[i : i + 2])[0]
 975:         i += 2
 976:         if len(data) >= i + 6:
 977:             lang, stat, cap_h, salt_len = struct.unpack("<BHHB", data[i : i + 6])
 978:             i += 6
 979:             # TODO: deprecate server_language and server_charset.
 980:             # mysqlclient-python doesn't provide it.
 981:             self.server_language = lang
 982:             try:
 983:                 self.server_charset = charset_by_id(lang).name
 984:             except KeyError:
 985:                 # unknown collation
 986:                 self.server_charset = None
 987:             self.server_status = stat
 988:             if DEBUG:
 989:                 print("server_status: %x" % stat)
 990:             self.server_capabilities |= cap_h << 16
 991:             if DEBUG:
 992:                 print("salt_len:", salt_len)
 993:             salt_len = max(12, salt_len - 9)
 994:         # reserved
 995:         i += 10
 996:         if len(data) >= i + salt_len:
 997:             # salt_len includes auth_plugin_data_part_1 and filler
 998:             self.salt += data[i : i + salt_len]
 999:             i += salt_len
1000:         i += 1
1001:         # AUTH PLUGIN NAME may appear here.
1002:         if self.server_capabilities & CLIENT.PLUGIN_AUTH and len(data) >= i:
1003:             # Due to Bug#59453 the auth-plugin-name is missing the terminating
1004:             # NUL-char in versions prior to 5.5.10 and 5.6.2.
1005:             # ref: https://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::Handshake
1006:             # didn't use version checks as mariadb is corrected and reports
1007:             # earlier than those two.
1008:             server_end = data.find(b"\0", i)
1009:             if server_end < 0:  # pragma: no cover - very specific upstream bug
1010:                 # not found \0 and last field so take it all
1011:                 self._auth_plugin_name = data[i:].decode("utf-8")
1012:             else:
1013:                 self._auth_plugin_name = data[i:server_end].decode("utf-8")
1014:     def get_server_info(self):
1015:         return self.server_version
1016:     Warning = err.Warning
1017:     Error = err.Error
1018:     InterfaceError = err.InterfaceError
1019:     DatabaseError = err.DatabaseError
1020:     DataError = err.DataError
1021:     OperationalError = err.OperationalError
1022:     IntegrityError = err.IntegrityError
1023:     InternalError = err.InternalError
1024:     ProgrammingError = err.ProgrammingError
1025:     NotSupportedError = err.NotSupportedError
1026: class MySQLResult:
1027:     def __init__(self, connection):
1028:         """
1029:         :type connection: Connection
1030:         """
1031:         self.connection = connection
1032:         self.affected_rows = None
1033:         self.insert_id = None
1034:         self.server_status = None
1035:         self.warning_count = 0
1036:         self.message = None
1037:         self.field_count = 0
1038:         self.description = None
1039:         self.rows = None
1040:         self.has_next = None
1041:         self.unbuffered_active = False
1042:     def __del__(self):
1043:         if self.unbuffered_active:
1044:             self._finish_unbuffered_query()
1045:     def read(self):
1046:         try:
1047:             first_packet = self.connection._read_packet()
1048:             if first_packet.is_ok_packet():
1049:                 self._read_ok_packet(first_packet)
1050:             elif first_packet.is_load_local_packet():
1051:                 self._read_load_local_packet(first_packet)
1052:             else:
1053:                 self._read_result_packet(first_packet)
1054:         finally:
1055:             self.connection = None
1056:     def init_unbuffered_query(self):
1057:         """
1058:         :raise OperationalError: If the connection to the MySQL server is lost.
1059:         :raise InternalError:
1060:         """
1061:         self.unbuffered_active = True
1062:         first_packet = self.connection._read_packet()
1063:         if first_packet.is_ok_packet():
1064:             self._read_ok_packet(first_packet)
1065:             self.unbuffered_active = False
1066:             self.connection = None
1067:         elif first_packet.is_load_local_packet():
1068:             self._read_load_local_packet(first_packet)
1069:             self.unbuffered_active = False
1070:             self.connection = None
1071:         else:
1072:             self.field_count = first_packet.read_length_encoded_integer()
1073:             self._get_descriptions()
1074:             # Apparently, MySQLdb picks this number because it's the maximum
1075:             # value of a 64bit unsigned integer. Since we're emulating MySQLdb,
1076:             # we set it to this instead of None, which would be preferred.
1077:             self.affected_rows = 18446744073709551615
1078:     def _read_ok_packet(self, first_packet):
1079:         ok_packet = OKPacketWrapper(first_packet)
1080:         self.affected_rows = ok_packet.affected_rows
1081:         self.insert_id = ok_packet.insert_id
1082:         self.server_status = ok_packet.server_status
1083:         self.warning_count = ok_packet.warning_count
1084:         self.message = ok_packet.message
1085:         self.has_next = ok_packet.has_next
1086:     def _read_load_local_packet(self, first_packet):
1087:         if not self.connection._local_infile:
1088:             raise RuntimeError(
1089:                 "**WARN**: Received LOAD_LOCAL packet but local_infile option is false."
1090:             )
1091:         load_packet = LoadLocalPacketWrapper(first_packet)
1092:         sender = LoadLocalFile(load_packet.filename, self.connection)
1093:         try:
1094:             sender.send_data()
1095:         except:
1096:             self.connection._read_packet()  # skip ok packet
1097:             raise
1098:         ok_packet = self.connection._read_packet()
1099:         if (
1100:             not ok_packet.is_ok_packet()
1101:         ):  # pragma: no cover - upstream induced protocol error
1102:             raise err.OperationalError(
1103:                 CR.CR_COMMANDS_OUT_OF_SYNC,
1104:                 "Commands Out of Sync",
1105:             )
1106:         self._read_ok_packet(ok_packet)
1107:     def _check_packet_is_eof(self, packet):
1108:         if not packet.is_eof_packet():
1109:             return False
1110:         # TODO: Support CLIENT.DEPRECATE_EOF
1111:         # 1) Add DEPRECATE_EOF to CAPABILITIES
1112:         # 2) Mask CAPABILITIES with server_capabilities
1113:         # 3) if server_capabilities & CLIENT.DEPRECATE_EOF:
1114:         #    use OKPacketWrapper instead of EOFPacketWrapper
1115:         wp = EOFPacketWrapper(packet)
1116:         self.warning_count = wp.warning_count
1117:         self.has_next = wp.has_next
1118:         return True
1119:     def _read_result_packet(self, first_packet):
1120:         self.field_count = first_packet.read_length_encoded_integer()
1121:         self._get_descriptions()
1122:         self._read_rowdata_packet()
1123:     def _read_rowdata_packet_unbuffered(self):
1124:         # Check if in an active query
1125:         if not self.unbuffered_active:
1126:             return
1127:         # EOF
1128:         packet = self.connection._read_packet()
1129:         if self._check_packet_is_eof(packet):
1130:             self.unbuffered_active = False
1131:             self.connection = None
1132:             self.rows = None
1133:             return
1134:         row = self._read_row_from_packet(packet)
1135:         self.affected_rows = 1
1136:         self.rows = (row,)  # rows should tuple of row for MySQL-python compatibility.
1137:         return row
1138:     def _finish_unbuffered_query(self):
1139:         # After much reading on the MySQL protocol, it appears that there is,
1140:         # in fact, no way to stop MySQL from sending all the data after
1141:         # executing a query, so we just spin, and wait for an EOF packet.
1142:         while self.unbuffered_active:
1143:             try:
1144:                 packet = self.connection._read_packet()
1145:             except err.OperationalError as e:
1146:                 if e.args[0] in (
1147:                     ER.QUERY_TIMEOUT,
1148:                     ER.STATEMENT_TIMEOUT,
1149:                 ):
1150:                     # if the query timed out we can simply ignore this error
1151:                     self.unbuffered_active = False
1152:                     self.connection = None
1153:                     return
1154:                 raise
1155:             if self._check_packet_is_eof(packet):
1156:                 self.unbuffered_active = False
1157:                 self.connection = None  # release reference to kill cyclic reference.
1158:     def _read_rowdata_packet(self):
1159:         """Read a rowdata packet for each data row in the result set."""
1160:         rows = []
1161:         while True:
1162:             packet = self.connection._read_packet()
1163:             if self._check_packet_is_eof(packet):
1164:                 self.connection = None  # release reference to kill cyclic reference.
1165:                 break
1166:             rows.append(self._read_row_from_packet(packet))
1167:         self.affected_rows = len(rows)
1168:         self.rows = tuple(rows)
1169:     def _read_row_from_packet(self, packet):
1170:         row = []
1171:         for encoding, converter in self.converters:
1172:             try:
1173:                 data = packet.read_length_coded_string()
1174:             except IndexError:
1175:                 # No more columns in this row
1176:                 # See https://github.com/PyMySQL/PyMySQL/pull/434
1177:                 break
1178:             if data is not None:
1179:                 if encoding is not None:
1180:                     data = data.decode(encoding)
1181:                 if DEBUG:
1182:                     print("DEBUG: DATA = ", data)
1183:                 if converter is not None:
1184:                     data = converter(data)
1185:             row.append(data)
1186:         return tuple(row)
1187:     def _get_descriptions(self):
1188:         """Read a column descriptor packet for each column in the result."""
1189:         self.fields = []
1190:         self.converters = []
1191:         use_unicode = self.connection.use_unicode
1192:         conn_encoding = self.connection.encoding
1193:         description = []
1194:         for i in range(self.field_count):
1195:             field = self.connection._read_packet(FieldDescriptorPacket)
1196:             self.fields.append(field)
1197:             description.append(field.description())
1198:             field_type = field.type_code
1199:             if use_unicode:
1200:                 if field_type == FIELD_TYPE.JSON:
1201:                     # When SELECT from JSON column: charset = binary
1202:                     # When SELECT CAST(... AS JSON): charset = connection encoding
1203:                     # This behavior is different from TEXT / BLOB.
1204:                     # We should decode result by connection encoding regardless charsetnr.
1205:                     # See https://github.com/PyMySQL/PyMySQL/issues/488
1206:                     encoding = conn_encoding  # SELECT CAST(... AS JSON)
1207:                 elif field_type in TEXT_TYPES:
1208:                     if field.charsetnr == 63:  # binary
1209:                         # TEXTs with charset=binary means BINARY types.
1210:                         encoding = None
1211:                     else:
1212:                         encoding = conn_encoding
1213:                 else:
1214:                     # Integers, Dates and Times, and other basic data is encoded in ascii
1215:                     encoding = "ascii"
1216:             else:
1217:                 encoding = None
1218:             converter = self.connection.decoders.get(field_type)
1219:             if converter is converters.through:
1220:                 converter = None
1221:             if DEBUG:
1222:                 print(f"DEBUG: field={field}, converter={converter}")
1223:             self.converters.append((encoding, converter))
1224:         eof_packet = self.connection._read_packet()
1225:         assert eof_packet.is_eof_packet(), "Protocol error, expecting EOF"
1226:         self.description = tuple(description)
1227: class LoadLocalFile:
1228:     def __init__(self, filename, connection):
1229:         self.filename = filename
1230:         self.connection = connection
1231:     def send_data(self):
1232:         """Send data packets from the local file to the server"""
1233:         if not self.connection._sock:
1234:             raise err.InterfaceError(0, "")
1235:         conn: Connection = self.connection
1236:         try:
1237:             with open(self.filename, "rb") as open_file:
1238:                 packet_size = min(
1239:                     conn.max_allowed_packet, 16 * 1024
1240:                 )  # 16KB is efficient enough
1241:                 while True:
1242:                     chunk = open_file.read(packet_size)
1243:                     if not chunk:
1244:                         break
1245:                     conn.write_packet(chunk)
1246:         except OSError:
1247:             raise err.OperationalError(
1248:                 ER.FILE_NOT_FOUND,
1249:                 f"Can't find file '{self.filename}'",
1250:             )
1251:         finally:
1252:             if not conn._closed:
1253:                 # send the empty packet to signify we are done sending data
1254:                 conn.write_packet(b"")
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/converters.py
````python
  1: import datetime
  2: from decimal import Decimal
  3: import re
  4: import time
  5: from .err import ProgrammingError
  6: from .constants import FIELD_TYPE
  7: def escape_item(val, charset, mapping=None):
  8:     if mapping is None:
  9:         mapping = encoders
 10:     encoder = mapping.get(type(val))
 11:     # Fallback to default when no encoder found
 12:     if not encoder:
 13:         try:
 14:             encoder = mapping[str]
 15:         except KeyError:
 16:             raise TypeError("no default type converter defined")
 17:     if encoder in (escape_dict, escape_sequence):
 18:         val = encoder(val, charset, mapping)
 19:     else:
 20:         val = encoder(val, mapping)
 21:     return val
 22: def escape_dict(val, charset, mapping=None):
 23:     raise TypeError("dict can not be used as parameter")
 24: def escape_sequence(val, charset, mapping=None):
 25:     n = []
 26:     for item in val:
 27:         quoted = escape_item(item, charset, mapping)
 28:         n.append(quoted)
 29:     return "(" + ",".join(n) + ")"
 30: def escape_set(val, charset, mapping=None):
 31:     return ",".join([escape_item(x, charset, mapping) for x in val])
 32: def escape_bool(value, mapping=None):
 33:     return str(int(value))
 34: def escape_int(value, mapping=None):
 35:     return str(value)
 36: def escape_float(value, mapping=None):
 37:     s = repr(value)
 38:     if s in ("inf", "-inf", "nan"):
 39:         raise ProgrammingError("%s can not be used with MySQL" % s)
 40:     if "e" not in s:
 41:         s += "e0"
 42:     return s
 43: _escape_table = [chr(x) for x in range(128)]
 44: _escape_table[0] = "\\0"
 45: _escape_table[ord("\\")] = "\\\\"
 46: _escape_table[ord("\n")] = "\\n"
 47: _escape_table[ord("\r")] = "\\r"
 48: _escape_table[ord("\032")] = "\\Z"
 49: _escape_table[ord('"')] = '\\"'
 50: _escape_table[ord("'")] = "\\'"
 51: def escape_string(value, mapping=None):
 52:     """escapes *value* without adding quote.
 53:     Value should be unicode
 54:     """
 55:     return value.translate(_escape_table)
 56: def escape_bytes_prefixed(value, mapping=None):
 57:     return "_binary'%s'" % value.decode("ascii", "surrogateescape").translate(
 58:         _escape_table
 59:     )
 60: def escape_bytes(value, mapping=None):
 61:     return "'%s'" % value.decode("ascii", "surrogateescape").translate(_escape_table)
 62: def escape_str(value, mapping=None):
 63:     return "'%s'" % escape_string(str(value), mapping)
 64: def escape_None(value, mapping=None):
 65:     return "NULL"
 66: def escape_timedelta(obj, mapping=None):
 67:     seconds = int(obj.seconds) % 60
 68:     minutes = int(obj.seconds // 60) % 60
 69:     hours = int(obj.seconds // 3600) % 24 + int(obj.days) * 24
 70:     if obj.microseconds:
 71:         fmt = "'{0:02d}:{1:02d}:{2:02d}.{3:06d}'"
 72:     else:
 73:         fmt = "'{0:02d}:{1:02d}:{2:02d}'"
 74:     return fmt.format(hours, minutes, seconds, obj.microseconds)
 75: def escape_time(obj, mapping=None):
 76:     if obj.microsecond:
 77:         fmt = "'{0.hour:02}:{0.minute:02}:{0.second:02}.{0.microsecond:06}'"
 78:     else:
 79:         fmt = "'{0.hour:02}:{0.minute:02}:{0.second:02}'"
 80:     return fmt.format(obj)
 81: def escape_datetime(obj, mapping=None):
 82:     if obj.microsecond:
 83:         fmt = (
 84:             "'{0.year:04}-{0.month:02}-{0.day:02}"
 85:             + " {0.hour:02}:{0.minute:02}:{0.second:02}.{0.microsecond:06}'"
 86:         )
 87:     else:
 88:         fmt = "'{0.year:04}-{0.month:02}-{0.day:02} {0.hour:02}:{0.minute:02}:{0.second:02}'"
 89:     return fmt.format(obj)
 90: def escape_date(obj, mapping=None):
 91:     fmt = "'{0.year:04}-{0.month:02}-{0.day:02}'"
 92:     return fmt.format(obj)
 93: def escape_struct_time(obj, mapping=None):
 94:     return escape_datetime(datetime.datetime(*obj[:6]))
 95: def Decimal2Literal(o, d):
 96:     return format(o, "f")
 97: def _convert_second_fraction(s):
 98:     if not s:
 99:         return 0
100:     # Pad zeros to ensure the fraction length in microseconds
101:     s = s.ljust(6, "0")
102:     return int(s[:6])
103: DATETIME_RE = re.compile(
104:     r"(\d{1,4})-(\d{1,2})-(\d{1,2})[T ](\d{1,2}):(\d{1,2}):(\d{1,2})(?:.(\d{1,6}))?"
105: )
106: def convert_datetime(obj):
107:     """Returns a DATETIME or TIMESTAMP column value as a datetime object:
108:       >>> convert_datetime('2007-02-25 23:06:20')
109:       datetime.datetime(2007, 2, 25, 23, 6, 20)
110:       >>> convert_datetime('2007-02-25T23:06:20')
111:       datetime.datetime(2007, 2, 25, 23, 6, 20)
112:     Illegal values are returned as str:
113:       >>> convert_datetime('2007-02-31T23:06:20')
114:       '2007-02-31T23:06:20'
115:       >>> convert_datetime('0000-00-00 00:00:00')
116:       '0000-00-00 00:00:00'
117:     """
118:     if isinstance(obj, (bytes, bytearray)):
119:         obj = obj.decode("ascii")
120:     m = DATETIME_RE.match(obj)
121:     if not m:
122:         return convert_date(obj)
123:     try:
124:         groups = list(m.groups())
125:         groups[-1] = _convert_second_fraction(groups[-1])
126:         return datetime.datetime(*[int(x) for x in groups])
127:     except ValueError:
128:         return convert_date(obj)
129: TIMEDELTA_RE = re.compile(r"(-)?(\d{1,3}):(\d{1,2}):(\d{1,2})(?:.(\d{1,6}))?")
130: def convert_timedelta(obj):
131:     """Returns a TIME column as a timedelta object:
132:       >>> convert_timedelta('25:06:17')
133:       datetime.timedelta(days=1, seconds=3977)
134:       >>> convert_timedelta('-25:06:17')
135:       datetime.timedelta(days=-2, seconds=82423)
136:     Illegal values are returned as string:
137:       >>> convert_timedelta('random crap')
138:       'random crap'
139:     Note that MySQL always returns TIME columns as (+|-)HH:MM:SS, but
140:     can accept values as (+|-)DD HH:MM:SS. The latter format will not
141:     be parsed correctly by this function.
142:     """
143:     if isinstance(obj, (bytes, bytearray)):
144:         obj = obj.decode("ascii")
145:     m = TIMEDELTA_RE.match(obj)
146:     if not m:
147:         return obj
148:     try:
149:         groups = list(m.groups())
150:         groups[-1] = _convert_second_fraction(groups[-1])
151:         negate = -1 if groups[0] else 1
152:         hours, minutes, seconds, microseconds = groups[1:]
153:         tdelta = (
154:             datetime.timedelta(
155:                 hours=int(hours),
156:                 minutes=int(minutes),
157:                 seconds=int(seconds),
158:                 microseconds=int(microseconds),
159:             )
160:             * negate
161:         )
162:         return tdelta
163:     except ValueError:
164:         return obj
165: TIME_RE = re.compile(r"(\d{1,2}):(\d{1,2}):(\d{1,2})(?:.(\d{1,6}))?")
166: def convert_time(obj):
167:     """Returns a TIME column as a time object:
168:       >>> convert_time('15:06:17')
169:       datetime.time(15, 6, 17)
170:     Illegal values are returned as str:
171:       >>> convert_time('-25:06:17')
172:       '-25:06:17'
173:       >>> convert_time('random crap')
174:       'random crap'
175:     Note that MySQL always returns TIME columns as (+|-)HH:MM:SS, but
176:     can accept values as (+|-)DD HH:MM:SS. The latter format will not
177:     be parsed correctly by this function.
178:     Also note that MySQL's TIME column corresponds more closely to
179:     Python's timedelta and not time. However if you want TIME columns
180:     to be treated as time-of-day and not a time offset, then you can
181:     use set this function as the converter for FIELD_TYPE.TIME.
182:     """
183:     if isinstance(obj, (bytes, bytearray)):
184:         obj = obj.decode("ascii")
185:     m = TIME_RE.match(obj)
186:     if not m:
187:         return obj
188:     try:
189:         groups = list(m.groups())
190:         groups[-1] = _convert_second_fraction(groups[-1])
191:         hours, minutes, seconds, microseconds = groups
192:         return datetime.time(
193:             hour=int(hours),
194:             minute=int(minutes),
195:             second=int(seconds),
196:             microsecond=int(microseconds),
197:         )
198:     except ValueError:
199:         return obj
200: def convert_date(obj):
201:     """Returns a DATE column as a date object:
202:       >>> convert_date('2007-02-26')
203:       datetime.date(2007, 2, 26)
204:     Illegal values are returned as str:
205:       >>> convert_date('2007-02-31')
206:       '2007-02-31'
207:       >>> convert_date('0000-00-00')
208:       '0000-00-00'
209:     """
210:     if isinstance(obj, (bytes, bytearray)):
211:         obj = obj.decode("ascii")
212:     try:
213:         return datetime.date(*[int(x) for x in obj.split("-", 2)])
214:     except ValueError:
215:         return obj
216: def through(x):
217:     return x
218: # def convert_bit(b):
219: #    b = "\x00" * (8 - len(b)) + b # pad w/ zeroes
220: #    return struct.unpack(">Q", b)[0]
221: #
222: #     the snippet above is right, but MySQLdb doesn't process bits,
223: #     so we shouldn't either
224: convert_bit = through
225: encoders = {
226:     bool: escape_bool,
227:     int: escape_int,
228:     float: escape_float,
229:     str: escape_str,
230:     bytes: escape_bytes,
231:     tuple: escape_sequence,
232:     list: escape_sequence,
233:     set: escape_sequence,
234:     frozenset: escape_sequence,
235:     dict: escape_dict,
236:     type(None): escape_None,
237:     datetime.date: escape_date,
238:     datetime.datetime: escape_datetime,
239:     datetime.timedelta: escape_timedelta,
240:     datetime.time: escape_time,
241:     time.struct_time: escape_struct_time,
242:     Decimal: Decimal2Literal,
243: }
244: decoders = {
245:     FIELD_TYPE.BIT: convert_bit,
246:     FIELD_TYPE.TINY: int,
247:     FIELD_TYPE.SHORT: int,
248:     FIELD_TYPE.LONG: int,
249:     FIELD_TYPE.FLOAT: float,
250:     FIELD_TYPE.DOUBLE: float,
251:     FIELD_TYPE.LONGLONG: int,
252:     FIELD_TYPE.INT24: int,
253:     FIELD_TYPE.YEAR: int,
254:     FIELD_TYPE.TIMESTAMP: convert_datetime,
255:     FIELD_TYPE.DATETIME: convert_datetime,
256:     FIELD_TYPE.TIME: convert_timedelta,
257:     FIELD_TYPE.DATE: convert_date,
258:     FIELD_TYPE.BLOB: through,
259:     FIELD_TYPE.TINY_BLOB: through,
260:     FIELD_TYPE.MEDIUM_BLOB: through,
261:     FIELD_TYPE.LONG_BLOB: through,
262:     FIELD_TYPE.STRING: through,
263:     FIELD_TYPE.VAR_STRING: through,
264:     FIELD_TYPE.VARCHAR: through,
265:     FIELD_TYPE.DECIMAL: Decimal,
266:     FIELD_TYPE.NEWDECIMAL: Decimal,
267: }
268: # for MySQLdb compatibility
269: conversions = encoders.copy()
270: conversions.update(decoders)
271: Thing2Literal = escape_str
272: # Run doctests with `pytest --doctest-modules pymysql/converters.py`
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/cursors.py
````python
  1: import re
  2: import warnings
  3: from . import err
  4: #: Regular expression for :meth:`Cursor.executemany`.
  5: #: executemany only supports simple bulk insert.
  6: #: You can use it to load large dataset.
  7: RE_INSERT_VALUES = re.compile(
  8:     r"\s*((?:INSERT|REPLACE)\b.+\bVALUES?\s*)"
  9:     + r"(\(\s*(?:%s|%\(.+\)s)\s*(?:,\s*(?:%s|%\(.+\)s)\s*)*\))"
 10:     + r"(\s*(?:ON DUPLICATE.*)?);?\s*\Z",
 11:     re.IGNORECASE | re.DOTALL,
 12: )
 13: class Cursor:
 14:     """
 15:     This is the object used to interact with the database.
 16:     Do not create an instance of a Cursor yourself. Call
 17:     connections.Connection.cursor().
 18:     See `Cursor <https://www.python.org/dev/peps/pep-0249/#cursor-objects>`_ in
 19:     the specification.
 20:     """
 21:     #: Max statement size which :meth:`executemany` generates.
 22:     #:
 23:     #: Max size of allowed statement is max_allowed_packet - packet_header_size.
 24:     #: Default value of max_allowed_packet is 1048576.
 25:     max_stmt_length = 1024000
 26:     def __init__(self, connection):
 27:         self.connection = connection
 28:         self.warning_count = 0
 29:         self.description = None
 30:         self.rownumber = 0
 31:         self.rowcount = -1
 32:         self.arraysize = 1
 33:         self._executed = None
 34:         self._result = None
 35:         self._rows = None
 36:     def close(self):
 37:         """
 38:         Closing a cursor just exhausts all remaining data.
 39:         """
 40:         conn = self.connection
 41:         if conn is None:
 42:             return
 43:         try:
 44:             while self.nextset():
 45:                 pass
 46:         finally:
 47:             self.connection = None
 48:     def __enter__(self):
 49:         return self
 50:     def __exit__(self, *exc_info):
 51:         del exc_info
 52:         self.close()
 53:     def _get_db(self):
 54:         if not self.connection:
 55:             raise err.ProgrammingError("Cursor closed")
 56:         return self.connection
 57:     def _check_executed(self):
 58:         if not self._executed:
 59:             raise err.ProgrammingError("execute() first")
 60:     def _conv_row(self, row):
 61:         return row
 62:     def setinputsizes(self, *args):
 63:         """Does nothing, required by DB API."""
 64:     def setoutputsizes(self, *args):
 65:         """Does nothing, required by DB API."""
 66:     def _nextset(self, unbuffered=False):
 67:         """Get the next query set."""
 68:         conn = self._get_db()
 69:         current_result = self._result
 70:         if current_result is None or current_result is not conn._result:
 71:             return None
 72:         if not current_result.has_next:
 73:             return None
 74:         self._result = None
 75:         self._clear_result()
 76:         conn.next_result(unbuffered=unbuffered)
 77:         self._do_get_result()
 78:         return True
 79:     def nextset(self):
 80:         return self._nextset(False)
 81:     def _escape_args(self, args, conn):
 82:         if isinstance(args, (tuple, list)):
 83:             return tuple(conn.literal(arg) for arg in args)
 84:         elif isinstance(args, dict):
 85:             return {key: conn.literal(val) for (key, val) in args.items()}
 86:         else:
 87:             # If it's not a dictionary let's try escaping it anyways.
 88:             # Worst case it will throw a Value error
 89:             return conn.escape(args)
 90:     def mogrify(self, query, args=None):
 91:         """
 92:         Returns the exact string that would be sent to the database by calling the
 93:         execute() method.
 94:         :param query: Query to mogrify.
 95:         :type query: str
 96:         :param args: Parameters used with query. (optional)
 97:         :type args: tuple, list or dict
 98:         :return: The query with argument binding applied.
 99:         :rtype: str
100:         This method follows the extension to the DB API 2.0 followed by Psycopg.
101:         """
102:         conn = self._get_db()
103:         if args is not None:
104:             query = query % self._escape_args(args, conn)
105:         return query
106:     def execute(self, query, args=None):
107:         """Execute a query.
108:         :param query: Query to execute.
109:         :type query: str
110:         :param args: Parameters used with query. (optional)
111:         :type args: tuple, list or dict
112:         :return: Number of affected rows.
113:         :rtype: int
114:         If args is a list or tuple, %s can be used as a placeholder in the query.
115:         If args is a dict, %(name)s can be used as a placeholder in the query.
116:         """
117:         while self.nextset():
118:             pass
119:         query = self.mogrify(query, args)
120:         result = self._query(query)
121:         self._executed = query
122:         return result
123:     def executemany(self, query, args):
124:         """Run several data against one query.
125:         :param query: Query to execute.
126:         :type query: str
127:         :param args: Sequence of sequences or mappings. It is used as parameter.
128:         :type args: tuple or list
129:         :return: Number of rows affected, if any.
130:         :rtype: int or None
131:         This method improves performance on multiple-row INSERT and
132:         REPLACE. Otherwise it is equivalent to looping over args with
133:         execute().
134:         """
135:         if not args:
136:             return
137:         m = RE_INSERT_VALUES.match(query)
138:         if m:
139:             q_prefix = m.group(1) % ()
140:             q_values = m.group(2).rstrip()
141:             q_postfix = m.group(3) or ""
142:             assert q_values[0] == "(" and q_values[-1] == ")"
143:             return self._do_execute_many(
144:                 q_prefix,
145:                 q_values,
146:                 q_postfix,
147:                 args,
148:                 self.max_stmt_length,
149:                 self._get_db().encoding,
150:             )
151:         self.rowcount = sum(self.execute(query, arg) for arg in args)
152:         return self.rowcount
153:     def _do_execute_many(
154:         self, prefix, values, postfix, args, max_stmt_length, encoding
155:     ):
156:         conn = self._get_db()
157:         escape = self._escape_args
158:         if isinstance(prefix, str):
159:             prefix = prefix.encode(encoding)
160:         if isinstance(postfix, str):
161:             postfix = postfix.encode(encoding)
162:         sql = bytearray(prefix)
163:         args = iter(args)
164:         v = values % escape(next(args), conn)
165:         if isinstance(v, str):
166:             v = v.encode(encoding, "surrogateescape")
167:         sql += v
168:         rows = 0
169:         for arg in args:
170:             v = values % escape(arg, conn)
171:             if isinstance(v, str):
172:                 v = v.encode(encoding, "surrogateescape")
173:             if len(sql) + len(v) + len(postfix) + 1 > max_stmt_length:
174:                 rows += self.execute(sql + postfix)
175:                 sql = bytearray(prefix)
176:             else:
177:                 sql += b","
178:             sql += v
179:         rows += self.execute(sql + postfix)
180:         self.rowcount = rows
181:         return rows
182:     def callproc(self, procname, args=()):
183:         """Execute stored procedure procname with args.
184:         :param procname: Name of procedure to execute on server.
185:         :type procname: str
186:         :param args: Sequence of parameters to use with procedure.
187:         :type args: tuple or list
188:         Returns the original args.
189:         Compatibility warning: PEP-249 specifies that any modified
190:         parameters must be returned. This is currently impossible
191:         as they are only available by storing them in a server
192:         variable and then retrieved by a query. Since stored
193:         procedures return zero or more result sets, there is no
194:         reliable way to get at OUT or INOUT parameters via callproc.
195:         The server variables are named @_procname_n, where procname
196:         is the parameter above and n is the position of the parameter
197:         (from zero). Once all result sets generated by the procedure
198:         have been fetched, you can issue a SELECT @_procname_0, ...
199:         query using .execute() to get any OUT or INOUT values.
200:         Compatibility warning: The act of calling a stored procedure
201:         itself creates an empty result set. This appears after any
202:         result sets generated by the procedure. This is non-standard
203:         behavior with respect to the DB-API. Be sure to use nextset()
204:         to advance through all result sets; otherwise you may get
205:         disconnected.
206:         """
207:         conn = self._get_db()
208:         if args:
209:             fmt = f"@_{procname}_%d=%s"
210:             self._query(
211:                 "SET %s"
212:                 % ",".join(
213:                     fmt % (index, conn.escape(arg)) for index, arg in enumerate(args)
214:                 )
215:             )
216:             self.nextset()
217:         q = "CALL {}({})".format(
218:             procname,
219:             ",".join(["@_%s_%d" % (procname, i) for i in range(len(args))]),
220:         )
221:         self._query(q)
222:         self._executed = q
223:         return args
224:     def fetchone(self):
225:         """Fetch the next row."""
226:         self._check_executed()
227:         if self._rows is None or self.rownumber >= len(self._rows):
228:             return None
229:         result = self._rows[self.rownumber]
230:         self.rownumber += 1
231:         return result
232:     def fetchmany(self, size=None):
233:         """Fetch several rows."""
234:         self._check_executed()
235:         if self._rows is None:
236:             # Django expects () for EOF.
237:             # https://github.com/django/django/blob/0c1518ee429b01c145cf5b34eab01b0b92f8c246/django/db/backends/mysql/features.py#L8
238:             return ()
239:         end = self.rownumber + (size or self.arraysize)
240:         result = self._rows[self.rownumber : end]
241:         self.rownumber = min(end, len(self._rows))
242:         return result
243:     def fetchall(self):
244:         """Fetch all the rows."""
245:         self._check_executed()
246:         if self._rows is None:
247:             return []
248:         if self.rownumber:
249:             result = self._rows[self.rownumber :]
250:         else:
251:             result = self._rows
252:         self.rownumber = len(self._rows)
253:         return result
254:     def scroll(self, value, mode="relative"):
255:         self._check_executed()
256:         if mode == "relative":
257:             r = self.rownumber + value
258:         elif mode == "absolute":
259:             r = value
260:         else:
261:             raise err.ProgrammingError("unknown scroll mode %s" % mode)
262:         if not (0 <= r < len(self._rows)):
263:             raise IndexError("out of range")
264:         self.rownumber = r
265:     def _query(self, q):
266:         conn = self._get_db()
267:         self._clear_result()
268:         conn.query(q)
269:         self._do_get_result()
270:         return self.rowcount
271:     def _clear_result(self):
272:         self.rownumber = 0
273:         self._result = None
274:         self.rowcount = 0
275:         self.warning_count = 0
276:         self.description = None
277:         self.lastrowid = None
278:         self._rows = None
279:     def _do_get_result(self):
280:         conn = self._get_db()
281:         self._result = result = conn._result
282:         self.rowcount = result.affected_rows
283:         self.warning_count = result.warning_count
284:         self.description = result.description
285:         self.lastrowid = result.insert_id
286:         self._rows = result.rows
287:     def __iter__(self):
288:         return self
289:     def __next__(self):
290:         row = self.fetchone()
291:         if row is None:
292:             raise StopIteration
293:         return row
294:     def __getattr__(self, name):
295:         # DB-API 2.0 optional extension says these errors can be accessed
296:         # via Connection object. But MySQLdb had defined them on Cursor object.
297:         if name in (
298:             "Warning",
299:             "Error",
300:             "InterfaceError",
301:             "DatabaseError",
302:             "DataError",
303:             "OperationalError",
304:             "IntegrityError",
305:             "InternalError",
306:             "ProgrammingError",
307:             "NotSupportedError",
308:         ):
309:             # Deprecated since v1.1
310:             warnings.warn(
311:                 "PyMySQL errors hould be accessed from `pymysql` package",
312:                 DeprecationWarning,
313:                 stacklevel=2,
314:             )
315:             return getattr(err, name)
316:         raise AttributeError(name)
317: class DictCursorMixin:
318:     # You can override this to use OrderedDict or other dict-like types.
319:     dict_type = dict
320:     def _do_get_result(self):
321:         super()._do_get_result()
322:         fields = []
323:         if self.description:
324:             for f in self._result.fields:
325:                 name = f.name
326:                 if name in fields:
327:                     name = f.table_name + "." + name
328:                 fields.append(name)
329:             self._fields = fields
330:         if fields and self._rows:
331:             self._rows = [self._conv_row(r) for r in self._rows]
332:     def _conv_row(self, row):
333:         if row is None:
334:             return None
335:         return self.dict_type(zip(self._fields, row))
336: class DictCursor(DictCursorMixin, Cursor):
337:     """A cursor which returns results as a dictionary"""
338: class SSCursor(Cursor):
339:     """
340:     Unbuffered Cursor, mainly useful for queries that return a lot of data,
341:     or for connections to remote servers over a slow network.
342:     Instead of copying every row of data into a buffer, this will fetch
343:     rows as needed. The upside of this is the client uses much less memory,
344:     and rows are returned much faster when traveling over a slow network
345:     or if the result set is very big.
346:     There are limitations, though. The MySQL protocol doesn't support
347:     returning the total number of rows, so the only way to tell how many rows
348:     there are is to iterate over every row returned. Also, it currently isn't
349:     possible to scroll backwards, as only the current row is held in memory.
350:     """
351:     def _conv_row(self, row):
352:         return row
353:     def close(self):
354:         conn = self.connection
355:         if conn is None:
356:             return
357:         if self._result is not None and self._result is conn._result:
358:             self._result._finish_unbuffered_query()
359:         try:
360:             while self.nextset():
361:                 pass
362:         finally:
363:             self.connection = None
364:     __del__ = close
365:     def _query(self, q):
366:         conn = self._get_db()
367:         self._clear_result()
368:         conn.query(q, unbuffered=True)
369:         self._do_get_result()
370:         return self.rowcount
371:     def nextset(self):
372:         return self._nextset(unbuffered=True)
373:     def read_next(self):
374:         """Read next row."""
375:         return self._conv_row(self._result._read_rowdata_packet_unbuffered())
376:     def fetchone(self):
377:         """Fetch next row."""
378:         self._check_executed()
379:         row = self.read_next()
380:         if row is None:
381:             self.warning_count = self._result.warning_count
382:             return None
383:         self.rownumber += 1
384:         return row
385:     def fetchall(self):
386:         """
387:         Fetch all, as per MySQLdb. Pretty useless for large queries, as
388:         it is buffered. See fetchall_unbuffered(), if you want an unbuffered
389:         generator version of this method.
390:         """
391:         return list(self.fetchall_unbuffered())
392:     def fetchall_unbuffered(self):
393:         """
394:         Fetch all, implemented as a generator, which isn't to standard,
395:         however, it doesn't make sense to return everything in a list, as that
396:         would use ridiculous memory for large result sets.
397:         """
398:         return iter(self.fetchone, None)
399:     def fetchmany(self, size=None):
400:         """Fetch many."""
401:         self._check_executed()
402:         if size is None:
403:             size = self.arraysize
404:         rows = []
405:         for i in range(size):
406:             row = self.read_next()
407:             if row is None:
408:                 self.warning_count = self._result.warning_count
409:                 break
410:             rows.append(row)
411:             self.rownumber += 1
412:         if not rows:
413:             # Django expects () for EOF.
414:             # https://github.com/django/django/blob/0c1518ee429b01c145cf5b34eab01b0b92f8c246/django/db/backends/mysql/features.py#L8
415:             return ()
416:         return rows
417:     def scroll(self, value, mode="relative"):
418:         self._check_executed()
419:         if mode == "relative":
420:             if value < 0:
421:                 raise err.NotSupportedError(
422:                     "Backwards scrolling not supported by this cursor"
423:                 )
424:             for _ in range(value):
425:                 self.read_next()
426:             self.rownumber += value
427:         elif mode == "absolute":
428:             if value < self.rownumber:
429:                 raise err.NotSupportedError(
430:                     "Backwards scrolling not supported by this cursor"
431:                 )
432:             end = value - self.rownumber
433:             for _ in range(end):
434:                 self.read_next()
435:             self.rownumber = value
436:         else:
437:             raise err.ProgrammingError("unknown scroll mode %s" % mode)
438: class SSDictCursor(DictCursorMixin, SSCursor):
439:     """An unbuffered cursor, which returns results as a dictionary"""
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/err.py
````python
  1: import struct
  2: from .constants import ER
  3: class MySQLError(Exception):
  4:     """Exception related to operation with MySQL."""
  5: class Warning(Warning, MySQLError):
  6:     """Exception raised for important warnings like data truncations
  7:     while inserting, etc."""
  8: class Error(MySQLError):
  9:     """Exception that is the base class of all other error exceptions
 10:     (not Warning)."""
 11: class InterfaceError(Error):
 12:     """Exception raised for errors that are related to the database
 13:     interface rather than the database itself."""
 14: class DatabaseError(Error):
 15:     """Exception raised for errors that are related to the
 16:     database."""
 17: class DataError(DatabaseError):
 18:     """Exception raised for errors that are due to problems with the
 19:     processed data like division by zero, numeric value out of range,
 20:     etc."""
 21: class OperationalError(DatabaseError):
 22:     """Exception raised for errors that are related to the database's
 23:     operation and not necessarily under the control of the programmer,
 24:     e.g. an unexpected disconnect occurs, the data source name is not
 25:     found, a transaction could not be processed, a memory allocation
 26:     error occurred during processing, etc."""
 27: class IntegrityError(DatabaseError):
 28:     """Exception raised when the relational integrity of the database
 29:     is affected, e.g. a foreign key check fails, duplicate key,
 30:     etc."""
 31: class InternalError(DatabaseError):
 32:     """Exception raised when the database encounters an internal
 33:     error, e.g. the cursor is not valid anymore, the transaction is
 34:     out of sync, etc."""
 35: class ProgrammingError(DatabaseError):
 36:     """Exception raised for programming errors, e.g. table not found
 37:     or already exists, syntax error in the SQL statement, wrong number
 38:     of parameters specified, etc."""
 39: class NotSupportedError(DatabaseError):
 40:     """Exception raised in case a method or database API was used
 41:     which is not supported by the database, e.g. requesting a
 42:     .rollback() on a connection that does not support transaction or
 43:     has transactions turned off."""
 44: error_map = {}
 45: def _map_error(exc, *errors):
 46:     for error in errors:
 47:         error_map[error] = exc
 48: _map_error(
 49:     ProgrammingError,
 50:     ER.DB_CREATE_EXISTS,
 51:     ER.SYNTAX_ERROR,
 52:     ER.PARSE_ERROR,
 53:     ER.NO_SUCH_TABLE,
 54:     ER.WRONG_DB_NAME,
 55:     ER.WRONG_TABLE_NAME,
 56:     ER.FIELD_SPECIFIED_TWICE,
 57:     ER.INVALID_GROUP_FUNC_USE,
 58:     ER.UNSUPPORTED_EXTENSION,
 59:     ER.TABLE_MUST_HAVE_COLUMNS,
 60:     ER.CANT_DO_THIS_DURING_AN_TRANSACTION,
 61:     ER.WRONG_DB_NAME,
 62:     ER.WRONG_COLUMN_NAME,
 63: )
 64: _map_error(
 65:     DataError,
 66:     ER.WARN_DATA_TRUNCATED,
 67:     ER.WARN_NULL_TO_NOTNULL,
 68:     ER.WARN_DATA_OUT_OF_RANGE,
 69:     ER.NO_DEFAULT,
 70:     ER.PRIMARY_CANT_HAVE_NULL,
 71:     ER.DATA_TOO_LONG,
 72:     ER.DATETIME_FUNCTION_OVERFLOW,
 73:     ER.TRUNCATED_WRONG_VALUE_FOR_FIELD,
 74:     ER.ILLEGAL_VALUE_FOR_TYPE,
 75: )
 76: _map_error(
 77:     IntegrityError,
 78:     ER.DUP_ENTRY,
 79:     ER.NO_REFERENCED_ROW,
 80:     ER.NO_REFERENCED_ROW_2,
 81:     ER.ROW_IS_REFERENCED,
 82:     ER.ROW_IS_REFERENCED_2,
 83:     ER.CANNOT_ADD_FOREIGN,
 84:     ER.BAD_NULL_ERROR,
 85: )
 86: _map_error(
 87:     NotSupportedError,
 88:     ER.WARNING_NOT_COMPLETE_ROLLBACK,
 89:     ER.NOT_SUPPORTED_YET,
 90:     ER.FEATURE_DISABLED,
 91:     ER.UNKNOWN_STORAGE_ENGINE,
 92: )
 93: _map_error(
 94:     OperationalError,
 95:     ER.DBACCESS_DENIED_ERROR,
 96:     ER.ACCESS_DENIED_ERROR,
 97:     ER.CON_COUNT_ERROR,
 98:     ER.TABLEACCESS_DENIED_ERROR,
 99:     ER.COLUMNACCESS_DENIED_ERROR,
100:     ER.CONSTRAINT_FAILED,
101:     ER.LOCK_DEADLOCK,
102: )
103: del _map_error, ER
104: def raise_mysql_exception(data):
105:     errno = struct.unpack("<h", data[1:3])[0]
106:     # https://dev.mysql.com/doc/dev/mysql-server/latest/page_protocol_basic_err_packet.html
107:     # Error packet has optional sqlstate that is 5 bytes and starts with '#'.
108:     if data[3] == 0x23:  # '#'
109:         # sqlstate = data[4:9].decode()
110:         # TODO: Append (sqlstate) in the error message. This will be come in next minor release.
111:         errval = data[9:].decode("utf-8", "replace")
112:     else:
113:         errval = data[3:].decode("utf-8", "replace")
114:     errorclass = error_map.get(errno)
115:     if errorclass is None:
116:         errorclass = InternalError if errno < 1000 else OperationalError
117:     raise errorclass(errno, errval)
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/optionfile.py
````python
 1: import configparser
 2: class Parser(configparser.RawConfigParser):
 3:     def __init__(self, **kwargs):
 4:         kwargs["allow_no_value"] = True
 5:         configparser.RawConfigParser.__init__(self, **kwargs)
 6:     def __remove_quotes(self, value):
 7:         quotes = ["'", '"']
 8:         for quote in quotes:
 9:             if len(value) >= 2 and value[0] == value[-1] == quote:
10:                 return value[1:-1]
11:         return value
12:     def optionxform(self, key):
13:         return key.lower().replace("_", "-")
14:     def get(self, section, option):
15:         value = configparser.RawConfigParser.get(self, section, option)
16:         return self.__remove_quotes(value)
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/protocol.py
````python
  1: # Python implementation of low level MySQL client-server protocol
  2: # http://dev.mysql.com/doc/internals/en/client-server-protocol.html
  3: from .charset import MBLENGTH
  4: from .constants import FIELD_TYPE, SERVER_STATUS
  5: from . import err
  6: import struct
  7: import sys
  8: DEBUG = False
  9: NULL_COLUMN = 251
 10: UNSIGNED_CHAR_COLUMN = 251
 11: UNSIGNED_SHORT_COLUMN = 252
 12: UNSIGNED_INT24_COLUMN = 253
 13: UNSIGNED_INT64_COLUMN = 254
 14: def dump_packet(data):  # pragma: no cover
 15:     def printable(data):
 16:         if 32 <= data < 127:
 17:             return chr(data)
 18:         return "."
 19:     try:
 20:         print("packet length:", len(data))
 21:         for i in range(1, 7):
 22:             f = sys._getframe(i)
 23:             print("call[%d]: %s (line %d)" % (i, f.f_code.co_name, f.f_lineno))
 24:         print("-" * 66)
 25:     except ValueError:
 26:         pass
 27:     dump_data = [data[i : i + 16] for i in range(0, min(len(data), 256), 16)]
 28:     for d in dump_data:
 29:         print(
 30:             " ".join(f"{x:02X}" for x in d)
 31:             + "   " * (16 - len(d))
 32:             + " " * 2
 33:             + "".join(printable(x) for x in d)
 34:         )
 35:     print("-" * 66)
 36:     print()
 37: class MysqlPacket:
 38:     """Representation of a MySQL response packet.
 39:     Provides an interface for reading/parsing the packet results.
 40:     """
 41:     __slots__ = ("_position", "_data")
 42:     def __init__(self, data, encoding):
 43:         self._position = 0
 44:         self._data = data
 45:     def get_all_data(self):
 46:         return self._data
 47:     def read(self, size):
 48:         """Read the first 'size' bytes in packet and advance cursor past them."""
 49:         result = self._data[self._position : (self._position + size)]
 50:         if len(result) != size:
 51:             error = (
 52:                 "Result length not requested length:\n"
 53:                 f"Expected={size}.  Actual={len(result)}.  Position: {self._position}.  Data Length: {len(self._data)}"
 54:             )
 55:             if DEBUG:
 56:                 print(error)
 57:                 self.dump()
 58:             raise AssertionError(error)
 59:         self._position += size
 60:         return result
 61:     def read_all(self):
 62:         """Read all remaining data in the packet.
 63:         (Subsequent read() will return errors.)
 64:         """
 65:         result = self._data[self._position :]
 66:         self._position = None  # ensure no subsequent read()
 67:         return result
 68:     def advance(self, length):
 69:         """Advance the cursor in data buffer 'length' bytes."""
 70:         new_position = self._position + length
 71:         if new_position < 0 or new_position > len(self._data):
 72:             raise Exception(
 73:                 f"Invalid advance amount ({length}) for cursor.  Position={new_position}"
 74:             )
 75:         self._position = new_position
 76:     def rewind(self, position=0):
 77:         """Set the position of the data buffer cursor to 'position'."""
 78:         if position < 0 or position > len(self._data):
 79:             raise Exception("Invalid position to rewind cursor to: %s." % position)
 80:         self._position = position
 81:     def get_bytes(self, position, length=1):
 82:         """Get 'length' bytes starting at 'position'.
 83:         Position is start of payload (first four packet header bytes are not
 84:         included) starting at index '0'.
 85:         No error checking is done.  If requesting outside end of buffer
 86:         an empty string (or string shorter than 'length') may be returned!
 87:         """
 88:         return self._data[position : (position + length)]
 89:     def read_uint8(self):
 90:         result = self._data[self._position]
 91:         self._position += 1
 92:         return result
 93:     def read_uint16(self):
 94:         result = struct.unpack_from("<H", self._data, self._position)[0]
 95:         self._position += 2
 96:         return result
 97:     def read_uint24(self):
 98:         low, high = struct.unpack_from("<HB", self._data, self._position)
 99:         self._position += 3
100:         return low + (high << 16)
101:     def read_uint32(self):
102:         result = struct.unpack_from("<I", self._data, self._position)[0]
103:         self._position += 4
104:         return result
105:     def read_uint64(self):
106:         result = struct.unpack_from("<Q", self._data, self._position)[0]
107:         self._position += 8
108:         return result
109:     def read_string(self):
110:         end_pos = self._data.find(b"\0", self._position)
111:         if end_pos < 0:
112:             return None
113:         result = self._data[self._position : end_pos]
114:         self._position = end_pos + 1
115:         return result
116:     def read_length_encoded_integer(self):
117:         """Read a 'Length Coded Binary' number from the data buffer.
118:         Length coded numbers can be anywhere from 1 to 9 bytes depending
119:         on the value of the first byte.
120:         """
121:         c = self.read_uint8()
122:         if c == NULL_COLUMN:
123:             return None
124:         if c < UNSIGNED_CHAR_COLUMN:
125:             return c
126:         elif c == UNSIGNED_SHORT_COLUMN:
127:             return self.read_uint16()
128:         elif c == UNSIGNED_INT24_COLUMN:
129:             return self.read_uint24()
130:         elif c == UNSIGNED_INT64_COLUMN:
131:             return self.read_uint64()
132:     def read_length_coded_string(self):
133:         """Read a 'Length Coded String' from the data buffer.
134:         A 'Length Coded String' consists first of a length coded
135:         (unsigned, positive) integer represented in 1-9 bytes followed by
136:         that many bytes of binary data.  (For example "cat" would be "3cat".)
137:         """
138:         length = self.read_length_encoded_integer()
139:         if length is None:
140:             return None
141:         return self.read(length)
142:     def read_struct(self, fmt):
143:         s = struct.Struct(fmt)
144:         result = s.unpack_from(self._data, self._position)
145:         self._position += s.size
146:         return result
147:     def is_ok_packet(self):
148:         # https://dev.mysql.com/doc/internals/en/packet-OK_Packet.html
149:         return self._data[0] == 0 and len(self._data) >= 7
150:     def is_eof_packet(self):
151:         # http://dev.mysql.com/doc/internals/en/generic-response-packets.html#packet-EOF_Packet
152:         # Caution: \xFE may be LengthEncodedInteger.
153:         # If \xFE is LengthEncodedInteger header, 8bytes followed.
154:         return self._data[0] == 0xFE and len(self._data) < 9
155:     def is_auth_switch_request(self):
156:         # http://dev.mysql.com/doc/internals/en/connection-phase-packets.html#packet-Protocol::AuthSwitchRequest
157:         return self._data[0] == 0xFE
158:     def is_extra_auth_data(self):
159:         # https://dev.mysql.com/doc/internals/en/successful-authentication.html
160:         return self._data[0] == 1
161:     def is_resultset_packet(self):
162:         field_count = self._data[0]
163:         return 1 <= field_count <= 250
164:     def is_load_local_packet(self):
165:         return self._data[0] == 0xFB
166:     def is_error_packet(self):
167:         return self._data[0] == 0xFF
168:     def check_error(self):
169:         if self.is_error_packet():
170:             self.raise_for_error()
171:     def raise_for_error(self):
172:         self.rewind()
173:         self.advance(1)  # field_count == error (we already know that)
174:         errno = self.read_uint16()
175:         if DEBUG:
176:             print("errno =", errno)
177:         err.raise_mysql_exception(self._data)
178:     def dump(self):
179:         dump_packet(self._data)
180: class FieldDescriptorPacket(MysqlPacket):
181:     """A MysqlPacket that represents a specific column's metadata in the result.
182:     Parsing is automatically done and the results are exported via public
183:     attributes on the class such as: db, table_name, name, length, type_code.
184:     """
185:     def __init__(self, data, encoding):
186:         MysqlPacket.__init__(self, data, encoding)
187:         self._parse_field_descriptor(encoding)
188:     def _parse_field_descriptor(self, encoding):
189:         """Parse the 'Field Descriptor' (Metadata) packet.
190:         This is compatible with MySQL 4.1+ (not compatible with MySQL 4.0).
191:         """
192:         self.catalog = self.read_length_coded_string()
193:         self.db = self.read_length_coded_string()
194:         self.table_name = self.read_length_coded_string().decode(encoding)
195:         self.org_table = self.read_length_coded_string().decode(encoding)
196:         self.name = self.read_length_coded_string().decode(encoding)
197:         self.org_name = self.read_length_coded_string().decode(encoding)
198:         (
199:             self.charsetnr,
200:             self.length,
201:             self.type_code,
202:             self.flags,
203:             self.scale,
204:         ) = self.read_struct("<xHIBHBxx")
205:         # 'default' is a length coded binary and is still in the buffer?
206:         # not used for normal result sets...
207:     def description(self):
208:         """Provides a 7-item tuple compatible with the Python PEP249 DB Spec."""
209:         return (
210:             self.name,
211:             self.type_code,
212:             None,  # TODO: display_length; should this be self.length?
213:             self.get_column_length(),  # 'internal_size'
214:             self.get_column_length(),  # 'precision'  # TODO: why!?!?
215:             self.scale,
216:             self.flags % 2 == 0,
217:         )
218:     def get_column_length(self):
219:         if self.type_code == FIELD_TYPE.VAR_STRING:
220:             mblen = MBLENGTH.get(self.charsetnr, 1)
221:             return self.length // mblen
222:         return self.length
223:     def __str__(self):
224:         return "{} {!r}.{!r}.{!r}, type={}, flags={:x}".format(
225:             self.__class__,
226:             self.db,
227:             self.table_name,
228:             self.name,
229:             self.type_code,
230:             self.flags,
231:         )
232: class OKPacketWrapper:
233:     """
234:     OK Packet Wrapper. It uses an existing packet object, and wraps
235:     around it, exposing useful variables while still providing access
236:     to the original packet objects variables and methods.
237:     """
238:     def __init__(self, from_packet):
239:         if not from_packet.is_ok_packet():
240:             raise ValueError(
241:                 "Cannot create "
242:                 + str(self.__class__.__name__)
243:                 + " object from invalid packet type"
244:             )
245:         self.packet = from_packet
246:         self.packet.advance(1)
247:         self.affected_rows = self.packet.read_length_encoded_integer()
248:         self.insert_id = self.packet.read_length_encoded_integer()
249:         self.server_status, self.warning_count = self.read_struct("<HH")
250:         self.message = self.packet.read_all()
251:         self.has_next = self.server_status & SERVER_STATUS.SERVER_MORE_RESULTS_EXISTS
252:     def __getattr__(self, key):
253:         return getattr(self.packet, key)
254: class EOFPacketWrapper:
255:     """
256:     EOF Packet Wrapper. It uses an existing packet object, and wraps
257:     around it, exposing useful variables while still providing access
258:     to the original packet objects variables and methods.
259:     """
260:     def __init__(self, from_packet):
261:         if not from_packet.is_eof_packet():
262:             raise ValueError(
263:                 f"Cannot create '{self.__class__}' object from invalid packet type"
264:             )
265:         self.packet = from_packet
266:         self.warning_count, self.server_status = self.packet.read_struct("<xhh")
267:         if DEBUG:
268:             print("server_status=", self.server_status)
269:         self.has_next = self.server_status & SERVER_STATUS.SERVER_MORE_RESULTS_EXISTS
270:     def __getattr__(self, key):
271:         return getattr(self.packet, key)
272: class LoadLocalPacketWrapper:
273:     """
274:     Load Local Packet Wrapper. It uses an existing packet object, and wraps
275:     around it, exposing useful variables while still providing access
276:     to the original packet objects variables and methods.
277:     """
278:     def __init__(self, from_packet):
279:         if not from_packet.is_load_local_packet():
280:             raise ValueError(
281:                 f"Cannot create '{self.__class__}' object from invalid packet type"
282:             )
283:         self.packet = from_packet
284:         self.filename = self.packet.get_all_data()[1:]
285:         if DEBUG:
286:             print("filename=", self.filename)
287:     def __getattr__(self, key):
288:         return getattr(self.packet, key)
````

## File: infra/envs/prod/lambda/db_bootstrap/pymysql/times.py
````python
 1: from time import localtime
 2: from datetime import date, datetime, time, timedelta
 3: Date = date
 4: Time = time
 5: TimeDelta = timedelta
 6: Timestamp = datetime
 7: def DateFromTicks(ticks):
 8:     return date(*localtime(ticks)[:3])
 9: def TimeFromTicks(ticks):
10:     return time(*localtime(ticks)[3:6])
11: def TimestampFromTicks(ticks):
12:     return datetime(*localtime(ticks)[:6])
````

## File: infra/envs/prod/backend.tf
````hcl
 1: ###############################################################################
 2: # Remote state backend.
 3: #
 4: # The bucket and KMS key are created by infra/bootstrap. Replace placeholders
 5: # with the bootstrap outputs (or pass them via -backend-config).
 6: #
 7: # Native S3 locking is used (use_lockfile = true). DynamoDB is not required.
 8: ###############################################################################
 9: 
10: terraform {
11:   backend "s3" {
12:     bucket       = "java-app-tfstate-260684397593-us-east-1"
13:     key          = "java-app/prod/terraform.tfstate"
14:     region       = "us-east-1"
15:     encrypt      = true
16:     kms_key_id   = "arn:aws:kms:us-east-1:260684397593:key/4d06feee-1aea-4a51-9ecb-174775f82666"
17:     use_lockfile = true
18:   }
19: }
````

## File: infra/envs/prod/db_bootstrap.tf
````hcl
  1: ###############################################################################
  2: # DB bootstrap - idempotent provisioning of the application MySQL user.
  3: #
  4: # Why this exists:
  5: #   The RDS instance ships with only the master user (`dbadmin`). The
  6: #   application connects as `appuser`, whose CREATE USER + GRANT cannot be
  7: #   performed by Flyway because Flyway authenticates AS `appuser` (chicken/
  8: #   egg). After every dev-cycle `terraform destroy` + `terraform apply` the
  9: #   RDS instance is recreated empty-of-`appuser`, the backend container
 10: #   crash-loops on `Access denied for user 'appuser'`, and the ASG flaps
 11: #   until the user is provisioned out-of-band. See runbook RB-ASG-001
 12: #   (docs/auxiliary/operations_guide/runbooks/2026-05-10_asg_flapping_investigation.md).
 13: #
 14: # How:
 15: #   A small Python Lambda runs in the VPC, reads the RDS-managed master
 16: #   secret and the app-user secret from Secrets Manager, and executes
 17: #   idempotent DDL:
 18: #
 19: #     CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED WITH caching_sha2_password BY ?;
 20: #     ALTER USER  'appuser'@'%' IDENTIFIED WITH caching_sha2_password BY ?;
 21: #     GRANT ALL PRIVILEGES ON `javaapp`.* TO 'appuser'@'%';
 22: #     FLUSH PRIVILEGES;
 23: #
 24: #   `terraform_data.db_bootstrap` invokes the Lambda whenever:
 25: #     - the RDS resource id changes (replacement, e.g. dev-cycle re-apply), or
 26: #     - the app-user secret version changes (manual rotation).
 27: #
 28: # Trade-off vs. data "aws_lambda_invocation":
 29: #   That data source runs on every plan, which adds noise. terraform_data
 30: #   with explicit triggers re-runs only on the events that actually require
 31: #   the bootstrap to converge. Both are idempotent on the DB side; this
 32: #   choice is purely about plan signal-to-noise.
 33: #
 34: # Connection security:
 35: #   TLS to RDS without CA verification (ssl={"ssl": {}} in the Lambda).
 36: #   Intra-VPC traffic to the RDS endpoint is the only viable path because
 37: #   the RDS SG only accepts ingress from referenced SGs. Tighten to a CA
 38: #   bundle if compliance requires explicit cert validation.
 39: ###############################################################################
 40: 
 41: # ----------------------------------------------------------------------------
 42: # Network: dedicated SG for the bootstrap Lambda. Egress to RDS on 3306
 43: # (referenced-SG rule), and HTTPS to AWS APIs (Secrets Manager VPCE).
 44: # ----------------------------------------------------------------------------
 45: resource "aws_security_group" "db_bootstrap_lambda" {
 46:   # checkov:skip=CKV2_AWS_5:attached to aws_lambda_function.db_bootstrap.vpc_config; checkov cannot follow the SG ID through the Lambda VPC config.
 47:   name        = "${local.name_prefix}-db-bootstrap-sg"
 48:   description = "Lambda that bootstraps the appuser MySQL account after RDS is created."
 49:   vpc_id      = module.vpc.vpc_id
 50:   tags        = merge(local.common_tags, { Name = "${local.name_prefix}-db-bootstrap-sg" })
 51: }
 52: 
 53: resource "aws_vpc_security_group_egress_rule" "db_bootstrap_to_rds" {
 54:   security_group_id            = aws_security_group.db_bootstrap_lambda.id
 55:   description                  = "MySQL egress to RDS"
 56:   ip_protocol                  = "tcp"
 57:   from_port                    = local.db_port
 58:   to_port                      = local.db_port
 59:   referenced_security_group_id = aws_security_group.rds.id
 60: }
 61: 
 62: resource "aws_vpc_security_group_egress_rule" "db_bootstrap_https" {
 63:   security_group_id = aws_security_group.db_bootstrap_lambda.id
 64:   description       = "HTTPS to AWS APIs (Secrets Manager VPCE)"
 65:   ip_protocol       = "tcp"
 66:   from_port         = 443
 67:   to_port           = 443
 68:   cidr_ipv4         = var.vpc_cidr
 69: }
 70: 
 71: resource "aws_vpc_security_group_ingress_rule" "rds_from_db_bootstrap" {
 72:   security_group_id            = aws_security_group.rds.id
 73:   description                  = "MySQL from db-bootstrap Lambda"
 74:   ip_protocol                  = "tcp"
 75:   from_port                    = local.db_port
 76:   to_port                      = local.db_port
 77:   referenced_security_group_id = aws_security_group.db_bootstrap_lambda.id
 78: }
 79: 
 80: # ----------------------------------------------------------------------------
 81: # IAM
 82: # ----------------------------------------------------------------------------
 83: data "aws_iam_policy_document" "db_bootstrap_assume" {
 84:   statement {
 85:     actions = ["sts:AssumeRole"]
 86:     principals {
 87:       type        = "Service"
 88:       identifiers = ["lambda.amazonaws.com"]
 89:     }
 90:   }
 91: }
 92: 
 93: resource "aws_iam_role" "db_bootstrap_lambda" {
 94:   name               = "${local.name_prefix}-db-bootstrap-lambda"
 95:   assume_role_policy = data.aws_iam_policy_document.db_bootstrap_assume.json
 96:   tags               = local.common_tags
 97: }
 98: 
 99: # Required for VPC-attached Lambda: ENI create/delete + log writes.
100: resource "aws_iam_role_policy_attachment" "db_bootstrap_vpc_exec" {
101:   role       = aws_iam_role.db_bootstrap_lambda.name
102:   policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
103: }
104: 
105: data "aws_iam_policy_document" "db_bootstrap_inline" {
106:   # Read both DB credential secrets.
107:   statement {
108:     sid    = "ReadDbSecrets"
109:     effect = "Allow"
110:     actions = [
111:       "secretsmanager:GetSecretValue",
112:       "secretsmanager:DescribeSecret",
113:     ]
114:     resources = [
115:       module.rds.db_instance_master_user_secret_arn,
116:       aws_secretsmanager_secret.db_app_user.arn,
117:     ]
118:   }
119: 
120:   # Decrypt the secrets above (both are encrypted with the app-secrets CMK
121:   # per rds.tf:87 and secrets.tf:104).
122:   statement {
123:     sid       = "DecryptSecrets"
124:     effect    = "Allow"
125:     actions   = ["kms:Decrypt", "kms:DescribeKey"]
126:     resources = [aws_kms_key.app_secrets.arn]
127:   }
128: }
129: 
130: resource "aws_iam_policy" "db_bootstrap_inline" {
131:   name   = "${local.name_prefix}-db-bootstrap-inline"
132:   policy = data.aws_iam_policy_document.db_bootstrap_inline.json
133: }
134: 
135: resource "aws_iam_role_policy_attachment" "db_bootstrap_inline" {
136:   role       = aws_iam_role.db_bootstrap_lambda.name
137:   policy_arn = aws_iam_policy.db_bootstrap_inline.arn
138: }
139: 
140: # ----------------------------------------------------------------------------
141: # Lambda package
142: # ----------------------------------------------------------------------------
143: data "archive_file" "db_bootstrap" {
144:   type        = "zip"
145:   source_dir  = "${path.module}/lambda/db_bootstrap"
146:   output_path = "${path.module}/.terraform/tmp/db_bootstrap.zip"
147: 
148:   # Excludes any pre-existing zip alongside the source dir to prevent
149:   # archive_file from packaging its own output if Terraform is re-run with
150:   # the output path inside source_dir (it isn't here, but defensive).
151:   excludes = ["__pycache__", "*.pyc"]
152: }
153: 
154: resource "aws_lambda_function" "db_bootstrap" {
155:   # checkov:skip=CKV_AWS_115:reserved concurrency intentionally unset; the function is invoked once per terraform_data trigger event, not by a high-throughput consumer.
156:   # checkov:skip=CKV_AWS_116:DLQ intentionally unset; Lambda errors propagate to terraform_data.local-exec and surface in the apply log.
157:   # checkov:skip=CKV_AWS_117:VPC config IS set (vpc_config block below); checkov sometimes mis-parses inline VPC config blocks.
158:   # checkov:skip=CKV_AWS_173:env vars are non-sensitive identifiers (host, port, db name, secret ARNs); secret VALUES are fetched at runtime.
159:   # checkov:skip=CKV_AWS_272:code-signing not enforced in dev; revisit alongside enabling AWS Signer for the deployment account.
160:   function_name = "${local.name_prefix}-db-bootstrap"
161:   description   = "Idempotent CREATE USER + GRANT for the application MySQL user."
162: 
163:   role             = aws_iam_role.db_bootstrap_lambda.arn
164:   filename         = data.archive_file.db_bootstrap.output_path
165:   source_code_hash = data.archive_file.db_bootstrap.output_base64sha256
166: 
167:   runtime     = "python3.12"
168:   handler     = "main.handler"
169:   timeout     = 60
170:   memory_size = 256
171: 
172:   vpc_config {
173:     subnet_ids         = module.vpc.private_subnets
174:     security_group_ids = [aws_security_group.db_bootstrap_lambda.id]
175:   }
176: 
177:   environment {
178:     variables = {
179:       DB_HOST            = module.rds.db_instance_address
180:       DB_PORT            = tostring(local.db_port)
181:       DB_NAME            = var.db_name
182:       APP_USER           = var.db_app_username
183:       MASTER_SECRET_ARN  = module.rds.db_instance_master_user_secret_arn
184:       APPUSER_SECRET_ARN = aws_secretsmanager_secret.db_app_user.arn
185:     }
186:   }
187: 
188:   tracing_config {
189:     mode = "PassThrough"
190:   }
191: 
192:   tags = local.common_tags
193: 
194:   depends_on = [
195:     aws_iam_role_policy_attachment.db_bootstrap_vpc_exec,
196:     aws_iam_role_policy_attachment.db_bootstrap_inline,
197:   ]
198: }
199: 
200: # ----------------------------------------------------------------------------
201: # Invocation orchestrator
202: #
203: # terraform_data is a no-op resource that re-runs its provisioner only when
204: # triggers_replace changes. We trigger on:
205: #   - module.rds.db_instance_resource_id  -> RDS replacement (dev re-apply).
206: #   - aws_secretsmanager_secret_version.db_app_user.version_id -> rotation.
207: #   - aws_lambda_function.db_bootstrap.source_code_hash -> code change.
208: #
209: # The provisioner shells out to `aws lambda invoke`, then fails the apply
210: # if the function returned an error or non-200 status. This surfaces DB
211: # bootstrap problems at apply time instead of leaving a broken stack
212: # behind a green plan/apply.
213: # ----------------------------------------------------------------------------
214: resource "terraform_data" "db_bootstrap" {
215:   triggers_replace = {
216:     rds_id            = module.rds.db_instance_resource_id
217:     app_secret_ver    = aws_secretsmanager_secret_version.db_app_user.version_id
218:     lambda_code_hash  = aws_lambda_function.db_bootstrap.source_code_hash
219:     lambda_env_master = module.rds.db_instance_master_user_secret_arn
220:     lambda_env_app    = aws_secretsmanager_secret.db_app_user.arn
221:   }
222: 
223:   provisioner "local-exec" {
224:     interpreter = ["/bin/bash", "-c"]
225:     command     = <<-EOT
226:       set -euo pipefail
227:       OUT=$(mktemp -t db_bootstrap_out.XXXXXX.json)
228:       trap 'rm -f "$OUT"' EXIT
229:       aws lambda invoke \
230:         --region ${var.aws_region} \
231:         --function-name ${aws_lambda_function.db_bootstrap.function_name} \
232:         --invocation-type RequestResponse \
233:         --cli-binary-format raw-in-base64-out \
234:         --payload '{}' \
235:         "$OUT" >/dev/null
236:       cat "$OUT"
237:       echo
238:       python3 -c '
239:       import json, sys
240:       data=json.load(open(sys.argv[1]))
241:       if not isinstance(data, dict) or data.get("status") != "ok":
242:           print("db_bootstrap returned unexpected payload:", data, file=sys.stderr)
243:           sys.exit(1)
244:       ' "$OUT"
245:     EOT
246:   }
247: 
248:   depends_on = [
249:     aws_lambda_function.db_bootstrap,
250:     aws_iam_role_policy_attachment.db_bootstrap_inline,
251:     aws_iam_role_policy_attachment.db_bootstrap_vpc_exec,
252:     aws_vpc_security_group_egress_rule.db_bootstrap_to_rds,
253:     aws_vpc_security_group_egress_rule.db_bootstrap_https,
254:     aws_vpc_security_group_ingress_rule.rds_from_db_bootstrap,
255:     module.rds,
256:   ]
257: }
258: 
259: # ----------------------------------------------------------------------------
260: # Outputs (operator-facing)
261: # ----------------------------------------------------------------------------
262: output "db_bootstrap_lambda_name" {
263:   description = "Name of the Lambda that provisions the appuser MySQL account. Manually re-trigger with: aws lambda invoke --function-name <name> /tmp/out.json && cat /tmp/out.json"
264:   value       = aws_lambda_function.db_bootstrap.function_name
265: }
````

## File: infra/envs/prod/providers.tf
````hcl
 1: ###############################################################################
 2: # Providers
 3: #
 4: # Default `aws` provider:
 5: #   Targets the DEPLOYMENT account. CI assumes the DEPLOYMENT_ROLE_ARN via
 6: #   GitHub OIDC; the operator can also run locally with admin credentials.
 7: #
 8: # Aliased `aws.domain` provider:
 9: #   Assumes a Route53-DNS-write role in the DOMAIN account so cross-account
10: #   alias records and SES DKIM CNAMEs can be managed from the same plan.
11: ###############################################################################
12: 
13: provider "aws" {
14:   region = var.aws_region
15: 
16:   default_tags {
17:     tags = local.common_tags
18:   }
19: }
20: 
21: provider "aws" {
22:   alias  = "domain"
23:   region = var.aws_region
24: 
25:   assume_role {
26:     role_arn     = var.domain_account_route53_role_arn
27:     session_name = "tf-${var.project}-${var.environment}"
28:   }
29: 
30:   default_tags {
31:     tags = local.common_tags
32:   }
33: }
````

## File: tests/e2e/specs/smoke.spec.ts
````typescript
 1: import { test, expect } from '@playwright/test';
 2: test('landing page renders and security headers are present', async ({ page, request }) => {
 3:   // 1. Container-level health (frontend Nginx)
 4:   const healthz = await request.get('/healthz');
 5:   expect(healthz.ok()).toBeTruthy();
 6:   // 2. Backend health proxied via Nginx
 7:   const beHealth = await request.get('/actuator/health');
 8:   expect(beHealth.ok()).toBeTruthy();
 9:   // 3. Page renders + security headers (TR-HARD-010)
10:   const res = await request.get('/');
11:   expect(res.ok()).toBeTruthy();
12:   const headers = res.headers();
13:   expect(headers['strict-transport-security']).toBeTruthy();
14:   expect(headers['x-content-type-options']).toBe('nosniff');
15:   expect(headers['x-frame-options']).toBe('DENY');
16:   expect(headers['referrer-policy']).toBeTruthy();
17:   expect(headers['content-security-policy']).toBeTruthy();
18:   await page.goto('/');
19:   await expect(page.locator('h1')).toContainText('Welcome');
20: });
21: test('signup -> verify code rejection -> login rejection', async ({ page, request }) => {
22:   const email = `user-${Date.now()}@example.test`;
23:   const signup = await request.post('/api/auth/signup', {
24:     data: { email, password: 'CorrectHorse_Battery_5!', fullName: 'Test User' },
25:   });
26:   expect(signup.status()).toBe(202);
27:   // Wrong code -> 400 generic
28:   const v = await request.post('/api/auth/verify', { data: { email, code: '000000' } });
29:   expect(v.status()).toBe(400);
30:   // Login before verify -> 401
31:   const l = await request.post('/api/auth/login', { data: { email, password: 'CorrectHorse_Battery_5!' } });
32:   expect(l.status()).toBe(401);
33: });
````

## File: tests/e2e/playwright.config.ts
````typescript
 1: import { defineConfig, devices } from '@playwright/test';
 2: export default defineConfig({
 3:   testDir: './specs',
 4:   timeout: 60_000,
 5:   expect: { timeout: 10_000 },
 6:   retries: 1,
 7:   reporter: process.env.CI ? [['list'], ['html', { open: 'never' }]] : 'list',
 8:   use: {
 9:     baseURL: process.env.E2E_BASE_URL ?? 'http://localhost:8080',
10:     trace: 'retain-on-failure',
11:     screenshot: 'only-on-failure',
12:     video: 'retain-on-failure',
13:   },
14:   projects: [
15:     { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
16:   ],
17: });
````

## File: .editorconfig
````
 1: root = true
 2: 
 3: [*]
 4: charset = utf-8
 5: end_of_line = lf
 6: indent_style = space
 7: indent_size = 2
 8: insert_final_newline = true
 9: trim_trailing_whitespace = true
10: 
11: [*.{java,sql}]
12: indent_size = 4
13: 
14: [Makefile]
15: indent_style = tab
16: 
17: [*.md]
18: trim_trailing_whitespace = false
````

## File: repomix.config.json
````json
 1: {
 2:   "$schema": "https://repomix.com/schemas/latest/schema.json",
 3:   "input": {
 4:     "maxFileSize": 52428800,
 5:     "instructionFilePath": "repomix-instruction.md"
 6:   },
 7:   "output": {
 8:     "filePath": "repomix-output.md",
 9:     "style": "markdown",
10:     "parsableStyle": false,
11:     "fileSummary": true,
12:     "directoryStructure": true,
13:     "files": true,
14:     "removeComments": false,
15:     "removeEmptyLines": true,
16:     "compress": false,
17:     "topFilesLength": 15,
18:     "showLineNumbers": true,
19:     "truncateBase64": false,
20:     "copyToClipboard": false,
21:     "includeFullDirectoryStructure": true,
22:     "tokenCountTree": false,
23:     "git": {
24:       "sortByChanges": true,
25:       "sortByChangesMaxCommits": 100,
26:       "includeDiffs": false,
27:       "includeLogs": false,
28:       "includeLogsCount": 50
29:     }
30:   },
31:   "include": [],
32:   "ignore": {
33:     "useGitignore": true,
34:     "useDotIgnore": true,
35:     "useDefaultPatterns": true,
36:     "customPatterns": []
37:   },
38:   "security": {
39:     "enableSecurityCheck": true
40:   },
41:   "tokenCount": {
42:     "encoding": "o200k_base"
43:   }
44: }
````

## File: .github/scripts/purge_pending_secrets.sh
````bash
 1: #!/usr/bin/env bash
 2: # Purge any AWS Secrets Manager secrets that are in the PendingDeletion state
 3: # under the project's well-known prefix (set by infra/envs/prod/secrets.tf).
 4: #
 5: # Why this exists: AWS forbids creating a new secret whose name is currently
 6: # scheduled for deletion. After `terraform destroy`, the four app secrets
 7: # enter a 7-day recovery window and block any subsequent `terraform apply`
 8: # until the window expires or the secrets are forcibly removed.
 9: #
10: # Strategy: ListSecrets with --include-planned-deletion under the prefix,
11: # then ForceDelete every match whose DeletedDate is non-null. This handles
12: # leftovers under variant names and avoids the missing-vs-healthy ambiguity
13: # that a per-name DescribeSecret had: DescribeSecret returns success on a
14: # healthy secret and ResourceNotFoundException on a missing one, both of
15: # which look identical when stderr is suppressed, so genuine pending-
16: # deletion entries can hide behind a misconfigured region or profile.
17: #
18: # Idempotent: safe to re-run. Exits 0 if no secrets are pending.
19: # Requires: AWS CLI v2 (--include-planned-deletion was added in v2).
20: # Credentials must already be exported (the workflow handles this via
21: # aws-actions/configure-aws-credentials).
22: #
23: # Env overrides:
24: #   SECRET_PREFIX  Defaults to /java-app/prod/. Change for other envs/projects.
25: set -euo pipefail
26: PREFIX="${SECRET_PREFIX:-/java-app/prod/}"
27: # Visibility: print exactly which AWS account, region, and principal this
28: # run is targeting. If this disagrees with where the pending-deletion
29: # secrets actually live, no purge will happen and Terraform will keep
30: # failing with InvalidRequestException.
31: echo "AWS context for purge:"
32: aws sts get-caller-identity --output table || {
33:   echo "ERROR: sts get-caller-identity failed; credentials are not configured." >&2
34:   exit 1
35: }
36: echo "Region:       ${AWS_REGION:-${AWS_DEFAULT_REGION:-<unset>}}"
37: echo "Prefix:       ${PREFIX}"
38: echo
39: # ListSecrets filters: Key=name does a prefix-style match on the Name field.
40: # --include-planned-deletion is required to surface pending-deletion entries.
41: # The query keeps only those with DeletedDate set.
42: mapfile -t PENDING < <(
43:   aws secretsmanager list-secrets \
44:     --include-planned-deletion \
45:     --filters "Key=name,Values=${PREFIX}" \
46:     --query 'SecretList[?DeletedDate!=`null`].Name' \
47:     --output text \
48:     | tr '\t' '\n' \
49:     | sed '/^$/d'
50: )
51: # For diagnostic completeness, also list every secret under the prefix
52: # (healthy or pending) so an operator can compare against expectations.
53: echo "All secrets under ${PREFIX} (healthy and pending):"
54: aws secretsmanager list-secrets \
55:   --include-planned-deletion \
56:   --filters "Key=name,Values=${PREFIX}" \
57:   --query 'SecretList[].[Name,DeletedDate]' \
58:   --output table || true
59: echo
60: if [ "${#PENDING[@]}" -eq 0 ]; then
61:   echo "No secrets under ${PREFIX} are in PendingDeletion. Nothing to purge."
62:   exit 0
63: fi
64: echo "Found ${#PENDING[@]} pending-deletion secret(s):"
65: printf '  %s\n' "${PENDING[@]}"
66: echo
67: for s in "${PENDING[@]}"; do
68:   echo "purge $s"
69:   aws secretsmanager delete-secret \
70:     --secret-id "$s" \
71:     --force-delete-without-recovery >/dev/null
72: done
73: echo "Purge complete."
````

## File: .github/env.local.example
````
 1: # .github/env.local - Loaded by .actrc as `--env-file`.
 2: #
 3: # Real GitHub-hosted runners ignore this file. It only affects local `act`
 4: # invocations from the repo root. Copy to `.github/env.local` (gitignored)
 5: # and fill in real values.
 6: #
 7: # Purpose: provide static AWS credentials so the act runner can call AWS APIs
 8: # without OIDC. Workflows that require OIDC are guarded with
 9: # `if: ${{ env.ACT != 'true' }}` on their `aws-actions/configure-aws-credentials`
10: # step (see infra-apply.yml, infra-destroy.yml, app-deploy.yml). Under act we
11: # rely on the env-file below to satisfy the AWS SDK chain instead.
12: #
13: # Tip: use a short-lived session token from `aws sts get-session-token` or an
14: # IAM Identity Center role. Do NOT paste long-lived user keys.
15: ACT=true
16: 
17: # Required by AWS SDK.
18: AWS_ACCESS_KEY_ID=ASIA...REPLACE
19: AWS_SECRET_ACCESS_KEY=REPLACE
20: AWS_SESSION_TOKEN=REPLACE
21: AWS_REGION=us-east-1
22: AWS_DEFAULT_REGION=us-east-1
23: 
24: # AWS CLI v2 piping: catthehacker:full-24.04 ships `less`, but keep this set
25: # defensively to match the workflows' inline `AWS_PAGER=""`.
26: AWS_PAGER=
27: 
28: # Force testcontainers to skip the Ryuk reaper container under act
29: # (PID-namespace mismatch when reaching the host daemon via bind-mounted
30: # socket). Same value the backend job sets in ci.yml.
31: TESTCONTAINERS_RYUK_DISABLED=true
32: 
33: # Pin the docker daemon socket to the standard path. catthehacker:full-24.04
34: # already mounts it; setting DOCKER_HOST removes ambiguity in the
35: # docker-java discovery path.
36: DOCKER_HOST=unix:///var/run/docker.sock
````

## File: app/backend/src/main/java/com/talorlik/javaapp/config/AppProperties.java
````java
 1: package com.talorlik.javaapp.config;
 2: import org.springframework.boot.context.properties.ConfigurationProperties;
 3: @ConfigurationProperties(prefix = "app")
 4: public class AppProperties {
 5:     private final Aws aws = new Aws();
 6:     private final Secrets secrets = new Secrets();
 7:     private final Jwt jwt = new Jwt();
 8:     private final Verification verification = new Verification();
 9:     private final RateLimit rateLimit = new RateLimit();
10:     private final Cors cors = new Cors();
11:     private final Ses ses = new Ses();
12:     private final Admin admin = new Admin();
13:     public Aws getAws() { return aws; }
14:     public Secrets getSecrets() { return secrets; }
15:     public Jwt getJwt() { return jwt; }
16:     public Verification getVerification() { return verification; }
17:     public RateLimit getRateLimit() { return rateLimit; }
18:     public Cors getCors() { return cors; }
19:     public Ses getSes() { return ses; }
20:     public Admin getAdmin() { return admin; }
21:     public static class Aws { private String region = "us-east-1";
22:         public String getRegion() { return region; } public void setRegion(String r) { this.region = r; } }
23:     public static class Secrets {
24:         private String jwtSecretName;
25:         private String sesSecretName;
26:         private String adminSecretName;
27:         public String getJwtSecretName() { return jwtSecretName; }
28:         public void setJwtSecretName(String v) { this.jwtSecretName = v; }
29:         public String getSesSecretName() { return sesSecretName; }
30:         public void setSesSecretName(String v) { this.sesSecretName = v; }
31:         public String getAdminSecretName() { return adminSecretName; }
32:         public void setAdminSecretName(String v) { this.adminSecretName = v; }
33:     }
34:     public static class Jwt {
35:         private long expirationMinutes = 60;
36:         // "secrets-manager" (default, prod) or "inline" (local/dev/CI smoke).
37:         // Selected by Spring's @ConditionalOnProperty on the matching
38:         // JwtSecretProvider implementation.
39:         private String secretSource = "secrets-manager";
40:         // Used only when secretSource = "inline". Must be >= 32 bytes for HS256.
41:         private String inlineKey;
42:         private String inlineIssuer = "java-app";
43:         public long getExpirationMinutes() { return expirationMinutes; }
44:         public void setExpirationMinutes(long v) { this.expirationMinutes = v; }
45:         public String getSecretSource() { return secretSource; }
46:         public void setSecretSource(String v) { this.secretSource = v; }
47:         public String getInlineKey() { return inlineKey; }
48:         public void setInlineKey(String v) { this.inlineKey = v; }
49:         public String getInlineIssuer() { return inlineIssuer; }
50:         public void setInlineIssuer(String v) { this.inlineIssuer = v; }
51:     }
52:     public static class Admin {
53:         // When false, AdminSeeder is a no-op. Used to keep local/CI boots
54:         // hermetic - i.e., no Secrets Manager call for the admin password.
55:         private boolean seedEnabled = true;
56:         public boolean isSeedEnabled() { return seedEnabled; }
57:         public void setSeedEnabled(boolean v) { this.seedEnabled = v; }
58:     }
59:     public static class Verification {
60:         private int codeLength = 6;
61:         private int ttlMinutes = 30;
62:         private int maxAttempts = 5;
63:         public int getCodeLength() { return codeLength; } public void setCodeLength(int v) { codeLength = v; }
64:         public int getTtlMinutes() { return ttlMinutes; } public void setTtlMinutes(int v) { ttlMinutes = v; }
65:         public int getMaxAttempts() { return maxAttempts; } public void setMaxAttempts(int v) { maxAttempts = v; }
66:     }
67:     public static class RateLimit {
68:         private int loginPerMinute = 10;
69:         private int verifyPerMinute = 10;
70:         private int signupPerHour = 20;
71:         public int getLoginPerMinute() { return loginPerMinute; } public void setLoginPerMinute(int v) { loginPerMinute = v; }
72:         public int getVerifyPerMinute() { return verifyPerMinute; } public void setVerifyPerMinute(int v) { verifyPerMinute = v; }
73:         public int getSignupPerHour() { return signupPerHour; } public void setSignupPerHour(int v) { signupPerHour = v; }
74:     }
75:     public static class Cors {
76:         private String allowedOrigin;
77:         public String getAllowedOrigin() { return allowedOrigin; } public void setAllowedOrigin(String v) { allowedOrigin = v; }
78:     }
79:     public static class Ses {
80:         private boolean enabled = true;
81:         public boolean isEnabled() { return enabled; } public void setEnabled(boolean v) { enabled = v; }
82:     }
83: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/domain/AuditEvent.java
````java
 1: package com.talorlik.javaapp.domain;
 2: import jakarta.persistence.*;
 3: import java.time.Instant;
 4: @Entity
 5: @Table(name = "audit_events")
 6: public class AuditEvent {
 7:     @Id
 8:     @GeneratedValue(strategy = GenerationType.IDENTITY)
 9:     private Long id;
10:     @Column(name = "actor_id")
11:     private Long actorId;
12:     @Column(name = "actor_email")
13:     private String actorEmail;
14:     @Column(nullable = false, length = 100)
15:     private String action;
16:     @Column(length = 255)
17:     private String target;
18:     // JSON column - persisted as string. Avoid storing sensitive data here.
19:     // columnDefinition pins Hibernate schema validation to the MySQL JSON
20:     // type used by V4__create_audit_events.sql; without this, @Lob on a
21:     // String maps to TINYTEXT/CLOB and validation fails against JSON.
22:     @Column(name = "metadata", columnDefinition = "json")
23:     private String metadata;
24:     @Column(name = "created_at", nullable = false, updatable = false)
25:     private Instant createdAt;
26:     @PrePersist
27:     void onCreate() { createdAt = Instant.now(); }
28:     public static AuditEvent of(String action, Long actorId, String actorEmail, String target, String metadataJson) {
29:         AuditEvent e = new AuditEvent();
30:         e.action = action;
31:         e.actorId = actorId;
32:         e.actorEmail = actorEmail;
33:         e.target = target;
34:         e.metadata = metadataJson;
35:         return e;
36:     }
37:     public Long getId() { return id; }
38:     public Long getActorId() { return actorId; }
39:     public String getActorEmail() { return actorEmail; }
40:     public String getAction() { return action; }
41:     public String getTarget() { return target; }
42:     public String getMetadata() { return metadata; }
43:     public Instant getCreatedAt() { return createdAt; }
44: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/init/AdminSeeder.java
````java
 1: package com.talorlik.javaapp.init;
 2: import com.fasterxml.jackson.databind.JsonNode;
 3: import com.fasterxml.jackson.databind.ObjectMapper;
 4: import com.talorlik.javaapp.config.AppProperties;
 5: import com.talorlik.javaapp.domain.Role;
 6: import com.talorlik.javaapp.domain.User;
 7: import com.talorlik.javaapp.repository.RoleRepository;
 8: import com.talorlik.javaapp.repository.UserRepository;
 9: import org.slf4j.Logger;
10: import org.slf4j.LoggerFactory;
11: import org.springframework.boot.context.event.ApplicationReadyEvent;
12: import org.springframework.context.event.EventListener;
13: import org.springframework.security.crypto.password.PasswordEncoder;
14: import org.springframework.stereotype.Component;
15: import org.springframework.transaction.annotation.Transactional;
16: import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
17: import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
18: import java.util.HashSet;
19: import java.util.List;
20: /**
21:  * Reads /java-app/prod/admin from Secrets Manager and inserts the admin user
22:  * if absent. Runs once at startup. Never logs the password.
23:  */
24: @Component
25: public class AdminSeeder {
26:     private static final Logger log = LoggerFactory.getLogger(AdminSeeder.class);
27:     private final SecretsManagerClient sm;
28:     private final UserRepository users;
29:     private final RoleRepository roles;
30:     private final PasswordEncoder encoder;
31:     private final AppProperties props;
32:     private final ObjectMapper mapper = new ObjectMapper();
33:     public AdminSeeder(SecretsManagerClient sm,
34:                        UserRepository users,
35:                        RoleRepository roles,
36:                        PasswordEncoder encoder,
37:                        AppProperties props) {
38:         this.sm = sm;
39:         this.users = users;
40:         this.roles = roles;
41:         this.encoder = encoder;
42:         this.props = props;
43:     }
44:     @EventListener(ApplicationReadyEvent.class)
45:     @Transactional
46:     public void seed() {
47:         if (!props.getAdmin().isSeedEnabled()) {
48:             // Hermetic local/CI: no Secrets Manager call, no admin row.
49:             log.info("AdminSeeder disabled by config (app.admin.seed-enabled=false)");
50:             return;
51:         }
52:         try {
53:             var resp = sm.getSecretValue(GetSecretValueRequest.builder()
54:                 .secretId(props.getSecrets().getAdminSecretName())
55:                 .build());
56:             JsonNode json = mapper.readTree(resp.secretString());
57:             String email = json.get("username").asText().toLowerCase();
58:             String password = json.get("password").asText();
59:             if (users.existsByEmailIgnoreCase(email)) {
60:                 log.info("Admin user already present (idempotent skip)");
61:                 return;
62:             }
63:             Role admin = roles.findByName(Role.ADMIN).orElseThrow();
64:             Role user  = roles.findByName(Role.USER).orElseThrow();
65:             User u = new User();
66:             u.setEmail(email);
67:             u.setFullName("Administrator");
68:             u.setPasswordHash(encoder.encode(password));
69:             u.setVerified(true);
70:             u.setEnabled(true);
71:             u.setRoles(new HashSet<>(List.of(admin, user)));
72:             users.save(u);
73:             // Do not log the password. Email is fine; it's not secret.
74:             log.info("Admin user seeded: {}", email);
75:         } catch (Exception e) {
76:             log.error("Admin seed failed: {}", e.getClass().getSimpleName());
77:             // Re-throwing would block startup. Better to keep app available.
78:         }
79:     }
80: }
````

## File: app/backend/src/main/java/com/talorlik/javaapp/security/JwtService.java
````java
 1: package com.talorlik.javaapp.security;
 2: import com.talorlik.javaapp.config.AppProperties;
 3: import io.jsonwebtoken.Claims;
 4: import io.jsonwebtoken.Jwts;
 5: import io.jsonwebtoken.security.Keys;
 6: import jakarta.annotation.PostConstruct;
 7: import org.springframework.stereotype.Component;
 8: import javax.crypto.SecretKey;
 9: import java.nio.charset.StandardCharsets;
10: import java.util.Date;
11: import java.util.List;
12: import java.util.Map;
13: /**
14:  * Builds and parses HMAC-signed JWTs. The signing key is obtained from a
15:  * {@link JwtSecretProvider} at startup (single-shot read; not rotated
16:  * mid-process). The provider implementation is selected by the
17:  * {@code app.jwt.secret-source} property; in production this resolves to
18:  * Secrets Manager, in local/CI smoke to an inline key.
19:  */
20: @Component
21: public class JwtService {
22:     private final AppProperties props;
23:     private final JwtSecretProvider secretProvider;
24:     private SecretKey key;
25:     private String issuer;
26:     public JwtService(AppProperties props, JwtSecretProvider secretProvider) {
27:         this.props = props;
28:         this.secretProvider = secretProvider;
29:     }
30:     @PostConstruct
31:     void init() {
32:         JwtSecretProvider.JwtMaterial m = secretProvider.load();
33:         this.issuer = (m.issuer() != null && !m.issuer().isBlank())
34:             ? m.issuer()
35:             : "java-app";
36:         // jjwt requires >= 256-bit key for HS256. The inline provider enforces
37:         // this at construction; the SM provider trusts the secret payload.
38:         this.key = Keys.hmacShaKeyFor(m.signingKey().getBytes(StandardCharsets.UTF_8));
39:     }
40:     public String issueToken(String subject, List<String> roles) {
41:         long now = System.currentTimeMillis();
42:         long exp = now + props.getJwt().getExpirationMinutes() * 60_000L;
43:         return Jwts.builder()
44:             .issuer(issuer)
45:             .subject(subject)
46:             .issuedAt(new Date(now))
47:             .expiration(new Date(exp))
48:             .claims(Map.of("roles", roles))
49:             .signWith(key, Jwts.SIG.HS256)
50:             .compact();
51:     }
52:     public Claims parse(String token) {
53:         return Jwts.parser()
54:             .verifyWith(key)
55:             .requireIssuer(issuer)
56:             .build()
57:             .parseSignedClaims(token)
58:             .getPayload();
59:     }
60:     public long expirationSeconds() {
61:         return props.getJwt().getExpirationMinutes() * 60L;
62:     }
63: }
````

## File: app/backend/src/test/java/com/talorlik/javaapp/integration/MigrationsIT.java
````java
 1: package com.talorlik.javaapp.integration;
 2: import org.junit.jupiter.api.Test;
 3: import org.springframework.beans.factory.annotation.Autowired;
 4: import org.springframework.boot.test.context.SpringBootTest;
 5: import org.springframework.test.context.ActiveProfiles;
 6: import org.springframework.test.context.DynamicPropertyRegistry;
 7: import org.springframework.test.context.DynamicPropertySource;
 8: import org.testcontainers.containers.MySQLContainer;
 9: import org.testcontainers.junit.jupiter.Container;
10: import org.testcontainers.junit.jupiter.Testcontainers;
11: import javax.sql.DataSource;
12: import static org.assertj.core.api.Assertions.assertThat;
13: @Testcontainers
14: @SpringBootTest(properties = {
15:     "app.ses.enabled=false",
16:     "app.secrets.jwt-secret-name=disabled",
17:     "app.secrets.ses-secret-name=disabled",
18:     "app.secrets.admin-secret-name=disabled"
19: })
20: @ActiveProfiles("test")
21: class MigrationsIT {
22:     @Container
23:     static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.4")
24:         .withDatabaseName("javaapp")
25:         .withUsername("test")
26:         .withPassword("test");
27:     @DynamicPropertySource
28:     static void props(DynamicPropertyRegistry r) {
29:         r.add("spring.datasource.url", mysql::getJdbcUrl);
30:         r.add("spring.datasource.username", mysql::getUsername);
31:         r.add("spring.datasource.password", mysql::getPassword);
32:         r.add("spring.datasource.driver-class-name", () -> "com.mysql.cj.jdbc.Driver");
33:     }
34:     @Autowired DataSource ds;
35:     @Test
36:     void datasource_is_initialized() {
37:         assertThat(ds).isNotNull();
38:     }
39: }
````

## File: app/docker/env.template
````
 1: # EC2 user-data renders /opt/java-app/.env from this template at boot.
 2: # Values come from SSM Parameter Store + Secrets Manager.
 3: 
 4: RELEASE_ID=
 5: BACKEND_IMAGE=
 6: FRONTEND_IMAGE=
 7: 
 8: AWS_REGION=us-east-1
 9: 
10: DB_HOST=
11: DB_PORT=3306
12: DB_NAME=javaapp
13: DB_USERNAME=
14: DB_PASSWORD=
15: 
16: JWT_SECRET_NAME=/java-app/prod/jwt
17: SES_SECRET_NAME=/java-app/prod/ses
18: ADMIN_SECRET_NAME=/java-app/prod/admin
19: 
20: APP_PUBLIC_URL=https://java.talorlik.com
````

## File: app/frontend/src/index.html
````html
 1: <!doctype html>
 2: <html lang="en">
 3: <head>
 4:   <meta charset="utf-8" />
 5:   <meta name="viewport" content="width=device-width, initial-scale=1" />
 6:   <title>Dockerized Java App on EC2</title>
 7:   <link rel="stylesheet" href="/css/main.css" />
 8: </head>
 9: <body>
10:   <header class="topbar">
11:     <a class="brand" href="/">java.talorlik.com</a>
12:     <nav id="nav"></nav>
13:   </header>
14:   <main id="app"></main>
15:   <footer class="bottombar">
16:     <span>Dockerized Java App on EC2</span>
17:   </footer>
18:   <script type="module" src="/js/app.js"></script>
19: </body>
20: </html>
````

## File: docs/auxiliary/architecture-diagrams/generated-python.py
````python
  1: #!/usr/bin/env python3
  2: """
  3: Generate a unified AWS architecture diagram for this repository.
  4: Outputs:
  5: - docs/auxiliary/architecture-diagrams/diagrams/java_app_architecture.png
  6: - docs/auxiliary/architecture-diagrams/diagrams/java_app_architecture.dot
  7: - docs/auxiliary/architecture-diagrams/diagrams/java_app_architecture.drawio
  8: """
  9: from __future__ import annotations
 10: import json
 11: import os
 12: import subprocess
 13: import sys
 14: from pathlib import Path
 15: from diagrams import Cluster, Diagram, Edge
 16: from diagrams.aws.compute import AutoScaling, EC2, ECR
 17: from diagrams.aws.database import RDS
 18: from diagrams.aws.management import Cloudwatch, CloudwatchLogs
 19: from diagrams.aws.management import SystemsManagerParameterStore
 20: from diagrams.aws.network import (
 21:     InternetGateway,
 22:     NATGateway,
 23:     PrivateSubnet,
 24:     PublicSubnet,
 25:     Route53,
 26:     Route53HostedZone,
 27:     VPC,
 28:     ElbApplicationLoadBalancer,
 29: )
 30: from diagrams.aws.security import CertificateManager, IAMRole, SecretsManager, WAF
 31: from diagrams.aws.storage import S3
 32: from diagrams.generic.compute import Rack
 33: from diagrams.generic.database import SQL
 34: from diagrams.generic.network import Firewall
 35: from diagrams.onprem.ci import GithubActions
 36: from diagrams.onprem.client import Users
 37: SCRIPT_DIR = Path(__file__).resolve().parent
 38: REPO_ROOT = SCRIPT_DIR.parent.parent.parent
 39: OUTPUT_DIR = SCRIPT_DIR / "diagrams"
 40: OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
 41: TIER_COLORS = {
 42:     "EDGE_DNS": "#E3F2FD",
 43:     "INGRESS": "#E8EAF6",
 44:     "NETWORK": "#E0F7FA",
 45:     "COMPUTE": "#E8F5E9",
 46:     "DELIVERY_RELEASE": "#F3E5F5",
 47:     "DATA": "#FFF3E0",
 48:     "STORAGE": "#FFF8E1",
 49:     "SECURITY_CONFIG": "#FFEBEE",
 50:     "OBSERVABILITY": "#ECEFF1",
 51: }
 52: def cluster_attrs(bg: str) -> dict:
 53:     return {"style": "filled", "color": bg}
 54: def _load_plan(path: Path) -> dict:
 55:     if not path.exists():
 56:         return {}
 57:     try:
 58:         return json.loads(path.read_text(encoding="utf-8"))
 59:     except (json.JSONDecodeError, OSError):
 60:         return {}
 61: def _extract_type_set(plan: dict) -> set[str]:
 62:     resource_types: set[str] = set()
 63:     for change in plan.get("resource_changes", []):
 64:         rtype = change.get("type")
 65:         if rtype:
 66:             resource_types.add(rtype)
 67:     return resource_types
 68: def _collect_plan_context() -> dict:
 69:     bootstrap_plan = _load_plan(REPO_ROOT / "infra/bootstrap/tfplan.bootstrap.json")
 70:     prod_plan = _load_plan(REPO_ROOT / "infra/envs/prod/tfplan.prod.json")
 71:     bootstrap_types = _extract_type_set(bootstrap_plan)
 72:     prod_types = _extract_type_set(prod_plan)
 73:     return {
 74:         "bootstrap_present": bool(bootstrap_plan),
 75:         "prod_present": bool(prod_plan),
 76:         "bootstrap_types": bootstrap_types,
 77:         "prod_types": prod_types,
 78:     }
 79: def _convert_dot_to_drawio(dot_path: Path, drawio_path: Path) -> None:
 80:     try:
 81:         subprocess.run(
 82:             ["graphviz2drawio", str(dot_path), "-o", str(drawio_path)],
 83:             check=True,
 84:             capture_output=True,
 85:             text=True,
 86:         )
 87:     except (FileNotFoundError, subprocess.CalledProcessError):
 88:         pass
 89: def build_diagram() -> str:
 90:     context = _collect_plan_context()
 91:     filename = "java_app_architecture"
 92:     previous_cwd = Path.cwd()
 93:     os.chdir(OUTPUT_DIR)
 94:     try:
 95:         with Diagram(
 96:             "Dockerized Java App on AWS EC2 (Unified Architecture)",
 97:             filename=filename,
 98:             outformat=["png", "dot"],
 99:             show=False,
100:             direction="TB",
101:             graph_attr={"splines": "ortho", "nodesep": "0.7", "ranksep": "0.9"},
102:         ):
103:             users = Users("End Users")
104:             github = GithubActions("GitHub Actions\n(ci/infra/app-deploy)")
105:             with Cluster("DOMAIN ACCOUNT", graph_attr=cluster_attrs(TIER_COLORS["EDGE_DNS"])):
106:                 registered_domain = Firewall("Registered Domain\n(talorlik.com)")
107:                 hosted_zone = Route53HostedZone("Route 53 Hosted Zone")
108:                 domain_dns_role = IAMRole("Route 53 DNS Role\n(cross-account)")
109:             with Cluster(
110:                 "DEPLOYMENT ACCOUNT",
111:                 graph_attr=cluster_attrs(TIER_COLORS["NETWORK"]),
112:             ):
113:                 with Cluster(
114:                     "EDGE AND DNS",
115:                     graph_attr=cluster_attrs(TIER_COLORS["EDGE_DNS"]),
116:                 ):
117:                     route53_alias = Route53("java.talorlik.com")
118:                     acm = CertificateManager("ACM Certificate")
119:                     waf = WAF("WAFv2 Web ACL")
120:                     alb = ElbApplicationLoadBalancer("ALB\nHTTPS 443 -> HTTP 8080")
121:                 with Cluster(
122:                     "SECURITY AND CONFIG",
123:                     graph_attr=cluster_attrs(TIER_COLORS["SECURITY_CONFIG"]),
124:                 ):
125:                     oidc_role = IAMRole("github-role\n(OIDC trusted)")
126:                     ec2_profile = IAMRole("EC2 Instance Profile")
127:                     secrets = SecretsManager("Secrets Manager")
128:                     ssm_params = SystemsManagerParameterStore("Parameter Store")
129:                 with Cluster("DELIVERY", graph_attr=cluster_attrs(TIER_COLORS["DELIVERY_RELEASE"])):
130:                     ecr = ECR("ECR backend/frontend")
131:                 with Cluster("NETWORK", graph_attr=cluster_attrs(TIER_COLORS["NETWORK"])):
132:                     vpc = VPC("VPC")
133:                     igw = InternetGateway("Internet Gateway")
134:                     nat = NATGateway("NAT Gateway")
135:                     with Cluster("Public Subnets", graph_attr=cluster_attrs(TIER_COLORS["INGRESS"])):
136:                         pub_a = PublicSubnet("Public Subnet A")
137:                         pub_b = PublicSubnet("Public Subnet B")
138:                     with Cluster("Private App Subnets", graph_attr=cluster_attrs(TIER_COLORS["COMPUTE"])):
139:                         app_a = PrivateSubnet("Private App A")
140:                         app_b = PrivateSubnet("Private App B")
141:                         asg = AutoScaling("EC2 Auto Scaling Group")
142:                         ec2 = EC2("EC2 Instances")
143:                         containers = Rack("Docker Compose\nNginx + Spring Boot")
144:                     with Cluster("DB Subnets", graph_attr=cluster_attrs(TIER_COLORS["DATA"])):
145:                         db_a = PrivateSubnet("Private DB A")
146:                         db_b = PrivateSubnet("Private DB B")
147:                         rds = RDS("RDS MySQL")
148:                 with Cluster(
149:                     "OBSERVABILITY AND STORAGE",
150:                     graph_attr=cluster_attrs(TIER_COLORS["OBSERVABILITY"]),
151:                 ):
152:                     cloudwatch = Cloudwatch("CloudWatch")
153:                     cloudwatch_logs = CloudwatchLogs("CloudWatch Logs")
154:                     alb_logs = S3("S3 ALB Access Logs")
155:                 with Cluster("MESSAGING", graph_attr=cluster_attrs(TIER_COLORS["DATA"])):
156:                     ses = SQL("Amazon SES")
157:             users >> Edge(label="DNS lookup") >> route53_alias
158:             route53_alias >> Edge(label="A/ALIAS") >> hosted_zone
159:             route53_alias >> Edge(label="HTTPS 443") >> waf >> alb
160:             acm >> Edge(label="TLS cert") >> alb
161:             alb >> Edge(label="HTTP 8080") >> asg >> ec2 >> containers
162:             containers >> Edge(label="/api -> backend") >> containers
163:             containers >> Edge(label="MySQL 3306") >> rds
164:             containers >> Edge(label="read secrets") >> secrets
165:             containers >> Edge(label="read release/config") >> ssm_params
166:             containers >> Edge(label="send emails") >> ses
167:             ec2 >> Edge(label="image pull") >> ecr
168:             ec2_profile >> ec2
169:             github >> Edge(label="OIDC") >> oidc_role
170:             oidc_role >> Edge(label="AssumeRole") >> domain_dns_role
171:             github >> Edge(label="build/push") >> ecr
172:             github >> Edge(label="update release pointers") >> ssm_params
173:             github >> Edge(label="instance refresh") >> asg
174:             domain_dns_role >> hosted_zone
175:             registered_domain >> hosted_zone
176:             igw >> pub_a
177:             igw >> pub_b
178:             nat >> app_a
179:             nat >> app_b
180:             vpc >> pub_a
181:             vpc >> pub_b
182:             vpc >> app_a
183:             vpc >> app_b
184:             vpc >> db_a
185:             vpc >> db_b
186:             alb >> Edge(label="access logs") >> alb_logs
187:             ec2 >> cloudwatch_logs >> cloudwatch
188:             rds >> cloudwatch
189:             alb >> cloudwatch
190:             if context["bootstrap_present"]:
191:                 tf_bootstrap = Rack("Terraform Root\ninfra/bootstrap")
192:                 tf_bootstrap >> Edge(label="state foundation") >> alb_logs
193:             if context["prod_present"]:
194:                 tf_prod = Rack("Terraform Root\ninfra/envs/prod")
195:                 github >> Edge(label="terraform plan/apply") >> tf_prod
196:                 tf_prod >> vpc
197:                 tf_prod >> ssm_params
198:                 tf_prod >> secrets
199:     finally:
200:         os.chdir(previous_cwd)
201:     dot_path = OUTPUT_DIR / f"{filename}.dot"
202:     drawio_path = OUTPUT_DIR / f"{filename}.drawio"
203:     _convert_dot_to_drawio(dot_path, drawio_path)
204:     return filename
205: def main() -> int:
206:     generated = build_diagram()
207:     print(f"Generated diagram artifacts under: {OUTPUT_DIR / generated}")
208:     return 0
209: if __name__ == "__main__":
210:     raise SystemExit(main())
````

## File: docs/dark-theme.css
````css
  1: * {
  2:   margin: 0;
  3:   padding: 0;
  4:   box-sizing: border-box;
  5: }
  6: :root {
  7:   --primary-color: #58a6ff;
  8:   --primary-hover: #79c0ff;
  9:   --bg-color: #0d1117;
 10:   --text-color: #c9d1d9;
 11:   --border-color: #30363d;
 12:   --code-bg: #161b22;
 13:   --nav-bg: #161b22;
 14:   --nav-shadow: rgba(0, 0, 0, 0.5);
 15:   --section-bg: #161b22;
 16:   --table-row-alt: #21262d;
 17:   --link-color: #58a6ff;
 18: }
 19: html {
 20:   scroll-behavior: smooth;
 21: }
 22: body {
 23:   font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
 24:   line-height: 1.6;
 25:   color: var(--text-color);
 26:   background-color: var(--bg-color);
 27:   padding-top: 80px;
 28: }
 29: .skip-link {
 30:   position: absolute;
 31:   left: -9999px;
 32:   z-index: 9999;
 33:   padding: 0.75rem 1rem;
 34:   background: var(--primary-color);
 35:   color: #fff;
 36:   text-decoration: none;
 37:   font-weight: 600;
 38: }
 39: .skip-link:focus {
 40:   left: 0;
 41:   top: 0;
 42:   position: fixed;
 43: }
 44: .navbar {
 45:   position: fixed;
 46:   top: 0;
 47:   left: 0;
 48:   right: 0;
 49:   background-color: var(--nav-bg);
 50:   border-bottom: 1px solid var(--border-color);
 51:   box-shadow: 0 2px 4px var(--nav-shadow);
 52:   z-index: 1000;
 53:   padding: 5px 20px;
 54: }
 55: .nav-container {
 56:   max-width: 1200px;
 57:   margin: 0 auto;
 58:   display: flex;
 59:   justify-content: space-between;
 60:   align-items: center;
 61: }
 62: .nav-logo {
 63:   font-size: 18px;
 64:   font-weight: 600;
 65:   color: var(--text-color);
 66:   text-decoration: none;
 67:   margin-right: 20px;
 68:   white-space: nowrap;
 69: }
 70: .nav-menu {
 71:   display: flex;
 72:   list-style: none;
 73:   gap: 10px;
 74:   align-items: center;
 75: }
 76: .nav-menu li {
 77:   display: flex;
 78:   align-items: center;
 79:   padding: 10px 12px;
 80: }
 81: .nav-menu a {
 82:   color: var(--text-color);
 83:   text-decoration: none;
 84:   font-size: 14px;
 85:   border-bottom: 2px solid transparent;
 86: }
 87: .nav-menu a:hover,
 88: .nav-menu a.active {
 89:   color: var(--primary-color);
 90:   border-bottom-color: var(--primary-color);
 91: }
 92: .mobile-menu-toggle {
 93:   display: none;
 94:   background: none;
 95:   border: none;
 96:   font-size: 24px;
 97:   cursor: pointer;
 98:   padding: 10px;
 99:   color: var(--text-color);
100: }
101: .theme-toggle {
102:   background: none;
103:   border: 1px solid var(--border-color);
104:   border-radius: 6px;
105:   color: var(--text-color);
106:   cursor: pointer;
107:   font-size: 20px;
108:   padding: 4px 10px;
109:   margin-left: 10px;
110: }
111: .theme-toggle .icon.hidden {
112:   display: none;
113: }
114: .hero {
115:   color: var(--text-color);
116:   padding: 60px 20px 0 20px;
117:   text-align: center;
118: }
119: .hero-content {
120:   max-width: 1200px;
121:   margin: 0 auto;
122: }
123: .hero h1 {
124:   font-size: 2.5em;
125:   margin-bottom: 20px;
126:   font-weight: 600;
127: }
128: .hero p {
129:   font-size: 1.2em;
130:   margin-bottom: 30px;
131: }
132: .hero-banner {
133:   max-width: 100%;
134:   height: auto;
135:   margin-top: 30px;
136:   border-radius: 8px;
137:   box-shadow: 0 4px 6px rgba(0, 0, 0, 0.5);
138:   filter: brightness(0.9);
139: }
140: .architecture-diagram-wrapper {
141:   margin: 1.5rem 0 2rem 0;
142:   padding: 0;
143:   border-radius: 8px;
144:   overflow: hidden;
145:   border: 1px solid var(--border-color);
146:   background: var(--section-bg);
147:   box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
148: }
149: .architecture-diagram {
150:   display: block;
151:   max-width: 100%;
152:   height: auto;
153:   width: 100%;
154:   object-fit: contain;
155:   vertical-align: middle;
156: }
157: section {
158:   max-width: 1200px;
159:   margin: 0 auto;
160:   padding: 40px 20px 0 20px;
161:   scroll-margin-top: 100px;
162: }
163: section h2 {
164:   font-size: 2em;
165:   margin-bottom: 20px;
166:   padding-bottom: 10px;
167:   border-bottom: 2px solid var(--border-color);
168: }
169: section h3 {
170:   font-size: 1.5em;
171:   margin-bottom: 15px;
172: }
173: .card {
174:   background: var(--section-bg);
175:   border: 1px solid var(--border-color);
176:   border-radius: 6px;
177:   padding: 20px;
178:   margin-bottom: 20px;
179:   box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
180: }
181: .ask-docs-card {
182:   margin-bottom: 24px;
183: }
184: .ask-docs-inline {
185:   margin-top: 0.75em;
186:   margin-bottom: 0;
187: }
188: .ask-docs-link {
189:   display: inline-flex;
190:   align-items: center;
191:   gap: 10px;
192:   font-size: 1.15em;
193:   font-weight: 600;
194:   padding: 4px 0;
195: }
196: .ask-docs-link:hover {
197:   text-decoration: none;
198:   color: var(--primary-hover);
199: }
200: .ask-docs-icon {
201:   display: inline-flex;
202:   flex-shrink: 0;
203: }
204: .ask-docs-icon svg {
205:   width: 24px;
206:   height: 24px;
207:   color: var(--primary-color);
208: }
209: .ask-docs-link:hover .ask-docs-icon svg {
210:   color: var(--primary-hover);
211: }
212: .doc-grid {
213:   display: grid;
214:   grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
215:   gap: 20px;
216:   margin-top: 20px;
217: }
218: .doc-item {
219:   background: var(--section-bg);
220:   border: 1px solid var(--border-color);
221:   border-radius: 6px;
222:   padding: 15px;
223:   transition: transform 0.2s, box-shadow 0.2s;
224: }
225: .doc-item:hover {
226:   transform: translateY(-2px);
227:   box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
228: }
229: .doc-item a {
230:   font-weight: 500;
231:   display: block;
232:   margin-bottom: 8px;
233: }
234: .doc-item p {
235:   font-size: 0.9em;
236:   color: #8b949e;
237:   margin: 0;
238: }
239: ul, ol {
240:   list-style-position: inside;
241: }
242: a {
243:   color: var(--link-color);
244:   text-decoration: none;
245: }
246: a:hover {
247:   text-decoration: underline;
248: }
249: p {
250:   margin-bottom: 15px;
251: }
252: code {
253:   background-color: var(--code-bg);
254:   padding: 2px 6px;
255:   border-radius: 3px;
256:   border: 1px solid var(--border-color);
257:   color: #f85149;
258: }
259: pre {
260:   background-color: var(--code-bg);
261:   padding: 16px;
262:   border-radius: 6px;
263:   overflow-x: auto;
264:   border: 1px solid var(--border-color);
265: }
266: pre code {
267:   background: none;
268:   padding: 0;
269:   border: none;
270:   color: var(--text-color);
271: }
272: footer {
273:   background-color: var(--section-bg);
274:   border-top: 1px solid var(--border-color);
275:   padding: 30px 20px;
276:   text-align: center;
277:   color: #8b949e;
278: }
279: .scroll-to-top {
280:   position: fixed;
281:   bottom: 30px;
282:   right: 30px;
283:   width: 50px;
284:   height: 50px;
285:   border-radius: 50%;
286:   background-color: rgba(88, 166, 255, 0.15);
287:   border: 2px solid rgba(88, 166, 255, 0.3);
288:   color: var(--primary-color);
289:   cursor: pointer;
290:   display: flex;
291:   align-items: center;
292:   justify-content: center;
293:   z-index: 999;
294:   opacity: 0;
295:   visibility: hidden;
296:   pointer-events: none;
297:   transition: opacity 0.3s ease, visibility 0.3s ease;
298: }
299: .scroll-to-top.visible {
300:   opacity: 1;
301:   visibility: visible;
302:   pointer-events: auto;
303: }
304: @media (max-width: 768px) {
305:   .mobile-menu-toggle {
306:     display: block;
307:   }
308:   .nav-menu {
309:     position: fixed;
310:     left: -100%;
311:     top: 60px;
312:     flex-direction: column;
313:     background-color: var(--nav-bg);
314:     width: 100%;
315:     text-align: center;
316:     transition: 0.3s;
317:     padding: 20px 0;
318:     border-bottom: 1px solid var(--border-color);
319:   }
320:   .nav-menu.active {
321:     left: 0;
322:   }
323:   .nav-logo {
324:     margin-right: 0;
325:     max-width: calc(100% - 60px);
326:     overflow: hidden;
327:     text-overflow: ellipsis;
328:   }
329:   .nav-menu li {
330:     width: 100%;
331:   }
332:   .nav-menu a {
333:     padding: 15px;
334:     border-bottom: none;
335:     border-left: 3px solid transparent;
336:   }
337:   .nav-menu a:hover,
338:   .nav-menu a.active {
339:     border-left-color: var(--primary-color);
340:     border-bottom-color: transparent;
341:   }
342:   .theme-toggle {
343:     margin-left: 0;
344:     margin-top: 10px;
345:   }
346:   .hero {
347:     padding-top: 40px;
348:   }
349:   .hero h1 {
350:     font-size: 2em;
351:   }
352:   .hero p {
353:     font-size: 1em;
354:   }
355:   section {
356:     padding-left: 16px;
357:     padding-right: 16px;
358:   }
359:   section h2 {
360:     font-size: 1.5em;
361:   }
362:   section h3 {
363:     font-size: 1.3em;
364:   }
365:   .doc-grid {
366:     grid-template-columns: 1fr;
367:   }
368:   .ask-docs-link {
369:     font-size: 1.05em;
370:   }
371:   .scroll-to-top {
372:     bottom: 20px;
373:     right: 20px;
374:     width: 45px;
375:     height: 45px;
376:   }
377:   .scroll-to-top svg {
378:     width: 20px;
379:     height: 20px;
380:   }
381: }
382: @media (max-width: 480px) {
383:   body {
384:     padding-top: 72px;
385:   }
386:   .navbar {
387:     padding-left: 12px;
388:     padding-right: 12px;
389:   }
390:   .nav-logo {
391:     font-size: 16px;
392:     max-width: calc(100% - 52px);
393:   }
394:   .mobile-menu-toggle {
395:     padding: 8px;
396:     font-size: 22px;
397:   }
398:   .hero {
399:     padding-top: 28px;
400:   }
401:   .hero h1 {
402:     font-size: 1.65em;
403:     line-height: 1.25;
404:   }
405:   .hero p {
406:     font-size: 0.95em;
407:     margin-bottom: 20px;
408:   }
409:   .hero-banner {
410:     margin-top: 20px;
411:   }
412:   section {
413:     padding-top: 28px;
414:     padding-left: 12px;
415:     padding-right: 12px;
416:     scroll-margin-top: 84px;
417:   }
418:   section h2 {
419:     font-size: 1.35em;
420:     margin-bottom: 14px;
421:   }
422:   section h3 {
423:     font-size: 1.15em;
424:     margin-bottom: 12px;
425:   }
426:   .card {
427:     padding: 14px;
428:     margin-bottom: 14px;
429:   }
430:   .doc-grid {
431:     gap: 14px;
432:     margin-top: 14px;
433:   }
434:   .ask-docs-link {
435:     font-size: 1em;
436:     gap: 8px;
437:   }
438:   .ask-docs-icon svg {
439:     width: 22px;
440:     height: 22px;
441:   }
442:   .architecture-diagram-wrapper {
443:     margin: 1rem 0 1.25rem 0;
444:   }
445:   .scroll-to-top {
446:     bottom: 16px;
447:     right: 16px;
448:     width: 42px;
449:     height: 42px;
450:   }
451: }
````

## File: docs/light-theme.css
````css
  1: * {
  2:   margin: 0;
  3:   padding: 0;
  4:   box-sizing: border-box;
  5: }
  6: :root {
  7:   --primary-color: #0366d6;
  8:   --primary-hover: #0256c2;
  9:   --bg-color: #ffffff;
 10:   --text-color: #24292e;
 11:   --border-color: #e1e4e8;
 12:   --code-bg: #f6f8fa;
 13:   --nav-bg: #ffffff;
 14:   --nav-shadow: rgba(0, 0, 0, 0.1);
 15:   --section-bg: #fafbfc;
 16:   --table-row-alt: #f6f8fa;
 17:   --link-color: #0366d6;
 18: }
 19: html {
 20:   scroll-behavior: smooth;
 21: }
 22: body {
 23:   font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
 24:   line-height: 1.6;
 25:   color: var(--text-color);
 26:   background-color: var(--bg-color);
 27:   padding-top: 80px;
 28: }
 29: .skip-link {
 30:   position: absolute;
 31:   left: -9999px;
 32:   z-index: 9999;
 33:   padding: 0.75rem 1rem;
 34:   background: var(--primary-color);
 35:   color: #fff;
 36:   text-decoration: none;
 37:   font-weight: 600;
 38: }
 39: .skip-link:focus {
 40:   left: 0;
 41:   top: 0;
 42:   position: fixed;
 43: }
 44: .navbar {
 45:   position: fixed;
 46:   top: 0;
 47:   left: 0;
 48:   right: 0;
 49:   background-color: var(--nav-bg);
 50:   border-bottom: 1px solid var(--border-color);
 51:   box-shadow: 0 2px 4px var(--nav-shadow);
 52:   z-index: 1000;
 53:   padding: 5px 20px;
 54: }
 55: .nav-container {
 56:   max-width: 1200px;
 57:   margin: 0 auto;
 58:   display: flex;
 59:   justify-content: space-between;
 60:   align-items: center;
 61: }
 62: .nav-logo {
 63:   font-size: 18px;
 64:   font-weight: 600;
 65:   color: var(--text-color);
 66:   text-decoration: none;
 67:   margin-right: 20px;
 68:   white-space: nowrap;
 69: }
 70: .nav-menu {
 71:   display: flex;
 72:   list-style: none;
 73:   gap: 10px;
 74:   align-items: center;
 75: }
 76: .nav-menu li {
 77:   display: flex;
 78:   align-items: center;
 79:   padding: 10px 12px;
 80: }
 81: .nav-menu a {
 82:   color: var(--text-color);
 83:   text-decoration: none;
 84:   font-size: 14px;
 85:   border-bottom: 2px solid transparent;
 86: }
 87: .nav-menu a:hover,
 88: .nav-menu a.active {
 89:   color: var(--primary-color);
 90:   border-bottom-color: var(--primary-color);
 91: }
 92: .mobile-menu-toggle {
 93:   display: none;
 94:   background: none;
 95:   border: none;
 96:   font-size: 24px;
 97:   cursor: pointer;
 98:   padding: 10px;
 99:   color: var(--text-color);
100: }
101: .theme-toggle {
102:   background: none;
103:   border: 1px solid var(--border-color);
104:   border-radius: 6px;
105:   color: var(--text-color);
106:   cursor: pointer;
107:   font-size: 20px;
108:   padding: 4px 10px;
109:   margin-left: 10px;
110: }
111: .theme-toggle .icon.hidden {
112:   display: none;
113: }
114: .hero {
115:   color: var(--text-color);
116:   padding: 60px 20px 0 20px;
117:   text-align: center;
118: }
119: .hero-content {
120:   max-width: 1200px;
121:   margin: 0 auto;
122: }
123: .hero h1 {
124:   font-size: 2.5em;
125:   margin-bottom: 20px;
126:   font-weight: 600;
127: }
128: .hero p {
129:   font-size: 1.2em;
130:   margin-bottom: 30px;
131: }
132: .hero-banner {
133:   max-width: 100%;
134:   height: auto;
135:   margin-top: 30px;
136:   border-radius: 8px;
137:   box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
138: }
139: .architecture-diagram-wrapper {
140:   margin: 1.5rem 0 2rem 0;
141:   padding: 0;
142:   border-radius: 8px;
143:   overflow: hidden;
144:   border: 1px solid var(--border-color);
145:   background: var(--section-bg);
146:   box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
147: }
148: .architecture-diagram {
149:   display: block;
150:   max-width: 100%;
151:   height: auto;
152:   width: 100%;
153:   object-fit: contain;
154:   vertical-align: middle;
155: }
156: section {
157:   max-width: 1200px;
158:   margin: 0 auto;
159:   padding: 40px 20px 0 20px;
160:   scroll-margin-top: 100px;
161: }
162: section h2 {
163:   font-size: 2em;
164:   margin-bottom: 20px;
165:   padding-bottom: 10px;
166:   border-bottom: 2px solid var(--border-color);
167: }
168: section h3 {
169:   font-size: 1.5em;
170:   margin-bottom: 15px;
171: }
172: .card {
173:   background: var(--bg-color);
174:   border: 1px solid var(--border-color);
175:   border-radius: 6px;
176:   padding: 20px;
177:   margin-bottom: 20px;
178:   box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
179: }
180: .ask-docs-card {
181:   margin-bottom: 24px;
182: }
183: .ask-docs-inline {
184:   margin-top: 0.75em;
185:   margin-bottom: 0;
186: }
187: .ask-docs-link {
188:   display: inline-flex;
189:   align-items: center;
190:   gap: 10px;
191:   font-size: 1.15em;
192:   font-weight: 600;
193:   padding: 4px 0;
194: }
195: .ask-docs-link:hover {
196:   text-decoration: none;
197:   color: var(--primary-hover);
198: }
199: .ask-docs-icon {
200:   display: inline-flex;
201:   flex-shrink: 0;
202: }
203: .ask-docs-icon svg {
204:   width: 24px;
205:   height: 24px;
206:   color: var(--primary-color);
207: }
208: .ask-docs-link:hover .ask-docs-icon svg {
209:   color: var(--primary-hover);
210: }
211: .doc-grid {
212:   display: grid;
213:   grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
214:   gap: 20px;
215:   margin-top: 20px;
216: }
217: .doc-item {
218:   background: var(--section-bg);
219:   border: 1px solid var(--border-color);
220:   border-radius: 6px;
221:   padding: 15px;
222:   transition: transform 0.2s, box-shadow 0.2s;
223: }
224: .doc-item:hover {
225:   transform: translateY(-2px);
226:   box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
227: }
228: .doc-item a {
229:   font-weight: 500;
230:   display: block;
231:   margin-bottom: 8px;
232: }
233: .doc-item p {
234:   font-size: 0.9em;
235:   color: #586069;
236:   margin: 0;
237: }
238: ul, ol {
239:   list-style-position: inside;
240: }
241: a {
242:   color: var(--link-color);
243:   text-decoration: none;
244: }
245: a:hover {
246:   text-decoration: underline;
247: }
248: p {
249:   margin-bottom: 15px;
250: }
251: code {
252:   background-color: var(--code-bg);
253:   padding: 2px 6px;
254:   border-radius: 3px;
255:   border: 1px solid var(--border-color);
256:   color: #d73a49;
257: }
258: pre {
259:   background-color: var(--code-bg);
260:   padding: 16px;
261:   border-radius: 6px;
262:   overflow-x: auto;
263:   border: 1px solid var(--border-color);
264: }
265: pre code {
266:   background: none;
267:   padding: 0;
268:   border: none;
269:   color: var(--text-color);
270: }
271: footer {
272:   background-color: var(--section-bg);
273:   border-top: 1px solid var(--border-color);
274:   padding: 30px 20px;
275:   text-align: center;
276:   color: #586069;
277: }
278: .scroll-to-top {
279:   position: fixed;
280:   bottom: 30px;
281:   right: 30px;
282:   width: 50px;
283:   height: 50px;
284:   border-radius: 50%;
285:   background-color: rgba(3, 102, 214, 0.15);
286:   border: 2px solid rgba(3, 102, 214, 0.3);
287:   color: var(--primary-color);
288:   cursor: pointer;
289:   display: flex;
290:   align-items: center;
291:   justify-content: center;
292:   z-index: 999;
293:   opacity: 0;
294:   visibility: hidden;
295:   pointer-events: none;
296:   transition: opacity 0.3s ease, visibility 0.3s ease;
297: }
298: .scroll-to-top.visible {
299:   opacity: 1;
300:   visibility: visible;
301:   pointer-events: auto;
302: }
303: @media (max-width: 768px) {
304:   .mobile-menu-toggle {
305:     display: block;
306:   }
307:   .nav-menu {
308:     position: fixed;
309:     left: -100%;
310:     top: 60px;
311:     flex-direction: column;
312:     background-color: var(--nav-bg);
313:     width: 100%;
314:     text-align: center;
315:     transition: 0.3s;
316:     padding: 20px 0;
317:     border-bottom: 1px solid var(--border-color);
318:   }
319:   .nav-menu.active {
320:     left: 0;
321:   }
322:   .nav-logo {
323:     margin-right: 0;
324:     max-width: calc(100% - 60px);
325:     overflow: hidden;
326:     text-overflow: ellipsis;
327:   }
328:   .nav-menu li {
329:     width: 100%;
330:   }
331:   .nav-menu a {
332:     padding: 15px;
333:     border-bottom: none;
334:     border-left: 3px solid transparent;
335:   }
336:   .nav-menu a:hover,
337:   .nav-menu a.active {
338:     border-left-color: var(--primary-color);
339:     border-bottom-color: transparent;
340:   }
341:   .theme-toggle {
342:     margin-left: 0;
343:     margin-top: 10px;
344:   }
345:   .hero {
346:     padding-top: 40px;
347:   }
348:   .hero h1 {
349:     font-size: 2em;
350:   }
351:   .hero p {
352:     font-size: 1em;
353:   }
354:   section {
355:     padding-left: 16px;
356:     padding-right: 16px;
357:   }
358:   section h2 {
359:     font-size: 1.5em;
360:   }
361:   section h3 {
362:     font-size: 1.3em;
363:   }
364:   .doc-grid {
365:     grid-template-columns: 1fr;
366:   }
367:   .ask-docs-link {
368:     font-size: 1.05em;
369:   }
370:   .scroll-to-top {
371:     bottom: 20px;
372:     right: 20px;
373:     width: 45px;
374:     height: 45px;
375:   }
376:   .scroll-to-top svg {
377:     width: 20px;
378:     height: 20px;
379:   }
380: }
381: @media (max-width: 480px) {
382:   body {
383:     padding-top: 72px;
384:   }
385:   .navbar {
386:     padding-left: 12px;
387:     padding-right: 12px;
388:   }
389:   .nav-logo {
390:     font-size: 16px;
391:     max-width: calc(100% - 52px);
392:   }
393:   .mobile-menu-toggle {
394:     padding: 8px;
395:     font-size: 22px;
396:   }
397:   .hero {
398:     padding-top: 28px;
399:   }
400:   .hero h1 {
401:     font-size: 1.65em;
402:     line-height: 1.25;
403:   }
404:   .hero p {
405:     font-size: 0.95em;
406:     margin-bottom: 20px;
407:   }
408:   .hero-banner {
409:     margin-top: 20px;
410:   }
411:   section {
412:     padding-top: 28px;
413:     padding-left: 12px;
414:     padding-right: 12px;
415:     scroll-margin-top: 84px;
416:   }
417:   section h2 {
418:     font-size: 1.35em;
419:     margin-bottom: 14px;
420:   }
421:   section h3 {
422:     font-size: 1.15em;
423:     margin-bottom: 12px;
424:   }
425:   .card {
426:     padding: 14px;
427:     margin-bottom: 14px;
428:   }
429:   .doc-grid {
430:     gap: 14px;
431:     margin-top: 14px;
432:   }
433:   .ask-docs-link {
434:     font-size: 1em;
435:     gap: 8px;
436:   }
437:   .ask-docs-icon svg {
438:     width: 22px;
439:     height: 22px;
440:   }
441:   .architecture-diagram-wrapper {
442:     margin: 1rem 0 1.25rem 0;
443:   }
444:   .scroll-to-top {
445:     bottom: 16px;
446:     right: 16px;
447:     width: 42px;
448:     height: 42px;
449:   }
450: }
````

## File: infra/bootstrap/outputs.tf
````hcl
 1: output "state_bucket_name" {
 2:   description = "S3 bucket name to use in infra/envs/prod backend block."
 3:   value       = aws_s3_bucket.tfstate.id
 4: }
 5: 
 6: output "state_bucket_arn" {
 7:   description = "S3 bucket ARN."
 8:   value       = aws_s3_bucket.tfstate.arn
 9: }
10: 
11: output "state_kms_key_arn" {
12:   description = "KMS key ARN used for state encryption."
13:   value       = aws_kms_key.tfstate.arn
14: }
15: 
16: output "state_kms_key_alias" {
17:   description = "KMS key alias."
18:   value       = aws_kms_alias.tfstate.name
19: }
20: 
21: output "access_log_bucket_name" {
22:   description = "S3 access-log bucket name (null if disabled)."
23:   value       = try(aws_s3_bucket.access_logs[0].id, null)
24: }
25: 
26: output "backend_block_example" {
27:   description = "Drop this block into infra/envs/prod/backend.tf."
28:   value       = <<EOT
29: terraform {
30:   backend "s3" {
31:     bucket       = "${aws_s3_bucket.tfstate.id}"
32:     key          = "java-app/prod/terraform.tfstate"
33:     region       = "${var.aws_region}"
34:     encrypt      = true
35:     kms_key_id   = "${aws_kms_key.tfstate.arn}"
36:     use_lockfile = true
37:   }
38: }
39: EOT
40: }
````

## File: infra/envs/prod/lambda/db_bootstrap/main.py
````python
  1: """
  2: db_bootstrap Lambda - idempotently provisions the application MySQL user.
  3: Triggered by terraform_data.db_bootstrap on RDS replacement or app-user
  4: secret rotation (see infra/envs/prod/db_bootstrap.tf). Re-invocation is
  5: safe: CREATE USER IF NOT EXISTS is a no-op when the row already exists,
  6: and ALTER USER deterministically syncs the password to whatever the
  7: current /java-app/<env>/db/app-user secret holds.
  8: Required env vars (Terraform sets all of these):
  9:   DB_HOST              - RDS writer endpoint (private DNS).
 10:   DB_PORT              - 3306.
 11:   DB_NAME              - logical schema name to grant on.
 12:   APP_USER             - MySQL username to provision.
 13:   MASTER_SECRET_ARN    - Secrets Manager ARN of the RDS-managed master
 14:                          credential (rotated by RDS).
 15:   APPUSER_SECRET_ARN   - Secrets Manager ARN of the app-user credential
 16:                          (rotated manually per ops guide section 5).
 17: Connection security:
 18:   PyMySQL's `ssl={"ssl": {}}` enables TLS without CA verification.
 19:   Intra-VPC traffic to RDS is the only path that can reach the
 20:   endpoint (see aws_security_group.rds: ingress is referenced-SG only),
 21:   so the absence of CA pinning here does not widen the attack surface
 22:   beyond what the SG already enforces. Tighten to `ca=` pointing at the
 23:   RDS CA bundle if compliance demands explicit cert validation.
 24: """
 25: import json
 26: import logging
 27: import os
 28: import boto3
 29: import pymysql
 30: LOG = logging.getLogger()
 31: LOG.setLevel(logging.INFO)
 32: _sm = boto3.client("secretsmanager")
 33: def _secret(arn: str) -> dict:
 34:     """Fetch a Secrets Manager secret and decode its JSON SecretString."""
 35:     return json.loads(_sm.get_secret_value(SecretId=arn)["SecretString"])
 36: def handler(event, _context):
 37:     db_host = os.environ["DB_HOST"]
 38:     db_port = int(os.environ["DB_PORT"])
 39:     db_name = os.environ["DB_NAME"]
 40:     app_user = os.environ["APP_USER"]
 41:     master = _secret(os.environ["MASTER_SECRET_ARN"])
 42:     appsec = _secret(os.environ["APPUSER_SECRET_ARN"])
 43:     # The app secret is canonical for the app username too; if it ever
 44:     # drifts from the APP_USER env var, prefer the secret so a manual
 45:     # rotation that also renames the user (rare but possible) does not
 46:     # require a Terraform change to converge.
 47:     secret_user = appsec.get("username", app_user)
 48:     if secret_user != app_user:
 49:         LOG.warning(
 50:             "app_user mismatch: env=%s secret=%s; using secret value",
 51:             app_user, secret_user,
 52:         )
 53:     app_user = secret_user
 54:     app_pw = appsec["password"]
 55:     LOG.info(
 56:         "connecting host=%s port=%s db=%s as master=%s",
 57:         db_host, db_port, db_name, master["username"],
 58:     )
 59:     conn = pymysql.connect(
 60:         host=db_host,
 61:         port=db_port,
 62:         user=master["username"],
 63:         password=master["password"],
 64:         ssl={"ssl": {}},
 65:         connect_timeout=10,
 66:         read_timeout=15,
 67:         write_timeout=15,
 68:         autocommit=True,
 69:     )
 70:     # CREATE USER and GRANT in MySQL grammar do not accept parameter
 71:     # binding for identifiers (user, host, schema). Identifiers are
 72:     # constrained: user/host come from controlled sources (env + the
 73:     # backing secret), schema comes from a controlled Terraform variable.
 74:     # The password IS bound via parameter substitution so it never
 75:     # appears in the rendered SQL or any log.
 76:     user_lit = f"'{_escape_ident(app_user)}'@'%'"
 77:     schema_lit = f"`{_escape_ident(db_name)}`"
 78:     # PyMySQL.cursor.execute() does Python `%`-formatting on the query when
 79:     # bind args are passed (cursors.py mogrify -> `query % args`). Any
 80:     # literal `%` in the SQL must therefore be doubled to `%%` for the
 81:     # parameterised path. user_lit contains the host wildcard `'%'`, so
 82:     # it would otherwise be parsed as a format spec and crash with
 83:     # "unsupported format character"). Queries WITHOUT bind args (GRANT
 84:     # below) skip mogrify entirely and use user_lit unchanged.
 85:     user_lit_param = user_lit.replace("%", "%%")
 86:     try:
 87:         with conn.cursor() as cur:
 88:             LOG.info("CREATE USER IF NOT EXISTS %s", user_lit)
 89:             cur.execute(
 90:                 f"CREATE USER IF NOT EXISTS {user_lit_param} "
 91:                 f"IDENTIFIED WITH caching_sha2_password BY %s",
 92:                 (app_pw,),
 93:             )
 94:             LOG.info(
 95:                 "ALTER USER %s (sync password + plugin to caching_sha2_password)",
 96:                 user_lit,
 97:             )
 98:             cur.execute(
 99:                 f"ALTER USER {user_lit_param} "
100:                 f"IDENTIFIED WITH caching_sha2_password BY %s",
101:                 (app_pw,),
102:             )
103:             LOG.info("GRANT ALL PRIVILEGES ON %s.* TO %s", schema_lit, user_lit)
104:             cur.execute(
105:                 f"GRANT ALL PRIVILEGES ON {schema_lit}.* TO {user_lit}"
106:             )
107:             cur.execute("FLUSH PRIVILEGES")
108:             cur.execute(
109:                 "SELECT plugin FROM mysql.user WHERE user=%s AND host='%%'",
110:                 (app_user,),
111:             )
112:             row = cur.fetchone()
113:             plugin = row[0] if row else None
114:     finally:
115:         conn.close()
116:     LOG.info("done; user=%s plugin=%s", app_user, plugin)
117:     return {
118:         "status": "ok",
119:         "user": app_user,
120:         "host": "%",
121:         "schema": db_name,
122:         "plugin": plugin,
123:     }
124: def _escape_ident(value: str) -> str:
125:     """
126:     Escape an identifier for safe inclusion in MySQL DDL.
127:     Backticks inside an identifier must be doubled; same for single
128:     quotes when the identifier is wrapped in single quotes (user names).
129:     Returning the inner content only - the caller wraps in the
130:     appropriate quote style.
131:     """
132:     if value is None:
133:         raise ValueError("identifier must not be None")
134:     return value.replace("`", "``").replace("'", "''")
````

## File: infra/envs/prod/main.tf
````hcl
 1: ###############################################################################
 2: # main.tf
 3: #
 4: # Account-context guard. The actual resources are split across domain-scoped
 5: # files (network.tf, security.tf, secrets.tf, rds.tf, ecr.tf, alb.tf, asg.tf,
 6: # iam.tf, observability.tf, route53.tf).
 7: ###############################################################################
 8: 
 9: data "aws_caller_identity" "current" {}
10: data "aws_partition" "current" {}
11: data "aws_region" "current" {}
12: 
13: # DOMAIN-account caller identity, resolved via the aliased provider that
14: # assumes the Route53 DNS-write role. Used to assert the assumed role lands
15: # in the expected account.
16: data "aws_caller_identity" "domain" {
17:   provider = aws.domain
18: }
19: 
20: # Fail fast if the wrong DEPLOYMENT account is used or the provider region
21: # does not match var.aws_region. Catches a class of footgun where the
22: # operator has stale credentials or a misaligned region. terraform_data is
23: # built-in (no extra provider) and supports lifecycle.precondition.
24: resource "terraform_data" "account_guard" {
25:   input = data.aws_caller_identity.current.account_id
26: 
27:   lifecycle {
28:     precondition {
29:       condition     = data.aws_caller_identity.current.account_id == var.deployment_account_id
30:       error_message = "Active credentials target account ${data.aws_caller_identity.current.account_id} but var.deployment_account_id is ${var.deployment_account_id}."
31:     }
32:     precondition {
33:       condition     = data.aws_region.current.name == var.aws_region
34:       error_message = "AWS provider region ${data.aws_region.current.name} does not match var.aws_region (${var.aws_region})."
35:     }
36:   }
37: }
38: 
39: # Fail fast if the DOMAIN-account assume_role lands in the wrong account.
40: # Same footgun class as account_guard but for the cross-account Route53
41: # provider alias.
42: resource "terraform_data" "domain_account_guard" {
43:   input = data.aws_caller_identity.domain.account_id
44: 
45:   lifecycle {
46:     precondition {
47:       condition     = data.aws_caller_identity.domain.account_id == var.domain_account_id
48:       error_message = "DNS provider assumed into account ${data.aws_caller_identity.domain.account_id} but var.domain_account_id is ${var.domain_account_id}."
49:     }
50:   }
51: }
````

## File: infra/envs/prod/observability.tf
````hcl
  1: ###############################################################################
  2: # Observability - CloudWatch dashboards + alarms + SNS topic.
  3: ###############################################################################
  4: 
  5: # ----------------------------------------------------------------------------
  6: # SNS topic for alarms
  7: # ----------------------------------------------------------------------------
  8: resource "aws_sns_topic" "alarms" {
  9:   name              = "${local.name_prefix}-alarms"
 10:   kms_master_key_id = aws_kms_key.app_secrets.arn
 11:   tags              = local.common_tags
 12: }
 13: 
 14: resource "aws_sns_topic_subscription" "alarm_email" {
 15:   count     = var.alarm_email == "" ? 0 : 1
 16:   topic_arn = aws_sns_topic.alarms.arn
 17:   protocol  = "email"
 18:   endpoint  = var.alarm_email
 19: }
 20: 
 21: # ----------------------------------------------------------------------------
 22: # Alarms - ALB
 23: # ----------------------------------------------------------------------------
 24: resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
 25:   alarm_name          = "${local.name_prefix}-alb-5xx"
 26:   comparison_operator = "GreaterThanThreshold"
 27:   evaluation_periods  = 2
 28:   metric_name         = "HTTPCode_Target_5XX_Count"
 29:   namespace           = "AWS/ApplicationELB"
 30:   period              = 60
 31:   statistic           = "Sum"
 32:   threshold           = 10
 33:   alarm_description   = "ALB target 5xx count > 10/min"
 34:   treat_missing_data  = "notBreaching"
 35:   alarm_actions       = [aws_sns_topic.alarms.arn]
 36: 
 37:   dimensions = {
 38:     LoadBalancer = module.alb.arn_suffix
 39:   }
 40: }
 41: 
 42: resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
 43:   alarm_name          = "${local.name_prefix}-alb-unhealthy-targets"
 44:   comparison_operator = "GreaterThanThreshold"
 45:   evaluation_periods  = 2
 46:   metric_name         = "UnHealthyHostCount"
 47:   namespace           = "AWS/ApplicationELB"
 48:   period              = 60
 49:   statistic           = "Average"
 50:   threshold           = 0
 51:   alarm_description   = "Unhealthy targets > 0"
 52:   treat_missing_data  = "notBreaching"
 53:   alarm_actions       = [aws_sns_topic.alarms.arn]
 54: 
 55:   dimensions = {
 56:     LoadBalancer = module.alb.arn_suffix
 57:     TargetGroup  = module.alb.target_groups["app"].arn_suffix
 58:   }
 59: }
 60: 
 61: # ----------------------------------------------------------------------------
 62: # Alarms - RDS
 63: # ----------------------------------------------------------------------------
 64: resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
 65:   alarm_name          = "${local.name_prefix}-rds-cpu"
 66:   comparison_operator = "GreaterThanThreshold"
 67:   evaluation_periods  = 5
 68:   metric_name         = "CPUUtilization"
 69:   namespace           = "AWS/RDS"
 70:   period              = 60
 71:   statistic           = "Average"
 72:   threshold           = 80
 73:   alarm_actions       = [aws_sns_topic.alarms.arn]
 74:   treat_missing_data  = "notBreaching"
 75: 
 76:   dimensions = {
 77:     DBInstanceIdentifier = module.rds.db_instance_identifier
 78:   }
 79: }
 80: 
 81: resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
 82:   alarm_name          = "${local.name_prefix}-rds-free-storage"
 83:   comparison_operator = "LessThanThreshold"
 84:   evaluation_periods  = 2
 85:   metric_name         = "FreeStorageSpace"
 86:   namespace           = "AWS/RDS"
 87:   period              = 300
 88:   statistic           = "Average"
 89:   threshold           = 5 * 1024 * 1024 * 1024 # 5 GiB
 90:   alarm_actions       = [aws_sns_topic.alarms.arn]
 91: 
 92:   dimensions = {
 93:     DBInstanceIdentifier = module.rds.db_instance_identifier
 94:   }
 95: }
 96: 
 97: resource "aws_cloudwatch_metric_alarm" "rds_connections" {
 98:   alarm_name          = "${local.name_prefix}-rds-connections"
 99:   comparison_operator = "GreaterThanThreshold"
100:   evaluation_periods  = 5
101:   metric_name         = "DatabaseConnections"
102:   namespace           = "AWS/RDS"
103:   period              = 60
104:   statistic           = "Average"
105:   threshold           = 150
106:   alarm_actions       = [aws_sns_topic.alarms.arn]
107: 
108:   dimensions = {
109:     DBInstanceIdentifier = module.rds.db_instance_identifier
110:   }
111: }
112: 
113: # ----------------------------------------------------------------------------
114: # Alarms - EC2 / ASG
115: # ----------------------------------------------------------------------------
116: resource "aws_cloudwatch_metric_alarm" "ec2_disk" {
117:   alarm_name          = "${local.name_prefix}-ec2-disk"
118:   comparison_operator = "GreaterThanThreshold"
119:   evaluation_periods  = 3
120:   metric_name         = "disk_used_percent"
121:   namespace           = "JavaApp/EC2"
122:   period              = 60
123:   statistic           = "Maximum"
124:   threshold           = 85
125:   alarm_actions       = [aws_sns_topic.alarms.arn]
126:   treat_missing_data  = "notBreaching"
127: }
128: 
129: # ASG instance refresh failures via EventBridge -> SNS
130: resource "aws_cloudwatch_event_rule" "asg_refresh_failed" {
131:   name        = "${local.name_prefix}-asg-refresh-failed"
132:   description = "ASG instance refresh failed/cancelled"
133: 
134:   event_pattern = jsonencode({
135:     "source" : ["aws.autoscaling"],
136:     "detail-type" : ["EC2 Auto Scaling Instance Refresh Failed", "EC2 Auto Scaling Instance Refresh Cancelled"]
137:   })
138: }
139: 
140: resource "aws_cloudwatch_event_target" "asg_refresh_failed_to_sns" {
141:   rule      = aws_cloudwatch_event_rule.asg_refresh_failed.name
142:   target_id = "to-sns"
143:   arn       = aws_sns_topic.alarms.arn
144: }
145: 
146: resource "aws_sns_topic_policy" "alarms_events" {
147:   arn = aws_sns_topic.alarms.arn
148:   policy = jsonencode({
149:     Version = "2012-10-17"
150:     Statement = [
151:       {
152:         Sid       = "AllowEventBridgePublish"
153:         Effect    = "Allow"
154:         Principal = { Service = "events.amazonaws.com" }
155:         Action    = "sns:Publish"
156:         Resource  = aws_sns_topic.alarms.arn
157:       },
158:       {
159:         Sid       = "AllowCloudWatchAlarmPublish"
160:         Effect    = "Allow"
161:         Principal = { Service = "cloudwatch.amazonaws.com" }
162:         Action    = "sns:Publish"
163:         Resource  = aws_sns_topic.alarms.arn
164:       }
165:     ]
166:   })
167: }
168: 
169: # ----------------------------------------------------------------------------
170: # Dashboard
171: # ----------------------------------------------------------------------------
172: resource "aws_cloudwatch_dashboard" "main" {
173:   dashboard_name = "${local.name_prefix}-main"
174: 
175:   dashboard_body = jsonencode({
176:     widgets = [
177:       {
178:         type = "metric", x = 0, y = 0, width = 12, height = 6,
179:         properties = {
180:           title  = "ALB requests + 5xx",
181:           region = var.aws_region,
182:           metrics = [
183:             ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", module.alb.arn_suffix],
184:             [".", "HTTPCode_Target_5XX_Count", ".", "."],
185:             [".", "HTTPCode_Target_4XX_Count", ".", "."]
186:           ],
187:           stat = "Sum", period = 60
188:         }
189:       },
190:       {
191:         type = "metric", x = 12, y = 0, width = 12, height = 6,
192:         properties = {
193:           title  = "ALB target latency",
194:           region = var.aws_region,
195:           metrics = [
196:             ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", module.alb.arn_suffix]
197:           ],
198:           stat = "Average", period = 60
199:         }
200:       },
201:       {
202:         type = "metric", x = 0, y = 6, width = 12, height = 6,
203:         properties = {
204:           title  = "ASG capacity",
205:           region = var.aws_region,
206:           metrics = [
207:             ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", module.asg.autoscaling_group_name],
208:             [".", "GroupDesiredCapacity", ".", "."],
209:             [".", "GroupTotalInstances", ".", "."]
210:           ],
211:           stat = "Average", period = 60
212:         }
213:       },
214:       {
215:         type = "metric", x = 12, y = 6, width = 12, height = 6,
216:         properties = {
217:           title  = "RDS performance",
218:           region = var.aws_region,
219:           metrics = [
220:             ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", module.rds.db_instance_identifier],
221:             [".", "DatabaseConnections", ".", "."],
222:             [".", "FreeStorageSpace", ".", "."]
223:           ],
224:           stat = "Average", period = 60
225:         }
226:       }
227:     ]
228:   })
229: }
````

## File: infra/envs/prod/outputs.tf
````hcl
 1: ###############################################################################
 2: # Outputs - everything CI/operators need to know after apply.
 3: ###############################################################################
 4: 
 5: output "vpc_id" {
 6:   value = module.vpc.vpc_id
 7: }
 8: 
 9: output "alb_dns_name" {
10:   description = "ALB DNS name. Route53 alias target."
11:   value       = module.alb.dns_name
12: }
13: 
14: output "alb_zone_id" {
15:   value = module.alb.zone_id
16: }
17: 
18: output "asg_name" {
19:   description = "ASG name (for Instance Refresh in CI/CD)."
20:   value       = module.asg.autoscaling_group_name
21: }
22: 
23: output "ecr_backend_url" {
24:   value = aws_ecr_repository.this["backend"].repository_url
25: }
26: 
27: output "ecr_frontend_url" {
28:   value = aws_ecr_repository.this["frontend"].repository_url
29: }
30: 
31: output "ssm_backend_image_tag" {
32:   value = aws_ssm_parameter.backend_image_tag.name
33: }
34: 
35: output "ssm_frontend_image_tag" {
36:   value = aws_ssm_parameter.frontend_image_tag.name
37: }
38: 
39: output "ssm_release_id" {
40:   value = aws_ssm_parameter.release_id.name
41: }
42: 
43: output "ssm_compose_object" {
44:   value = aws_ssm_parameter.compose_object.name
45: }
46: 
47: output "rds_endpoint" {
48:   value     = module.rds.db_instance_address
49:   sensitive = false
50: }
51: 
52: output "rds_master_secret_arn" {
53:   description = "RDS-managed master credential secret ARN."
54:   value       = module.rds.db_instance_master_user_secret_arn
55: }
56: 
57: output "secret_db_app_user_arn" {
58:   value = aws_secretsmanager_secret.db_app_user.arn
59: }
60: 
61: output "secret_admin_arn" {
62:   value = aws_secretsmanager_secret.admin.arn
63: }
64: 
65: output "secret_jwt_arn" {
66:   value = aws_secretsmanager_secret.jwt.arn
67: }
68: 
69: output "secret_ses_arn" {
70:   value = aws_secretsmanager_secret.ses.arn
71: }
72: 
73: output "alarms_topic_arn" {
74:   value = aws_sns_topic.alarms.arn
75: }
76: 
77: output "app_url" {
78:   value = "https://${var.app_subdomain}"
79: }
80: 
81: output "ses_dkim_tokens" {
82:   description = "DKIM tokens (already published as CNAMEs in the domain hosted zone)."
83:   value       = aws_sesv2_email_identity.sender.dkim_signing_attributes[0].tokens
84: }
````

## File: infra/envs/prod/route53.tf
````hcl
 1: ###############################################################################
 2: # Route53 - cross-account A alias to ALB.
 3: # Domain hosted zone lives in the DOMAIN account; record is created using
 4: # the aliased provider that assumes the DOMAIN-account Route53 role.
 5: ###############################################################################
 6: 
 7: resource "aws_route53_record" "app_alias" {
 8:   provider = aws.domain
 9:   zone_id  = var.hosted_zone_id
10:   name     = var.app_subdomain
11:   type     = "A"
12: 
13:   # If a previous infra-destroy partially failed and left the record in the
14:   # DOMAIN account hosted zone, allow_overwrite lets the next apply replace
15:   # it instead of erroring with "RR exists with different value".
16:   allow_overwrite = true
17: 
18:   alias {
19:     name                   = module.alb.dns_name
20:     zone_id                = module.alb.zone_id
21:     evaluate_target_health = true
22:   }
23: }
````

## File: infra/envs/prod/ses.tf
````hcl
 1: ###############################################################################
 2: # SES sender identity (subdomain) + DKIM CNAMEs in the DOMAIN account.
 3: ###############################################################################
 4: 
 5: resource "aws_sesv2_email_identity" "sender" {
 6:   email_identity         = var.ses_sender_subdomain
 7:   configuration_set_name = aws_sesv2_configuration_set.app.configuration_set_name
 8: }
 9: 
10: # DKIM CNAMEs are returned as a list of 3 tokens; publish them in the DOMAIN
11: # account hosted zone via the aliased provider.
12: resource "aws_route53_record" "ses_dkim" {
13:   provider = aws.domain
14:   count    = 3
15: 
16:   zone_id = var.hosted_zone_id
17:   name    = "${aws_sesv2_email_identity.sender.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.ses_sender_subdomain}"
18:   type    = "CNAME"
19:   ttl     = 600
20:   records = ["${aws_sesv2_email_identity.sender.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
21:   # Same reasoning as aws_route53_record.app_alias - tolerate stale records
22:   # left over by a partial infra-destroy.
23:   allow_overwrite = true
24: }
25: 
26: resource "aws_sesv2_configuration_set" "app" {
27:   configuration_set_name = "${local.name_prefix}-ses"
28: 
29:   delivery_options {
30:     tls_policy = "REQUIRE"
31:   }
32: 
33:   reputation_options {
34:     reputation_metrics_enabled = true
35:   }
36: 
37:   sending_options {
38:     sending_enabled = true
39:   }
40: }
41: 
42: resource "aws_sesv2_configuration_set_event_destination" "cw" {
43:   configuration_set_name = aws_sesv2_configuration_set.app.configuration_set_name
44:   event_destination_name = "cloudwatch"
45: 
46:   event_destination {
47:     enabled = true
48:     matching_event_types = [
49:       "SEND", "REJECT", "BOUNCE", "COMPLAINT", "DELIVERY", "RENDERING_FAILURE", "DELIVERY_DELAY"
50:     ]
51:     cloud_watch_destination {
52:       dimension_configuration {
53:         default_dimension_value = "default"
54:         dimension_name          = "MessageTag"
55:         dimension_value_source  = "MESSAGE_TAG"
56:       }
57:     }
58:   }
59: }
````

## File: infra/envs/prod/terraform.tfvars.example
````
 1: ###############################################################################
 2: # Copy to terraform.tfvars (or pass via -var-file) and fill in.
 3: # Sensitive values should NOT be committed - prefer GitHub repo variables/
 4: # secrets surfaced as TF_VAR_* environment variables in CI.
 5: ###############################################################################
 6: 
 7: aws_region                       = "us-east-1"
 8: project                          = "java-app"
 9: environment                      = "prod"
10: 
11: deployment_account_id            = "111111111111"
12: domain_account_id                = "222222222222"
13: domain_account_route53_role_arn  = "arn:aws:iam::222222222222:role/route53-dns-manager-role"
14: 
15: hosted_zone_id                   = "Z0123456789ABCDEFGHIJ"
16: root_domain                      = "talorlik.com"
17: app_subdomain                    = "java.talorlik.com"
18: acm_certificate_arn              = "arn:aws:acm:us-east-1:111111111111:certificate/00000000-0000-0000-0000-000000000000"
19: 
20: vpc_cidr                         = "10.40.0.0/16"
21: az_count                         = 2
22: 
23: instance_type                    = "t3.small"
24: asg_min_size                     = 2
25: asg_desired_capacity             = 2
26: asg_max_size                     = 6
27: ubuntu_lts_codename              = "noble"
28: 
29: rds_instance_class               = "db.t3.medium"
30: rds_allocated_storage_gb         = 50
31: rds_max_allocated_storage_gb     = 200
32: rds_engine_version               = "8.4"
33: db_name                          = "javaapp"
34: db_app_username                  = "appuser"
35: 
36: ses_sender_subdomain             = "java.talorlik.com"
37: ses_from_address                 = "no-reply@java.talorlik.com"
38: 
39: alarm_email                      = ""
40: log_retention_days               = 30
41: enable_waf                       = true
````

## File: infra/envs/prod/versions.tf
````hcl
 1: terraform {
 2:   required_version = ">= 1.7.0, < 2.0.0"
 3: 
 4:   required_providers {
 5:     aws = {
 6:       source  = "hashicorp/aws"
 7:       version = "~> 5.70"
 8:     }
 9:     random = {
10:       source  = "hashicorp/random"
11:       version = "~> 3.6"
12:     }
13:     tls = {
14:       source  = "hashicorp/tls"
15:       version = "~> 4.0"
16:     }
17:     # Used by db_bootstrap.tf to package the appuser-bootstrap Lambda zip
18:     # at apply time without requiring an out-of-band build step.
19:     archive = {
20:       source  = "hashicorp/archive"
21:       version = "~> 2.6"
22:     }
23:   }
24: }
````

## File: infra/envs/prod/waf.tf
````hcl
  1: ###############################################################################
  2: # AWS WAFv2 Web ACL attached to the ALB.
  3: ###############################################################################
  4: 
  5: resource "aws_wafv2_web_acl" "alb" {
  6:   count       = var.enable_waf ? 1 : 0
  7:   name        = "${local.name_prefix}-waf"
  8:   description = "Web ACL for app ALB"
  9:   scope       = "REGIONAL"
 10: 
 11:   default_action {
 12:     allow {}
 13:   }
 14: 
 15:   visibility_config {
 16:     cloudwatch_metrics_enabled = true
 17:     metric_name                = "${local.name_prefix}-waf"
 18:     sampled_requests_enabled   = true
 19:   }
 20: 
 21:   # AWS-managed: Common Rule Set
 22:   rule {
 23:     name     = "AWS-AWSManagedRulesCommonRuleSet"
 24:     priority = 1
 25: 
 26:     override_action {
 27:       none {}
 28:     }
 29: 
 30:     statement {
 31:       managed_rule_group_statement {
 32:         vendor_name = "AWS"
 33:         name        = "AWSManagedRulesCommonRuleSet"
 34:       }
 35:     }
 36: 
 37:     visibility_config {
 38:       cloudwatch_metrics_enabled = true
 39:       metric_name                = "common-rule-set"
 40:       sampled_requests_enabled   = true
 41:     }
 42:   }
 43: 
 44:   # AWS-managed: Known Bad Inputs
 45:   rule {
 46:     name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
 47:     priority = 2
 48: 
 49:     override_action {
 50:       none {}
 51:     }
 52: 
 53:     statement {
 54:       managed_rule_group_statement {
 55:         vendor_name = "AWS"
 56:         name        = "AWSManagedRulesKnownBadInputsRuleSet"
 57:       }
 58:     }
 59: 
 60:     visibility_config {
 61:       cloudwatch_metrics_enabled = true
 62:       metric_name                = "known-bad-inputs"
 63:       sampled_requests_enabled   = true
 64:     }
 65:   }
 66: 
 67:   # AWS-managed: SQL injection
 68:   rule {
 69:     name     = "AWS-AWSManagedRulesSQLiRuleSet"
 70:     priority = 3
 71: 
 72:     override_action {
 73:       none {}
 74:     }
 75: 
 76:     statement {
 77:       managed_rule_group_statement {
 78:         vendor_name = "AWS"
 79:         name        = "AWSManagedRulesSQLiRuleSet"
 80:       }
 81:     }
 82: 
 83:     visibility_config {
 84:       cloudwatch_metrics_enabled = true
 85:       metric_name                = "sqli"
 86:       sampled_requests_enabled   = true
 87:     }
 88:   }
 89: 
 90:   # Rate limit per source IP
 91:   rule {
 92:     name     = "RateLimitPerIp"
 93:     priority = 10
 94: 
 95:     action {
 96:       block {}
 97:     }
 98: 
 99:     statement {
100:       rate_based_statement {
101:         limit              = 2000
102:         aggregate_key_type = "IP"
103:       }
104:     }
105: 
106:     visibility_config {
107:       cloudwatch_metrics_enabled = true
108:       metric_name                = "rate-limit-ip"
109:       sampled_requests_enabled   = true
110:     }
111:   }
112: 
113:   tags = local.common_tags
114: }
115: 
116: resource "aws_wafv2_web_acl_association" "alb" {
117:   count        = var.enable_waf ? 1 : 0
118:   resource_arn = module.alb.arn
119:   web_acl_arn  = aws_wafv2_web_acl.alb[0].arn
120: }
121: 
122: # ----------------------------------------------------------------------------
123: # WAF logging configuration
124: #
125: # CKV2_AWS_31 requires every wafv2 ACL to have a logging configuration. We
126: # ship logs to a CloudWatch log group whose name MUST start with
127: # "aws-waf-logs-" (AWS WAF logging-destination naming requirement). The log
128: # group is encrypted with the same app CMK used for other log groups.
129: # ----------------------------------------------------------------------------
130: resource "aws_cloudwatch_log_group" "waf" {
131:   count = var.enable_waf ? 1 : 0
132:   # checkov:skip=CKV_AWS_338:dev-only environment, intentional short retention. Bump var.log_retention_days for live use.
133:   name              = "aws-waf-logs-${local.name_prefix}"
134:   retention_in_days = var.log_retention_days
135:   kms_key_id        = aws_kms_key.app_secrets.arn
136:   tags              = local.common_tags
137: }
138: 
139: resource "aws_wafv2_web_acl_logging_configuration" "alb" {
140:   count                   = var.enable_waf ? 1 : 0
141:   resource_arn            = aws_wafv2_web_acl.alb[0].arn
142:   log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]
143: }
````

## File: .gitattributes
````
 1: * text=auto eol=lf
 2: 
 3: *.png binary
 4: *.jpg binary
 5: *.jpeg binary
 6: *.gif binary
 7: *.ico binary
 8: *.jar binary
 9: *.zip binary
10: *.gz binary
11: 
12: # Maven Wrapper: mvnw must stay LF and executable; mvnw.cmd must stay CRLF.
13: mvnw          text eol=lf
14: mvnw.cmd      text eol=crlf
15: .mvn/wrapper/maven-wrapper.properties text eol=lf
````

## File: app/backend/src/main/resources/application-test.yml
````yaml
 1: spring:
 2:   datasource:
 3:     url: jdbc:tc:mysql:8.4:///javaapp_test
 4:     username: test
 5:     password: test
 6:     driver-class-name: org.testcontainers.jdbc.ContainerDatabaseDriver
 7:   jpa:
 8:     hibernate:
 9:       ddl-auto: validate
10: app:
11:   ses:
12:     enabled: false
13:   jwt:
14:     expiration-minutes: 60
15:     # Hermetic tests: never reach Secrets Manager. The placeholder below is
16:     # only used at bean-construction time; @SpringBootTest classes that need
17:     # a real key can override via @SpringBootTest(properties = ...).
18:     secret-source: inline
19:     inline-key: test-only-not-a-real-key-32bytes-min-aaaa
20:     inline-issuer: java-app-test
21:   admin:
22:     seed-enabled: false
````

## File: app/docker/docker-compose.local.yml
````yaml
 1: ###############################################################################
 2: # Local development / CI compose file.
 3: #
 4: # Brings up MySQL alongside backend + frontend so smoke tests work without
 5: # touching AWS. NOT for production use - prod uses RDS.
 6: ###############################################################################
 7: services:
 8:   mysql:
 9:     image: mysql:8.4
10:     environment:
11:       MYSQL_DATABASE: javaapp
12:       MYSQL_USER: appuser
13:       MYSQL_PASSWORD: localdevpass
14:       MYSQL_ROOT_PASSWORD: localrootpass
15:     ports:
16:       - "3306:3306"
17:     healthcheck:
18:       test: ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 --silent"]
19:       interval: 5s
20:       timeout: 5s
21:       retries: 30
22:   backend:
23:     build:
24:       context: ../backend
25:     image: java-app/backend:dev
26:     depends_on:
27:       mysql:
28:         condition: service_healthy
29:     environment:
30:       DB_HOST: mysql
31:       DB_PORT: "3306"
32:       DB_NAME: javaapp
33:       DB_USERNAME: appuser
34:       DB_PASSWORD: localdevpass
35:       SES_ENABLED: "false"
36:       JWT_SECRET_NAME: disabled-local
37:       SES_SECRET_NAME: disabled-local
38:       ADMIN_SECRET_NAME: disabled-local
39:       APP_PUBLIC_URL: http://localhost:8080
40:       # AWS_REGION is still consumed by the SES/SecretsManager client builders
41:       # in AwsConfig even though, under the local profile, neither client
42:       # actually performs a network call. Keep a default so the bean wires.
43:       AWS_REGION: ${AWS_REGION:-us-east-1}
44:       # Local profile uses InlineJwtSecretProvider. Override JWT_INLINE_KEY at
45:       # the host shell to pin the signing key across runs; otherwise the
46:       # placeholder in application-local.yml is used.
47:       JWT_INLINE_KEY: ${JWT_INLINE_KEY:-dev-only-not-a-real-key-32bytes-minimum-xx}
48:       SPRING_PROFILES_ACTIVE: local
49:     healthcheck:
50:       test: ["CMD", "curl", "-fsS", "http://localhost:8080/actuator/health"]
51:       interval: 10s
52:       timeout: 3s
53:       retries: 30
54:       start_period: 60s
55:     expose:
56:       - "8080"
57:   frontend:
58:     build:
59:       context: ../frontend
60:     image: java-app/frontend:dev
61:     ports:
62:       - "8080:80"
63:     depends_on:
64:       backend:
65:         condition: service_healthy
````

## File: infra/bootstrap/main.tf
````hcl
  1: ###############################################################################
  2: # infra/bootstrap/main.tf
  3: #
  4: # Creates the prerequisites for remote Terraform state in the DEPLOYMENT
  5: # account:
  6: #   - KMS CMK with alias for state encryption (CMK is preferred over SSE-S3
  7: #     to enable per-key access policies and rotation control)
  8: #   - S3 bucket for state with versioning, public access block, TLS-only
  9: #     bucket policy, and SSE-KMS default encryption
 10: #   - Optional access-log bucket
 11: #
 12: # State backend uses S3 native locking via `use_lockfile = true` (no DynamoDB).
 13: ###############################################################################
 14: 
 15: data "aws_caller_identity" "current" {}
 16: data "aws_partition" "current" {}
 17: 
 18: # ----------------------------------------------------------------------------
 19: # KMS CMK for state-bucket encryption
 20: # ----------------------------------------------------------------------------
 21: resource "aws_kms_key" "tfstate" {
 22:   description = "KMS key for Terraform state bucket (${var.state_bucket_name})"
 23:   # Dev default: KMS minimum (7). Bootstrap is intentionally one-time and
 24:   # should not be destroyed in normal flows; this only matters if you ever
 25:   # tear down and rebuild the state backend itself.
 26:   deletion_window_in_days = 7
 27:   enable_key_rotation     = true
 28: 
 29:   policy = jsonencode({
 30:     Version = "2012-10-17"
 31:     Statement = [
 32:       {
 33:         Sid    = "EnableRootAccountPermissions"
 34:         Effect = "Allow"
 35:         Principal = {
 36:           AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
 37:         }
 38:         Action   = "kms:*"
 39:         Resource = "*"
 40:       }
 41:     ]
 42:   })
 43: }
 44: 
 45: resource "aws_kms_alias" "tfstate" {
 46:   name          = var.kms_alias
 47:   target_key_id = aws_kms_key.tfstate.key_id
 48: }
 49: 
 50: # ----------------------------------------------------------------------------
 51: # Optional access-log bucket
 52: #
 53: # This bucket is the S3 server-access-log target for the tfstate bucket and
 54: # (by deterministic name) for the prod ALB log bucket as well. It is kept
 55: # encrypted, versioned, and lifecycle-managed so it satisfies the same
 56: # baseline as the buckets it serves.
 57: #
 58: # checkov skips below cover false positives or out-of-scope requirements for
 59: # a reference impl: cross-region replication is single-region by design, and
 60: # event notifications are not consumed by anything in this stack.
 61: # ----------------------------------------------------------------------------
 62: resource "aws_s3_bucket" "access_logs" {
 63:   # checkov:skip=CKV_AWS_144:single-region reference impl; CRR out of scope
 64:   # checkov:skip=CKV2_AWS_62:no consumer for S3 event notifications
 65:   # checkov:skip=CKV_AWS_18:bucket logs to itself; access logging on the log target is unnecessary and can loop
 66:   count         = var.enable_access_logging ? 1 : 0
 67:   bucket        = "${var.state_bucket_name}-access-logs"
 68:   force_destroy = false
 69: }
 70: 
 71: resource "aws_s3_bucket_public_access_block" "access_logs" {
 72:   count                   = var.enable_access_logging ? 1 : 0
 73:   bucket                  = aws_s3_bucket.access_logs[0].id
 74:   block_public_acls       = true
 75:   block_public_policy     = true
 76:   ignore_public_acls      = true
 77:   restrict_public_buckets = true
 78: }
 79: 
 80: resource "aws_s3_bucket_ownership_controls" "access_logs" {
 81:   count  = var.enable_access_logging ? 1 : 0
 82:   bucket = aws_s3_bucket.access_logs[0].id
 83:   rule {
 84:     object_ownership = "BucketOwnerEnforced"
 85:   }
 86: }
 87: 
 88: # S3 access-log delivery service writes with the bucket-owner's S3 service
 89: # account; SSE-KMS with a CMK is rejected on the log-delivery write path.
 90: # AES256 (SSE-S3) is the supported algorithm for log target buckets and
 91: # satisfies CKV_AWS_19 (encryption at rest).
 92: resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
 93:   # checkov:skip=CKV_AWS_145:S3 server-access log delivery does not support SSE-KMS CMK; AES256 is the supported choice for log target buckets
 94:   count  = var.enable_access_logging ? 1 : 0
 95:   bucket = aws_s3_bucket.access_logs[0].id
 96:   rule {
 97:     apply_server_side_encryption_by_default {
 98:       sse_algorithm = "AES256"
 99:     }
100:   }
101: }
102: 
103: resource "aws_s3_bucket_versioning" "access_logs" {
104:   count  = var.enable_access_logging ? 1 : 0
105:   bucket = aws_s3_bucket.access_logs[0].id
106:   versioning_configuration {
107:     status = "Enabled"
108:   }
109: }
110: 
111: resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
112:   count  = var.enable_access_logging ? 1 : 0
113:   bucket = aws_s3_bucket.access_logs[0].id
114: 
115:   rule {
116:     id     = "expire"
117:     status = "Enabled"
118:     filter {}
119: 
120:     expiration {
121:       days = 90
122:     }
123:     noncurrent_version_expiration {
124:       noncurrent_days = 30
125:     }
126:     abort_incomplete_multipart_upload {
127:       days_after_initiation = 7
128:     }
129:   }
130: }
131: 
132: # ----------------------------------------------------------------------------
133: # Terraform state bucket
134: # ----------------------------------------------------------------------------
135: # NOTE: force_destroy is intentionally false. State buckets must never be
136: # accidentally emptied.
137: resource "aws_s3_bucket" "tfstate" {
138:   # checkov:skip=CKV_AWS_144:single-region reference impl; CRR out of scope
139:   # checkov:skip=CKV2_AWS_62:no consumer for S3 event notifications
140:   bucket        = var.state_bucket_name
141:   force_destroy = false
142: }
143: 
144: resource "aws_s3_bucket_versioning" "tfstate" {
145:   bucket = aws_s3_bucket.tfstate.id
146:   versioning_configuration {
147:     status = "Enabled"
148:   }
149: }
150: 
151: resource "aws_s3_bucket_public_access_block" "tfstate" {
152:   bucket                  = aws_s3_bucket.tfstate.id
153:   block_public_acls       = true
154:   block_public_policy     = true
155:   ignore_public_acls      = true
156:   restrict_public_buckets = true
157: }
158: 
159: resource "aws_s3_bucket_ownership_controls" "tfstate" {
160:   bucket = aws_s3_bucket.tfstate.id
161:   rule {
162:     object_ownership = "BucketOwnerEnforced"
163:   }
164: }
165: 
166: resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
167:   bucket = aws_s3_bucket.tfstate.id
168:   rule {
169:     apply_server_side_encryption_by_default {
170:       sse_algorithm     = "aws:kms"
171:       kms_master_key_id = aws_kms_key.tfstate.arn
172:     }
173:     bucket_key_enabled = true
174:   }
175: }
176: 
177: resource "aws_s3_bucket_logging" "tfstate" {
178:   count         = var.enable_access_logging ? 1 : 0
179:   bucket        = aws_s3_bucket.tfstate.id
180:   target_bucket = aws_s3_bucket.access_logs[0].id
181:   target_prefix = "tfstate-access/"
182: }
183: 
184: # Enforce TLS for all requests against the state bucket
185: resource "aws_s3_bucket_policy" "tfstate_tls_only" {
186:   bucket = aws_s3_bucket.tfstate.id
187: 
188:   policy = jsonencode({
189:     Version = "2012-10-17"
190:     Statement = [
191:       {
192:         Sid       = "DenyInsecureTransport"
193:         Effect    = "Deny"
194:         Principal = "*"
195:         Action    = "s3:*"
196:         Resource = [
197:           aws_s3_bucket.tfstate.arn,
198:           "${aws_s3_bucket.tfstate.arn}/*"
199:         ]
200:         Condition = {
201:           Bool = {
202:             "aws:SecureTransport" = "false"
203:           }
204:         }
205:       }
206:     ]
207:   })
208: }
209: 
210: # Lifecycle: keep noncurrent versions for 90 days, abort incomplete uploads
211: resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
212:   bucket = aws_s3_bucket.tfstate.id
213: 
214:   rule {
215:     id     = "expire-noncurrent"
216:     status = "Enabled"
217: 
218:     # Empty filter applies the rule to every object in the bucket. Required by
219:     # AWS provider v5 SDKv2 schema (one of `filter` or `prefix` is mandatory).
220:     filter {}
221: 
222:     noncurrent_version_expiration {
223:       noncurrent_days = 90
224:     }
225: 
226:     abort_incomplete_multipart_upload {
227:       days_after_initiation = 7
228:     }
229:   }
230: }
````

## File: infra/envs/prod/ecr.tf
````hcl
 1: ###############################################################################
 2: # ECR repositories for backend and frontend.
 3: #
 4: # - Image scanning on push.
 5: # - Tag immutability so a SHA tag can't be overwritten.
 6: # - Lifecycle policy: keep latest 30 tagged images, expire untagged after 7d.
 7: ###############################################################################
 8: 
 9: locals {
10:   ecr_repos = {
11:     backend  = "${var.project}/backend"
12:     frontend = "${var.project}/frontend"
13:   }
14: }
15: 
16: resource "aws_ecr_repository" "this" {
17:   for_each             = local.ecr_repos
18:   name                 = each.value
19:   image_tag_mutability = "IMMUTABLE"
20:   # Dev default: true. Lets `terraform destroy` remove a non-empty repo if
21:   # the destroy workflow's image-purge step skipped or partially failed.
22:   # Bump to false before going live so accidental destroys can't drop images.
23:   force_delete = true
24: 
25:   image_scanning_configuration {
26:     scan_on_push = true
27:   }
28: 
29:   encryption_configuration {
30:     encryption_type = "KMS"
31:     kms_key         = aws_kms_key.app_secrets.arn
32:   }
33: 
34:   tags = local.common_tags
35: }
36: 
37: resource "aws_ecr_lifecycle_policy" "this" {
38:   for_each   = aws_ecr_repository.this
39:   repository = each.value.name
40: 
41:   policy = jsonencode({
42:     rules = [
43:       {
44:         rulePriority = 1
45:         description  = "Keep last 30 SHA-tagged images"
46:         selection = {
47:           tagStatus      = "tagged"
48:           tagPatternList = ["sha-*", "v*"]
49:           countType      = "imageCountMoreThan"
50:           countNumber    = 30
51:         }
52:         action = { type = "expire" }
53:       },
54:       {
55:         rulePriority = 2
56:         description  = "Expire untagged images after 7 days"
57:         selection = {
58:           tagStatus   = "untagged"
59:           countType   = "sinceImagePushed"
60:           countUnit   = "days"
61:           countNumber = 7
62:         }
63:         action = { type = "expire" }
64:       }
65:     ]
66:   })
67: }
````

## File: infra/envs/prod/locals.tf
````hcl
 1: locals {
 2:   name_prefix = "${var.project}-${var.environment}"
 3: 
 4:   common_tags = {
 5:     Project     = var.project
 6:     Environment = var.environment
 7:     ManagedBy   = "terraform"
 8:     Owner       = var.owner
 9:   }
10: 
11:   # Secrets Manager namespace as defined in TR-SEC-001.
12:   secret_prefix = "/${var.project}/${var.environment}"
13: 
14:   # SSM Parameter Store keys (TR-REL-005).
15:   ssm_keys = {
16:     backend_image_tag    = "${local.secret_prefix}/backend-image-tag"
17:     frontend_image_tag   = "${local.secret_prefix}/frontend-image-tag"
18:     release_id           = "${local.secret_prefix}/release-id"
19:     compose_object       = "${local.secret_prefix}/compose-object"
20:     db_endpoint          = "${local.secret_prefix}/db/endpoint"
21:     db_name              = "${local.secret_prefix}/db/name"
22:     log_group_app        = "${local.secret_prefix}/log-group/app"
23:     asg_min_size         = "${local.secret_prefix}/asg/min-size"
24:     asg_desired_capacity = "${local.secret_prefix}/asg/desired-capacity"
25:     asg_max_size         = "${local.secret_prefix}/asg/max-size"
26:   }
27: 
28:   app_port       = 8080
29:   alb_https_port = 443
30:   alb_http_port  = 80
31:   db_port        = 3306
32: 
33:   # Subnet CIDRs derived from var.vpc_cidr (a /16). Reserves /24s in the /16
34:   # so each tier gets up to 4 AZs without renumbering.
35:   public_subnets   = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
36:   private_app_cidr = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, 10 + i)]
37:   private_db_cidr  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, 20 + i)]
38: }
39: 
40: data "aws_availability_zones" "available" {
41:   state = "available"
42: }
````

## File: infra/envs/prod/network.tf
````hcl
  1: ###############################################################################
  2: # Network foundation
  3: #
  4: # Three-tier VPC built from terraform-aws-modules/vpc/aws:
  5: #   - Public subnets:        ALB + NAT gateways
  6: #   - Private app subnets:   ASG instances
  7: #   - Private DB subnets:    RDS subnet group
  8: #
  9: # Plus VPC endpoints so private nodes can reach SSM, Secrets Manager, ECR,
 10: # CloudWatch Logs, and S3 without traversing the NAT for every call.
 11: ###############################################################################
 12: 
 13: module "vpc" {
 14:   # checkov:skip=CKV_TF_1:source pinned via registry tag (~> 5.13). Commit-hash pinning rejected for upstream-maintained modules; CKV_TF_2 (tag pin) covers the supply-chain intent.
 15:   source  = "terraform-aws-modules/vpc/aws"
 16:   version = "~> 5.13"
 17: 
 18:   name = "${local.name_prefix}-vpc"
 19:   cidr = var.vpc_cidr
 20: 
 21:   azs              = slice(data.aws_availability_zones.available.names, 0, var.az_count)
 22:   public_subnets   = local.public_subnets
 23:   private_subnets  = local.private_app_cidr
 24:   database_subnets = local.private_db_cidr
 25: 
 26:   create_database_subnet_group       = true
 27:   create_database_subnet_route_table = true
 28: 
 29:   enable_nat_gateway     = true
 30:   single_nat_gateway     = false
 31:   one_nat_gateway_per_az = true
 32: 
 33:   enable_dns_hostnames = true
 34:   enable_dns_support   = true
 35: 
 36:   # Flow logs (CloudWatch) for forensic visibility (FR-OPS-01).
 37:   enable_flow_log                                 = true
 38:   create_flow_log_cloudwatch_iam_role             = true
 39:   create_flow_log_cloudwatch_log_group            = true
 40:   flow_log_max_aggregation_interval               = 60
 41:   flow_log_cloudwatch_log_group_retention_in_days = var.log_retention_days
 42: 
 43:   public_subnet_tags = {
 44:     Tier                     = "public"
 45:     "kubernetes.io/role/elb" = "1" # harmless tag, useful for any future EKS coexistence
 46:   }
 47:   private_subnet_tags = {
 48:     Tier = "private-app"
 49:   }
 50:   database_subnet_tags = {
 51:     Tier = "private-db"
 52:   }
 53: 
 54:   tags = local.common_tags
 55: }
 56: 
 57: # ----------------------------------------------------------------------------
 58: # VPC Endpoints
 59: # ----------------------------------------------------------------------------
 60: 
 61: # Endpoint security group: allow HTTPS from VPC CIDR.
 62: resource "aws_security_group" "vpce" {
 63:   name        = "${local.name_prefix}-vpce-sg"
 64:   description = "Allow HTTPS from VPC to interface VPC endpoints"
 65:   vpc_id      = module.vpc.vpc_id
 66: 
 67:   ingress {
 68:     description = "HTTPS from VPC"
 69:     from_port   = 443
 70:     to_port     = 443
 71:     protocol    = "tcp"
 72:     cidr_blocks = [var.vpc_cidr]
 73:   }
 74: 
 75:   # The vpce SG is only attached to interface VPC endpoints, which never
 76:   # initiate outbound traffic to anything beyond their parent VPC. Restrict
 77:   # egress to the VPC CIDR (still on TCP/443) so checkov CKV_AWS_382 passes
 78:   # and the SG's intent is explicit.
 79:   egress {
 80:     description = "HTTPS replies inside VPC"
 81:     from_port   = 443
 82:     to_port     = 443
 83:     protocol    = "tcp"
 84:     cidr_blocks = [var.vpc_cidr]
 85:   }
 86: 
 87:   tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpce-sg" })
 88: }
 89: 
 90: locals {
 91:   interface_endpoints = [
 92:     "ssm",
 93:     "ssmmessages",
 94:     "ec2messages",
 95:     "secretsmanager",
 96:     "logs",
 97:     "monitoring",
 98:     "ecr.api",
 99:     "ecr.dkr",
100:   ]
101: }
102: 
103: resource "aws_vpc_endpoint" "interface" {
104:   for_each = toset(local.interface_endpoints)
105: 
106:   vpc_id              = module.vpc.vpc_id
107:   service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
108:   vpc_endpoint_type   = "Interface"
109:   subnet_ids          = module.vpc.private_subnets
110:   security_group_ids  = [aws_security_group.vpce.id]
111:   private_dns_enabled = true
112: 
113:   tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpce-${replace(each.value, ".", "-")}" })
114: }
115: 
116: # S3 gateway endpoint - required for ECR layer pulls (ECR stores layers in S3)
117: # and for any direct S3 access (e.g. compose object).
118: resource "aws_vpc_endpoint" "s3" {
119:   vpc_id            = module.vpc.vpc_id
120:   service_name      = "com.amazonaws.${var.aws_region}.s3"
121:   vpc_endpoint_type = "Gateway"
122:   route_table_ids   = concat(module.vpc.private_route_table_ids, module.vpc.database_route_table_ids)
123: 
124:   tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpce-s3" })
125: }
````

## File: infra/envs/prod/security.tf
````hcl
  1: ###############################################################################
  2: # Security groups
  3: #
  4: # Strict tier-to-tier policy: all inter-tier rules use SG references, never
  5: # CIDRs. Only the ALB SG accepts internet traffic.
  6: ###############################################################################
  7: 
  8: # ----------------------------------------------------------------------------
  9: # ALB SG - public-facing
 10: # ----------------------------------------------------------------------------
 11: resource "aws_security_group" "alb" {
 12:   # checkov:skip=CKV2_AWS_5:attached to the ALB via module.alb.security_groups; checkov cannot follow the SG ID through the upstream module.
 13:   name        = "${local.name_prefix}-alb-sg"
 14:   description = "Public ALB. Accepts HTTPS on 443 and HTTP on 80 (redirect) from the internet."
 15:   vpc_id      = module.vpc.vpc_id
 16:   tags        = merge(local.common_tags, { Name = "${local.name_prefix}-alb-sg" })
 17: }
 18: 
 19: resource "aws_vpc_security_group_ingress_rule" "alb_https" {
 20:   security_group_id = aws_security_group.alb.id
 21:   description       = "Public HTTPS"
 22:   ip_protocol       = "tcp"
 23:   from_port         = local.alb_https_port
 24:   to_port           = local.alb_https_port
 25:   cidr_ipv4         = "0.0.0.0/0"
 26: }
 27: 
 28: # Plain HTTP only exists so the ALB can issue a 301 to HTTPS. No traffic
 29: # reaches the app tier on port 80; the ALB's own listener handles the
 30: # redirect locally.
 31: resource "aws_vpc_security_group_ingress_rule" "alb_http_redirect" {
 32:   # checkov:skip=CKV_AWS_260:port-80 ingress is required so the ALB can issue HTTP->HTTPS 301 redirects. No app traffic is served on 80; the listener responds locally with redirect_only.
 33:   security_group_id = aws_security_group.alb.id
 34:   description       = "Public HTTP (redirect to HTTPS)"
 35:   ip_protocol       = "tcp"
 36:   from_port         = local.alb_http_port
 37:   to_port           = local.alb_http_port
 38:   cidr_ipv4         = "0.0.0.0/0"
 39: }
 40: 
 41: resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
 42:   security_group_id            = aws_security_group.alb.id
 43:   description                  = "ALB to app tier"
 44:   ip_protocol                  = "tcp"
 45:   from_port                    = local.app_port
 46:   to_port                      = local.app_port
 47:   referenced_security_group_id = aws_security_group.app.id
 48: }
 49: 
 50: # ----------------------------------------------------------------------------
 51: # App SG - private app tier
 52: # ----------------------------------------------------------------------------
 53: resource "aws_security_group" "app" {
 54:   # checkov:skip=CKV2_AWS_5:attached to ASG launch template via module.asg.security_groups; checkov cannot follow the SG ID through the upstream module.
 55:   name        = "${local.name_prefix}-app-sg"
 56:   description = "App tier. Accepts traffic from ALB SG only."
 57:   vpc_id      = module.vpc.vpc_id
 58:   tags        = merge(local.common_tags, { Name = "${local.name_prefix}-app-sg" })
 59: }
 60: 
 61: resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
 62:   security_group_id            = aws_security_group.app.id
 63:   description                  = "From ALB on 8080"
 64:   ip_protocol                  = "tcp"
 65:   from_port                    = local.app_port
 66:   to_port                      = local.app_port
 67:   referenced_security_group_id = aws_security_group.alb.id
 68: }
 69: 
 70: # Egress: HTTPS for ECR/AWS APIs, MySQL to RDS SG, NTP, package mirrors.
 71: resource "aws_vpc_security_group_egress_rule" "app_https" {
 72:   security_group_id = aws_security_group.app.id
 73:   description       = "HTTPS egress (AWS APIs via VPCE, package mirrors via NAT)"
 74:   ip_protocol       = "tcp"
 75:   from_port         = 443
 76:   to_port           = 443
 77:   cidr_ipv4         = "0.0.0.0/0"
 78: }
 79: 
 80: resource "aws_vpc_security_group_egress_rule" "app_http" {
 81:   security_group_id = aws_security_group.app.id
 82:   description       = "HTTP egress (apt mirrors, docker)"
 83:   ip_protocol       = "tcp"
 84:   from_port         = 80
 85:   to_port           = 80
 86:   cidr_ipv4         = "0.0.0.0/0"
 87: }
 88: 
 89: resource "aws_vpc_security_group_egress_rule" "app_dns_udp" {
 90:   security_group_id = aws_security_group.app.id
 91:   description       = "DNS"
 92:   ip_protocol       = "udp"
 93:   from_port         = 53
 94:   to_port           = 53
 95:   cidr_ipv4         = "0.0.0.0/0"
 96: }
 97: 
 98: resource "aws_vpc_security_group_egress_rule" "app_ntp" {
 99:   security_group_id = aws_security_group.app.id
100:   description       = "NTP"
101:   ip_protocol       = "udp"
102:   from_port         = 123
103:   to_port           = 123
104:   cidr_ipv4         = "0.0.0.0/0"
105: }
106: 
107: resource "aws_vpc_security_group_egress_rule" "app_to_rds" {
108:   security_group_id            = aws_security_group.app.id
109:   description                  = "MySQL to RDS"
110:   ip_protocol                  = "tcp"
111:   from_port                    = local.db_port
112:   to_port                      = local.db_port
113:   referenced_security_group_id = aws_security_group.rds.id
114: }
115: 
116: # ----------------------------------------------------------------------------
117: # RDS SG - private DB tier
118: # ----------------------------------------------------------------------------
119: resource "aws_security_group" "rds" {
120:   # checkov:skip=CKV2_AWS_5:attached to RDS via module.rds.vpc_security_group_ids; checkov cannot follow the SG ID through the upstream module.
121:   name        = "${local.name_prefix}-rds-sg"
122:   description = "RDS MySQL. Accepts 3306 from app SG only."
123:   vpc_id      = module.vpc.vpc_id
124:   tags        = merge(local.common_tags, { Name = "${local.name_prefix}-rds-sg" })
125: }
126: 
127: resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
128:   security_group_id            = aws_security_group.rds.id
129:   description                  = "MySQL from app SG"
130:   ip_protocol                  = "tcp"
131:   from_port                    = local.db_port
132:   to_port                      = local.db_port
133:   referenced_security_group_id = aws_security_group.app.id
134: }
135: # RDS SG has no egress rules - DB doesn't initiate outbound traffic.
````

## File: .actrc
````
 1: # nektos/act default flags. Loaded automatically when `act` is invoked from
 2: # this repository's root. Real GitHub Actions runners ignore this file, so
 3: # settings here only affect local act runs.
 4: #
 5: # Override per-invocation by passing the same flag with a different value on
 6: # the command line.
 7: 
 8: # Pin runner image to a known-good catthehacker variant for reproducibility.
 9: #
10: # `full-24.04` (~18 GB) ships the same tool set as github-hosted ubuntu-24.04
11: # runners, including a recent docker CLI. The slimmer `act-latest` image
12: # (~2 GB) ships an older docker CLI that defaults to API version 1.32, which
13: # OrbStack and Docker Engine 24+ reject when Testcontainers reaches the
14: # host daemon through the bind-mounted socket ("client version 1.32 is too
15: # old. Minimum supported API version is 1.40"). The full image avoids that
16: # trip wire and matches the daemon api floor of github-hosted runners.
17: # (unverified - confirm by running the backend job under act after first
18: # pull; cold pull is large.)
19: -P ubuntu-latest=catthehacker/ubuntu:full-24.04
20: 
21: # Force amd64 so behavior matches GitHub-hosted ubuntu-latest. On Apple
22: # Silicon hosts this runs through Rosetta in Docker Desktop / OrbStack /
23: # Colima.
24: --container-architecture linux/amd64
25: 
26: # Emulated artifact server for actions/upload-artifact and download-artifact.
27: # Without this flag, upload steps fail with
28: #   ::error::Unable to get the ACTIONS_RUNTIME_TOKEN env variable
29: # Path is on the host filesystem; act mounts it into the runner container.
30: --artifact-server-path /tmp/act-artifacts
31: 
32: # Local-only credentials and config files. All three paths are gitignored
33: # (.github/env.local, .github/secrets.local, .github/vars.local). Populate
34: # them yourself; templates live next to them as *.example if added later.
35: --env-file .github/env.local
36: --secret-file .github/secrets.local
37: --var-file .github/vars.local
38: 
39: # Container options applied to the runner container itself.
40: #   --group-add=0
41: #       Adds the root group so the bind-mounted /var/run/docker.sock is
42: #       readable from inside the runner. Required for docker-cli, compose,
43: #       and Testcontainers calls that touch the daemon.
44: #
45: # Limitation: act's `--container-options` is a single-string flag, and
46: # `.actrc` lines are split on whitespace before parsing. That means you
47: # cannot pack multiple docker options into this one line, and adding
48: # additional `--container-options=` lines does not stack (last one wins).
49: # Pass extra docker options via a shell-quoted CLI invocation when needed,
50: # e.g. on a plain Linux Docker Engine daemon (no Docker Desktop / OrbStack)
51: # where `host.docker.internal` is not auto-provided:
52: #
53: #     act --container-options "--group-add=0 \
54: #         --add-host=host.docker.internal:host-gateway" -W ...
55: #
56: # On macOS with Docker Desktop or OrbStack the alias is injected into every
57: # container's /etc/hosts natively, so the bare `--group-add=0` below is
58: # enough for ci.yml's BACKEND_HOST and TESTCONTAINERS_HOST_OVERRIDE to
59: # resolve.
60: --container-options=--group-add=0
````

## File: app/backend/src/main/resources/application.yml
````yaml
 1: spring:
 2:   application:
 3:     name: java-app-backend
 4:   datasource:
 5:     url: jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:javaapp}?useSSL=true&requireSSL=false&serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8
 6:     username: ${DB_USERNAME:appuser}
 7:     password: ${DB_PASSWORD:changeme}
 8:     hikari:
 9:       maximum-pool-size: 20
10:       minimum-idle: 5
11:       connection-timeout: 5000
12:       idle-timeout: 600000
13:       max-lifetime: 1800000
14:   jpa:
15:     hibernate:
16:       ddl-auto: validate
17:     properties:
18:       hibernate.dialect: org.hibernate.dialect.MySQLDialect
19:       hibernate.jdbc.batch_size: 25
20:     open-in-view: false
21:   flyway:
22:     enabled: true
23:     baseline-on-migrate: true
24:     locations: classpath:db/migration
25: server:
26:   port: 8080
27:   forward-headers-strategy: framework
28:   error:
29:     include-stacktrace: never
30:     include-message: never
31: management:
32:   endpoints:
33:     web:
34:       exposure:
35:         include: health,info,metrics
36:       base-path: /actuator
37:   endpoint:
38:     health:
39:       show-details: never
40:       probes:
41:         enabled: true
42:   health:
43:     db:
44:       enabled: true
45: logging:
46:   level:
47:     root: INFO
48:     com.talorlik.javaapp: INFO
49:     org.springframework.security: INFO
50: app:
51:   aws:
52:     region: ${AWS_REGION:us-east-1}
53:   secrets:
54:     jwt-secret-name: ${JWT_SECRET_NAME:/java-app/prod/jwt}
55:     ses-secret-name: ${SES_SECRET_NAME:/java-app/prod/ses}
56:     admin-secret-name: ${ADMIN_SECRET_NAME:/java-app/prod/admin}
57:   jwt:
58:     expiration-minutes: 60
59:     # Source of the JWT signing key. "secrets-manager" (default) reads from
60:     # AWS Secrets Manager. "inline" reads from app.jwt.inline-key and is
61:     # intended for local dev / hermetic CI. Wiring is via @ConditionalOnProperty
62:     # on the JwtSecretProvider implementations.
63:     secret-source: ${JWT_SECRET_SOURCE:secrets-manager}
64:     inline-key: ${JWT_INLINE_KEY:}
65:     inline-issuer: ${JWT_INLINE_ISSUER:java-app}
66:   admin:
67:     # When false, AdminSeeder is a no-op. Keeps local/CI from calling
68:     # Secrets Manager for the admin password.
69:     seed-enabled: ${ADMIN_SEED_ENABLED:true}
70:   verification:
71:     code-length: 6
72:     ttl-minutes: 30
73:     max-attempts: 5
74:   rate-limit:
75:     login-per-minute: 10
76:     verify-per-minute: 10
77:     signup-per-hour: 20
78:   cors:
79:     allowed-origin: ${APP_PUBLIC_URL:https://java.talorlik.com}
80:   ses:
81:     enabled: ${SES_ENABLED:true}
````

## File: app/backend/pom.xml
````xml
  1: <?xml version="1.0" encoding="UTF-8"?>
  2: <project xmlns="http://maven.apache.org/POM/4.0.0"
  3:          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  4:          xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
  5:                              https://maven.apache.org/xsd/maven-4.0.0.xsd">
  6:     <modelVersion>4.0.0</modelVersion>
  7:     <parent>
  8:         <groupId>org.springframework.boot</groupId>
  9:         <artifactId>spring-boot-starter-parent</artifactId>
 10:         <version>3.5.0</version>
 11:         <relativePath/>
 12:     </parent>
 13:     <groupId>com.talorlik</groupId>
 14:     <artifactId>java-app-backend</artifactId>
 15:     <version>1.0.0</version>
 16:     <packaging>jar</packaging>
 17:     <name>java-app-backend</name>
 18:     <description>Dockerized Java App on EC2 - Backend</description>
 19:     <properties>
 20:         <java.version>21</java.version>
 21:         <maven.compiler.source>21</maven.compiler.source>
 22:         <maven.compiler.target>21</maven.compiler.target>
 23:         <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
 24:         <jjwt.version>0.12.6</jjwt.version>
 25:         <aws.sdk.version>2.28.16</aws.sdk.version>
 26:         <!--
 27:             Testcontainers 1.21.x explicitly works with recent Docker Engine
 28:             API minimums (>= 1.40). 1.21.3 is the latest patch on the 1.21
 29:             line as of 2026-05; 2.0.x exists upstream but is a major-version
 30:             bump that requires a migration audit (deferred). Pinning 1.21.3
 31:             keeps us on a Docker-modern client without taking that hit.
 32:             (unverified - confirm against Maven Central before pinning if
 33:             the container coords change.)
 34:         -->
 35:         <testcontainers.version>1.21.3</testcontainers.version>
 36:         <bucket4j.version>8.10.1</bucket4j.version>
 37:         <!--
 38:             docker-java pinned ahead of Spring Boot 3.5.0 BOM's older default.
 39:             Spring Boot's BOM ships a docker-java line that hardcodes Docker
 40:             REST path /v1.32/..., which modern daemons (28.x, 29.x) reject
 41:             with "client version 1.32 is too old. Minimum supported API
 42:             version is 1.40". 3.7.1 negotiates to the daemon's max API.
 43:             Required for Testcontainers IT to run on host-mounted sockets
 44:             (act) and on github-hosted ubuntu-latest equally.
 45:         -->
 46:         <docker-java.version>3.7.1</docker-java.version>
 47:         <!--
 48:             docker-java currently requires explicit API version pinning in our
 49:             environment. Keep this as the single project-level source of truth
 50:             for IT JVMs.
 51:         -->
 52:         <docker.api.version>1.45</docker.api.version>
 53:     </properties>
 54:     <dependencyManagement>
 55:         <dependencies>
 56:             <!--
 57:                 Import docker-java BOM to align all com.github.docker-java:*
 58:                 artifacts (api, core, transport-zerodep, etc.) on a single
 59:                 version. Listed before the Spring Boot parent's effective
 60:                 management because pom-imported BOMs in this dependencyManagement
 61:                 block resolve before the parent's own.
 62:             -->
 63:             <dependency>
 64:                 <groupId>com.github.docker-java</groupId>
 65:                 <artifactId>docker-java-bom</artifactId>
 66:                 <version>${docker-java.version}</version>
 67:                 <type>pom</type>
 68:                 <scope>import</scope>
 69:             </dependency>
 70:         </dependencies>
 71:     </dependencyManagement>
 72:     <dependencies>
 73:         <!-- Web + validation -->
 74:         <dependency>
 75:             <groupId>org.springframework.boot</groupId>
 76:             <artifactId>spring-boot-starter-web</artifactId>
 77:         </dependency>
 78:         <dependency>
 79:             <groupId>org.springframework.boot</groupId>
 80:             <artifactId>spring-boot-starter-validation</artifactId>
 81:         </dependency>
 82:         <!-- Persistence -->
 83:         <dependency>
 84:             <groupId>org.springframework.boot</groupId>
 85:             <artifactId>spring-boot-starter-data-jpa</artifactId>
 86:         </dependency>
 87:         <dependency>
 88:             <groupId>com.mysql</groupId>
 89:             <artifactId>mysql-connector-j</artifactId>
 90:         </dependency>
 91:         <dependency>
 92:             <groupId>org.flywaydb</groupId>
 93:             <artifactId>flyway-core</artifactId>
 94:         </dependency>
 95:         <dependency>
 96:             <groupId>org.flywaydb</groupId>
 97:             <artifactId>flyway-mysql</artifactId>
 98:         </dependency>
 99:         <!-- Security + JWT -->
100:         <dependency>
101:             <groupId>org.springframework.boot</groupId>
102:             <artifactId>spring-boot-starter-security</artifactId>
103:         </dependency>
104:         <dependency>
105:             <groupId>io.jsonwebtoken</groupId>
106:             <artifactId>jjwt-api</artifactId>
107:             <version>${jjwt.version}</version>
108:         </dependency>
109:         <dependency>
110:             <groupId>io.jsonwebtoken</groupId>
111:             <artifactId>jjwt-impl</artifactId>
112:             <version>${jjwt.version}</version>
113:             <scope>runtime</scope>
114:         </dependency>
115:         <dependency>
116:             <groupId>io.jsonwebtoken</groupId>
117:             <artifactId>jjwt-jackson</artifactId>
118:             <version>${jjwt.version}</version>
119:             <scope>runtime</scope>
120:         </dependency>
121:         <!-- Actuator -->
122:         <dependency>
123:             <groupId>org.springframework.boot</groupId>
124:             <artifactId>spring-boot-starter-actuator</artifactId>
125:         </dependency>
126:         <!-- AWS SDK v2 -->
127:         <dependency>
128:             <groupId>software.amazon.awssdk</groupId>
129:             <artifactId>secretsmanager</artifactId>
130:             <version>${aws.sdk.version}</version>
131:         </dependency>
132:         <dependency>
133:             <groupId>software.amazon.awssdk</groupId>
134:             <artifactId>sesv2</artifactId>
135:             <version>${aws.sdk.version}</version>
136:         </dependency>
137:         <!-- Rate limiting -->
138:         <dependency>
139:             <groupId>com.bucket4j</groupId>
140:             <artifactId>bucket4j-core</artifactId>
141:             <version>${bucket4j.version}</version>
142:         </dependency>
143:         <!-- ===== Test ===== -->
144:         <dependency>
145:             <groupId>org.springframework.boot</groupId>
146:             <artifactId>spring-boot-starter-test</artifactId>
147:             <scope>test</scope>
148:         </dependency>
149:         <dependency>
150:             <groupId>org.springframework.security</groupId>
151:             <artifactId>spring-security-test</artifactId>
152:             <scope>test</scope>
153:         </dependency>
154:         <dependency>
155:             <groupId>org.testcontainers</groupId>
156:             <artifactId>junit-jupiter</artifactId>
157:             <version>${testcontainers.version}</version>
158:             <scope>test</scope>
159:         </dependency>
160:         <dependency>
161:             <groupId>org.testcontainers</groupId>
162:             <artifactId>mysql</artifactId>
163:             <version>${testcontainers.version}</version>
164:             <scope>test</scope>
165:         </dependency>
166:     </dependencies>
167:     <build>
168:         <finalName>app</finalName>
169:         <plugins>
170:             <plugin>
171:                 <groupId>org.springframework.boot</groupId>
172:                 <artifactId>spring-boot-maven-plugin</artifactId>
173:                 <configuration>
174:                     <executable>true</executable>
175:                     <layers>
176:                         <enabled>true</enabled>
177:                     </layers>
178:                 </configuration>
179:             </plugin>
180:             <plugin>
181:                 <groupId>org.apache.maven.plugins</groupId>
182:                 <artifactId>maven-surefire-plugin</artifactId>
183:                 <configuration>
184:                     <includes>
185:                         <include>**/unit/**/*Test.java</include>
186:                         <include>**/*UnitTest.java</include>
187:                     </includes>
188:                 </configuration>
189:             </plugin>
190:             <plugin>
191:                 <groupId>org.apache.maven.plugins</groupId>
192:                 <artifactId>maven-failsafe-plugin</artifactId>
193:                 <configuration>
194:                     <systemPropertyVariables>
195:                         <api.version>${docker.api.version}</api.version>
196:                     </systemPropertyVariables>
197:                     <includes>
198:                         <include>**/integration/**/*IT.java</include>
199:                         <include>**/*IT.java</include>
200:                     </includes>
201:                 </configuration>
202:                 <executions>
203:                     <execution>
204:                         <goals>
205:                             <goal>integration-test</goal>
206:                             <goal>verify</goal>
207:                         </goals>
208:                     </execution>
209:                 </executions>
210:             </plugin>
211:         </plugins>
212:     </build>
213: </project>
````

## File: infra/envs/prod/templates/user_data.sh.tpl
````
  1: #!/bin/bash
  2: ###############################################################################
  3: # EC2 user-data: bootstrap a Docker Compose runtime for the Java app.
  4: #
  5: # Steps:
  6: #   1. Install Docker Engine, Compose v2 plugin, AWS CLI v2, jq, CW Agent.
  7: #   2. Pull image tags + DB endpoint from SSM and secrets from Secrets Manager.
  8: #   3. Authenticate to ECR.
  9: #   4. Render /opt/java-app/.env, fetch docker-compose.prod.yml from SSM-pointed
 10: #      S3 URI, then `docker compose up -d`.
 11: #   5. Configure CloudWatch Agent.
 12: #   6. Poll the local actuator until it returns UP. If it never does, mark
 13: #      this instance Unhealthy via the ASG API so it's replaced instead of
 14: #      lingering as a black hole behind the ALB.
 15: #
 16: # Hardening notes:
 17: #   - `set -x` echoes every command into the log to make boot regressions
 18: #     diagnosable in CloudWatch.
 19: #   - apt+curl operations retry; a transient apt mirror or download.docker.com
 20: #     blip used to leave the box partially provisioned.
 21: #   - Compose pull failure is no longer swallowed (was: `|| true`); a missing
 22: #     image must fail the boot so the ASG replaces it.
 23: ###############################################################################
 24: set -Eeuo pipefail
 25: set -x
 26: 
 27: REGION="${aws_region}"
 28: LOG_GROUP="${log_group_name}"
 29: 
 30: # ---- log everything to /var/log/user-data.log too ----
 31: exec > >(tee -a /var/log/user-data.log /var/log/cloud-init-output.log) 2>&1
 32: 
 33: echo "[user-data] starting at $(date -Iseconds)"
 34: 
 35: # ---- generic retry helper: retry <attempts> <sleep_seconds> -- <cmd...> ----
 36: retry() {
 37:   local attempts="$1"; shift
 38:   local delay="$1"; shift
 39:   local i=0
 40:   until "$@"; do
 41:     i=$((i + 1))
 42:     if (( i >= attempts )); then
 43:       echo "[user-data] command failed after $i attempts: $*" >&2
 44:       return 1
 45:     fi
 46:     echo "[user-data] attempt $i failed for: $*; sleeping $${delay}s"
 47:     sleep "$delay"
 48:   done
 49: }
 50: 
 51: # ---- mark this instance Unhealthy in its ASG and exit non-zero ----
 52: self_unhealthy() {
 53:   local reason="$1"
 54:   echo "[user-data] FATAL: $reason; marking instance Unhealthy" >&2
 55:   local token
 56:   token=$(curl -fsS --max-time 5 -X PUT "http://169.254.169.254/latest/api/token" \
 57:             -H "X-aws-ec2-metadata-token-ttl-seconds: 300" || true)
 58:   local iid
 59:   iid=$(curl -fsS --max-time 5 -H "X-aws-ec2-metadata-token: $${token}" \
 60:           "http://169.254.169.254/latest/meta-data/instance-id" || true)
 61:   if [[ -n "$${iid}" ]]; then
 62:     aws autoscaling set-instance-health \
 63:       --region "$REGION" \
 64:       --instance-id "$${iid}" \
 65:       --health-status Unhealthy \
 66:       --no-should-respect-grace-period || true
 67:   fi
 68:   exit 1
 69: }
 70: trap 'self_unhealthy "user-data trapped error on line $LINENO"' ERR
 71: 
 72: # ---- base packages ----
 73: export DEBIAN_FRONTEND=noninteractive
 74: retry 5 10 apt-get update -y
 75: retry 5 10 apt-get install -y ca-certificates curl gnupg lsb-release jq unzip
 76: 
 77: # ---- Docker Engine + Compose plugin (official Docker apt repo) ----
 78: install -m 0755 -d /etc/apt/keyrings
 79: retry 5 5 bash -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg'
 80: chmod a+r /etc/apt/keyrings/docker.gpg
 81: . /etc/os-release
 82: echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $${VERSION_CODENAME} stable" \
 83:   | tee /etc/apt/sources.list.d/docker.list >/dev/null
 84: retry 5 10 apt-get update -y
 85: retry 5 10 apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
 86: 
 87: # Docker.service is enabled here so containers auto-start across instance
 88: # stop/start cycles. Combined with `restart: unless-stopped` in compose,
 89: # this is what makes the "containers must come back on machine reboot"
 90: # requirement hold.
 91: systemctl enable --now docker
 92: 
 93: # ---- AWS CLI v2 (apt awscli is v1; replace with v2) ----
 94: retry 5 5 curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
 95: unzip -q /tmp/awscliv2.zip -d /tmp
 96: /tmp/aws/install --update
 97: rm -rf /tmp/aws /tmp/awscliv2.zip
 98: 
 99: # ---- CloudWatch Agent ----
100: retry 5 5 curl -fsSL \
101:   "https://s3.${aws_region}.amazonaws.com/amazoncloudwatch-agent-${aws_region}/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb" \
102:   -o /tmp/cwa.deb
103: dpkg -i -E /tmp/cwa.deb || apt-get install -fy
104: rm -f /tmp/cwa.deb
105: 
106: # ---- App directory ----
107: mkdir -p /opt/java-app
108: cd /opt/java-app
109: 
110: # ---- Pull release metadata + DB endpoint from SSM ----
111: # All these parameters are SecureString under the app-secrets CMK (see
112: # infra/envs/prod/secrets.tf). --with-decryption is required; the EC2 instance
113: # role grants kms:Decrypt on aws_kms_key.app_secrets via the app_inline policy.
114: BACKEND_TAG=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_backend_tag}"  --query 'Parameter.Value' --output text)
115: FRONTEND_TAG=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_frontend_tag}" --query 'Parameter.Value' --output text)
116: RELEASE_ID=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_release_id}"   --query 'Parameter.Value' --output text)
117: DB_HOST=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_db_endpoint}"     --query 'Parameter.Value' --output text)
118: DB_NAME=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_db_name}"         --query 'Parameter.Value' --output text)
119: COMPOSE_OBJ=$(aws ssm get-parameter --with-decryption --region "$REGION" --name "${ssm_compose_object}" --query 'Parameter.Value' --output text)
120: 
121: # ---- Pull DB app-user creds from Secrets Manager ----
122: DB_USER_JSON=$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "${secret_db_app_user}" --query 'SecretString' --output text)
123: DB_USER=$(echo "$DB_USER_JSON" | jq -r .username)
124: DB_PASS=$(echo "$DB_USER_JSON" | jq -r .password)
125: 
126: # JWT (only used by backend at runtime - pulled by the backend itself via
127: # Secrets Manager too; here we only export the secret name as an env var).
128: JWT_SECRET_NAME="${secret_jwt}"
129: SES_SECRET_NAME="${secret_ses}"
130: ADMIN_SECRET_NAME="${secret_admin}"
131: 
132: # ---- Render .env file (mode 0600, root-owned) ----
133: umask 077
134: cat >/opt/java-app/.env <<EOF
135: # Generated by user-data on $(date -Iseconds)
136: RELEASE_ID=$${RELEASE_ID}
137: BACKEND_IMAGE=${backend_repo_url}:$${BACKEND_TAG}
138: FRONTEND_IMAGE=${frontend_repo_url}:$${FRONTEND_TAG}
139: 
140: AWS_REGION=$${REGION}
141: 
142: DB_HOST=$${DB_HOST}
143: DB_PORT=3306
144: DB_NAME=$${DB_NAME}
145: DB_USERNAME=$${DB_USER}
146: DB_PASSWORD=$${DB_PASS}
147: 
148: JWT_SECRET_NAME=$${JWT_SECRET_NAME}
149: SES_SECRET_NAME=$${SES_SECRET_NAME}
150: ADMIN_SECRET_NAME=$${ADMIN_SECRET_NAME}
151: 
152: APP_PUBLIC_URL=https://${app_subdomain}
153: EOF
154: chmod 0600 /opt/java-app/.env
155: 
156: # ---- Fetch docker-compose.prod.yml from S3 (pointer in SSM) ----
157: if [[ "$${COMPOSE_OBJ}" == s3://* ]]; then
158:   retry 5 5 aws s3 cp "$${COMPOSE_OBJ}" /opt/java-app/docker-compose.yml
159: else
160:   echo "[user-data] WARNING: compose-object SSM value is '$${COMPOSE_OBJ}' (not s3:// URI)."
161:   # Sane default to keep the box up if compose isn't published yet.
162:   cat >/opt/java-app/docker-compose.yml <<'YAML'
163: services:
164:   placeholder:
165:     image: nginx:1.27-alpine
166:     ports: ["8080:80"]
167:     restart: unless-stopped
168: YAML
169: fi
170: 
171: # ---- ECR auth (with retry; ECR rate-limits cold logins occasionally) ----
172: retry 5 5 bash -c "aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${deployment_account}.dkr.ecr.$REGION.amazonaws.com"
173: 
174: # ---- Compose up ----
175: cd /opt/java-app
176: # `pull` failure must NOT be ignored: if a tag is missing, the box should
177: # fail provisioning and be replaced rather than start a stale image.
178: retry 3 10 docker compose --env-file /opt/java-app/.env pull
179: docker compose --env-file /opt/java-app/.env up -d --remove-orphans
180: 
181: # ---- CloudWatch Agent config ----
182: cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<JSON
183: {
184:   "agent": { "metrics_collection_interval": 60, "run_as_user": "root" },
185:   "metrics": {
186:     "namespace": "JavaApp/EC2",
187:     "append_dimensions": {
188:       "InstanceId": "\$${aws:InstanceId}",
189:       "AutoScalingGroupName": "\$${aws:AutoScalingGroupName}"
190:     },
191:     "metrics_collected": {
192:       "cpu":  { "measurement": ["cpu_usage_idle","cpu_usage_iowait","cpu_usage_user","cpu_usage_system"], "totalcpu": true },
193:       "mem":  { "measurement": ["mem_used_percent"] },
194:       "disk": { "measurement": ["used_percent"], "resources": ["/"] },
195:       "diskio": { "measurement": ["io_time"] }
196:     }
197:   },
198:   "logs": {
199:     "logs_collected": {
200:       "files": {
201:         "collect_list": [
202:           { "file_path": "/var/log/user-data.log",       "log_group_name": "$${LOG_GROUP}", "log_stream_name": "{instance_id}/user-data" },
203:           { "file_path": "/var/log/cloud-init-output.log","log_group_name": "$${LOG_GROUP}", "log_stream_name": "{instance_id}/cloud-init" },
204:           { "file_path": "/var/lib/docker/containers/*/*-json.log", "log_group_name": "$${LOG_GROUP}", "log_stream_name": "{instance_id}/docker" }
205:         ]
206:       }
207:     }
208:   }
209: }
210: JSON
211: 
212: /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
213:   -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
214: 
215: # ---- Wait for actuator/health BEFORE we hand off to the ASG. ----
216: # The ALB target group also probes /actuator/health, but it does so via the
217: # ALB SG path, which adds a DNS hop. Probing locally first lets us fail
218: # fast and self-mark Unhealthy if the app never comes up, instead of
219: # letting the ASG eventually time out the grace period.
220: echo "[user-data] waiting for /actuator/health on localhost:8080"
221: deadline=$(( $(date +%s) + 240 ))
222: ok=0
223: while (( $(date +%s) < deadline )); do
224:   if curl -fsS --max-time 5 "http://127.0.0.1:8080/actuator/health" | grep -q '"status":"UP"'; then
225:     ok=1
226:     break
227:   fi
228:   sleep 5
229: done
230: 
231: if (( ok != 1 )); then
232:   # Disable the trap so self_unhealthy runs cleanly.
233:   trap - ERR
234:   self_unhealthy "actuator never reported UP within 240s"
235: fi
236: 
237: # Disable the trap before exit so a benign cleanup doesn't trigger it.
238: trap - ERR
239: echo "[user-data] done at $(date -Iseconds)"
````

## File: infra/envs/prod/variables.tf
````hcl
  1: ###############################################################################
  2: # Inputs
  3: ###############################################################################
  4: 
  5: variable "aws_region" {
  6:   description = "Deployment region."
  7:   type        = string
  8:   default     = "us-east-1"
  9: }
 10: 
 11: variable "project" {
 12:   description = "Project tag."
 13:   type        = string
 14:   default     = "java-app"
 15: }
 16: 
 17: variable "environment" {
 18:   description = "Environment tag."
 19:   type        = string
 20:   default     = "prod"
 21: }
 22: 
 23: variable "owner" {
 24:   description = "Owner tag for cost allocation."
 25:   type        = string
 26:   default     = "platform"
 27: }
 28: 
 29: # ----------------------------------------------------------------------------
 30: # Account model
 31: # ----------------------------------------------------------------------------
 32: variable "deployment_account_id" {
 33:   description = "AWS account ID where infrastructure is deployed."
 34:   type        = string
 35: }
 36: 
 37: variable "domain_account_id" {
 38:   description = "AWS account ID where the public Route53 hosted zone lives."
 39:   type        = string
 40: }
 41: 
 42: variable "domain_account_route53_role_arn" {
 43:   description = <<EOT
 44: Role ARN in the DOMAIN account that the deployment account is allowed to
 45: assume in order to manage Route53 records (alias for the app, SES DKIM CNAMEs).
 46: EOT
 47:   type        = string
 48: }
 49: 
 50: # ----------------------------------------------------------------------------
 51: # Domain & TLS
 52: # ----------------------------------------------------------------------------
 53: variable "hosted_zone_id" {
 54:   description = "Hosted zone ID for talorlik.com in the DOMAIN account."
 55:   type        = string
 56: }
 57: 
 58: variable "root_domain" {
 59:   description = "Root domain registered in the DOMAIN account."
 60:   type        = string
 61:   default     = "talorlik.com"
 62: }
 63: 
 64: variable "app_subdomain" {
 65:   description = "Public app FQDN (must be a subdomain of root_domain)."
 66:   type        = string
 67:   default     = "java.talorlik.com"
 68: }
 69: 
 70: variable "acm_certificate_arn" {
 71:   description = "Existing ACM certificate ARN in DEPLOYMENT account covering app_subdomain."
 72:   type        = string
 73: }
 74: 
 75: # ----------------------------------------------------------------------------
 76: # Network
 77: # ----------------------------------------------------------------------------
 78: variable "vpc_cidr" {
 79:   description = "Primary CIDR for the VPC."
 80:   type        = string
 81:   default     = "10.40.0.0/16"
 82: }
 83: 
 84: variable "az_count" {
 85:   description = "Number of AZs to span."
 86:   type        = number
 87:   default     = 2
 88: }
 89: 
 90: # ----------------------------------------------------------------------------
 91: # Compute
 92: # ----------------------------------------------------------------------------
 93: variable "instance_type" {
 94:   description = "EC2 instance type for app nodes."
 95:   type        = string
 96:   default     = "t3.small"
 97: }
 98: 
 99: variable "asg_min_size" {
100:   type    = number
101:   default = 2
102: }
103: 
104: variable "asg_desired_capacity" {
105:   type    = number
106:   default = 2
107: }
108: 
109: variable "asg_max_size" {
110:   type    = number
111:   default = 6
112: }
113: 
114: variable "ubuntu_lts_codename" {
115:   description = <<EOT
116: Ubuntu LTS codename to resolve via Canonical's public SSM parameter
117: namespace (e.g. noble = 24.04). Switch to a newer codename once it is GA in
118: the target region (unverified - check Canonical's SSM listing).
119: EOT
120:   type        = string
121:   default     = "noble"
122: }
123: 
124: # ----------------------------------------------------------------------------
125: # Database
126: # ----------------------------------------------------------------------------
127: variable "rds_instance_class" {
128:   type    = string
129:   default = "db.t3.medium"
130: }
131: 
132: variable "rds_allocated_storage_gb" {
133:   type    = number
134:   default = 50
135: }
136: 
137: variable "rds_max_allocated_storage_gb" {
138:   type    = number
139:   default = 200
140: }
141: 
142: variable "rds_engine_version" {
143:   description = "RDS MySQL engine version. 8.4 is the current LTS line; the bare major lets RDS pick the latest 8.4.x patch."
144:   type        = string
145:   default     = "8.4"
146: }
147: 
148: variable "db_name" {
149:   type    = string
150:   default = "javaapp"
151: }
152: 
153: variable "db_app_username" {
154:   type    = string
155:   default = "appuser"
156: }
157: 
158: # ----------------------------------------------------------------------------
159: # Application release pointers (initial values)
160: # ----------------------------------------------------------------------------
161: variable "initial_backend_image_tag" {
162:   description = <<EOT
163: Initial image tag stored in SSM. The CI/CD app-deploy workflow updates this
164: parameter on each release. Use 'bootstrap' to indicate no app has been
165: deployed yet.
166: EOT
167:   type        = string
168:   default     = "bootstrap"
169: }
170: 
171: variable "initial_frontend_image_tag" {
172:   type    = string
173:   default = "bootstrap"
174: }
175: 
176: # ----------------------------------------------------------------------------
177: # Email
178: # ----------------------------------------------------------------------------
179: variable "ses_sender_subdomain" {
180:   description = "SES sender identity (subdomain of root_domain)."
181:   type        = string
182:   default     = "java.talorlik.com"
183: }
184: 
185: variable "ses_from_address" {
186:   description = "RFC 5322 From address used for outbound transactional mail."
187:   type        = string
188:   default     = "no-reply@java.talorlik.com"
189: }
190: 
191: # ----------------------------------------------------------------------------
192: # Observability
193: # ----------------------------------------------------------------------------
194: variable "alarm_email" {
195:   description = "Optional email subscribed to the SNS alarm topic. Empty disables subscription."
196:   type        = string
197:   default     = ""
198: }
199: 
200: variable "log_retention_days" {
201:   description = <<EOT
202: CloudWatch Logs retention for application + VPC flow log groups.
203: Dev-only environment: defaulted to 1 day (the service minimum; sub-day
204: retention is not supported). Bump to 365+ for live use; the corresponding
205: checkov skip on aws_cloudwatch_log_group.app must also be removed in
206: that case.
207: EOT
208:   type        = number
209:   default     = 1
210: }
211: 
212: # ----------------------------------------------------------------------------
213: # WAF
214: # ----------------------------------------------------------------------------
215: variable "enable_waf" {
216:   type    = bool
217:   default = true
218: }
219: 
220: # ----------------------------------------------------------------------------
221: # Destroy-friendly dev defaults
222: #
223: # This stack is a development reference impl. Defaults below are tuned so a
224: # `infra-apply -> infra-destroy -> infra-apply` cycle never blocks on
225: # protected resources, retained snapshots, or non-empty buckets/repos.
226: #
227: # BEFORE GOING LIVE, flip every default in this section:
228: #   rds_deletion_protection      false -> true
229: #   rds_skip_final_snapshot      true  -> false
230: #   rds_delete_automated_backups true  -> false
231: #   alb_logs_force_destroy       true  -> false
232: #   alb_deletion_protection      false -> true
233: # (and remove the dev-only retention skips on aws_cloudwatch_log_group.app
234: #  / .waf, plus bump var.log_retention_days; see those resources.)
235: # ----------------------------------------------------------------------------
236: variable "rds_deletion_protection" {
237:   description = "Whether RDS deletion protection is enabled. Dev default: false."
238:   type        = bool
239:   default     = false
240: }
241: 
242: variable "rds_skip_final_snapshot" {
243:   description = "Skip the RDS final snapshot at destroy time. Dev default: true (no snapshot orphan to wedge re-apply)."
244:   type        = bool
245:   default     = true
246: }
247: 
248: variable "alb_logs_force_destroy" {
249:   description = "Force-destroy the ALB log bucket even if non-empty. Dev default: true."
250:   type        = bool
251:   default     = true
252: }
253: 
254: variable "rds_delete_automated_backups" {
255:   description = "Delete retained automated backups when the instance is destroyed. Dev default: true."
256:   type        = bool
257:   default     = true
258: }
259: 
260: variable "alb_deletion_protection" {
261:   description = "Whether the ALB carries deletion protection. Dev default: false so a clean `terraform destroy` doesn't need an out-of-band flip."
262:   type        = bool
263:   default     = false
264: }
````

## File: .gitignore
````
 1: # Compiled class file
 2: *.class
 3: 
 4: # Log file
 5: *.log
 6: 
 7: # BlueJ files
 8: *.ctxt
 9: 
10: # Mobile Tools for Java (J2ME)
11: .mtj.tmp/
12: 
13: # Package Files #
14: *.jar
15: *.war
16: *.nar
17: *.ear
18: *.zip
19: *.tar.gz
20: *.rar
21: 
22: # virtual machine crash logs, see http://www.java.com/en/download/help/error_hotspot.xml
23: hs_err_pid*
24: replay_pid*
25: 
26: # Maven
27: target/
28: .mvn/wrapper/maven-wrapper.jar
29: .mvnw
30: 
31: # Gradle (unused but excluded for safety)
32: .gradle/
33: build/
34: 
35: # IDE
36: .idea/
37: *.iml
38: *.ipr
39: *.iws
40: .classpath
41: .project
42: .settings/
43: .vscode/
44: .cursor/
45: 
46: # Frontend / node
47: node_modules/
48: dist/
49: .next/
50: .nuxt/
51: .cache/
52: .parcel-cache/
53: playwright-report/
54: test-results/
55: 
56: # Terraform
57: .terraform/
58: .terraform.lock.hcl
59: *.tfstate
60: *.tfstate.*
61: *.tfplan
62: crash.log
63: 
64: # Env / secrets
65: .env
66: .env.*
67: !.env.example
68: *.pem
69: *.key
70: .github/env.local
71: .github/vars.local
72: .github/secrets.local
73: .github/secrets.local.aws
74: 
75: # OS
76: .DS_Store
77: Thumbs.db
````

## File: .github/workflows/infra-plan.yml
````yaml
 1: name: infra-plan
 2: on:
 3:   workflow_dispatch:
 4: permissions:
 5:   id-token: write
 6:   contents: read
 7: concurrency:
 8:   group: infra-plan-${{ github.ref }}
 9:   cancel-in-progress: true
10: jobs:
11:   plan:
12:     runs-on: ubuntu-latest
13:     steps:
14:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
15:       # Real GitHub runners only: assume DEPLOYMENT_ROLE_ARN via OIDC.
16:       # Skipped under `act` (env.ACT==true), where static AWS credentials are
17:       # already provided to the container via --env-file (.github/env.local).
18:       # Skipping prevents this action from clobbering the env-loaded creds and
19:       # from failing when no real OIDC token issuer is present.
20:       - uses: aws-actions/configure-aws-credentials@61815dcd50bd041e203e49132bacad1fd04d2708 # v5.1.1
21:         if: ${{ env.ACT != 'true' }}
22:         with:
23:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
24:           aws-region: ${{ vars.AWS_REGION }}
25:           role-session-name: gha-infra-plan
26:       - uses: hashicorp/setup-terraform@b9cd54a3c349d3f38e8881555d616ced269862dd # v3.1.2
27:         with:
28:           terraform_version: 1.9.8
29:       - name: terraform init
30:         working-directory: infra/envs/prod
31:         run: |
32:           terraform init \
33:             -backend-config="bucket=java-app-tfstate-${{ vars.DEPLOYMENT_ACCOUNT_ID }}-${{ vars.AWS_REGION }}" \
34:             -backend-config="region=${{ vars.AWS_REGION }}"
35:       - name: terraform fmt
36:         working-directory: infra/envs/prod
37:         run: terraform fmt -check
38:       - name: terraform validate
39:         working-directory: infra/envs/prod
40:         run: terraform validate
41:       - name: terraform plan
42:         working-directory: infra/envs/prod
43:         env:
44:           TF_VAR_aws_region: ${{ vars.AWS_REGION }}
45:           TF_VAR_deployment_account_id: ${{ vars.DEPLOYMENT_ACCOUNT_ID }}
46:           TF_VAR_domain_account_id: ${{ vars.DOMAIN_ACCOUNT_ID }}
47:           TF_VAR_domain_account_route53_role_arn: ${{ secrets.DOMAIN_ROUTE53_ROLE_ARN }}
48:           TF_VAR_hosted_zone_id: ${{ vars.HOSTED_ZONE_ID }}
49:           TF_VAR_acm_certificate_arn: ${{ secrets.ACM_CERTIFICATE_ARN }}
50:         run: |
51:           terraform plan -no-color -input=false -out=tfplan
52:           terraform show -no-color tfplan > plan.txt
53:       # Uploads to the GitHub-hosted artifact backend on real CI, and to the
54:       # emulated artifact server enabled by `--artifact-server-path` in
55:       # `.actrc` when running under act. plan.txt is also rendered into the
56:       # job summary below for at-a-glance inspection.
57:       - uses: actions/upload-artifact@b7c566a772e6b6bfb58ed0dc250532a479d7789f # v6.0.0
58:         with:
59:           name: terraform-plan
60:           path: |
61:             infra/envs/prod/tfplan
62:             infra/envs/prod/plan.txt
63:       - name: Surface plan in job summary
64:         run: |
65:           {
66:             echo "### terraform plan"
67:             echo ""
68:             echo '```'
69:             head -c 60000 infra/envs/prod/plan.txt
70:             echo ""
71:             echo '```'
72:           } >> "$GITHUB_STEP_SUMMARY"
````

## File: infra/envs/prod/asg.tf
````hcl
  1: ###############################################################################
  2: # Launch Template + Auto Scaling Group
  3: #
  4: # Latest Ubuntu LTS resolved at apply time via Canonical's public SSM
  5: # parameter namespace. IMDSv2 required, encrypted EBS, no SSH ingress.
  6: ###############################################################################
  7: 
  8: # Canonical publishes Ubuntu AMI IDs at predictable SSM paths under
  9: # /aws/service/canonical/ubuntu/server/<codename>/stable/current/amd64/hvm/ebs-gp3/ami-id
 10: data "aws_ssm_parameter" "ubuntu_ami" {
 11:   name = "/aws/service/canonical/ubuntu/server/${var.ubuntu_lts_codename}/stable/current/amd64/hvm/ebs-gp3/ami-id"
 12: }
 13: 
 14: # CloudWatch log group consumed by the CloudWatch agent on the instance.
 15: resource "aws_cloudwatch_log_group" "app" {
 16:   # checkov:skip=CKV_AWS_338:dev-only environment, intentional short retention. Bump var.log_retention_days to >=365 for live use and remove this skip.
 17:   name              = "/${var.project}/${var.environment}/app"
 18:   retention_in_days = var.log_retention_days
 19:   kms_key_id        = aws_kms_key.app_secrets.arn
 20:   tags              = local.common_tags
 21: }
 22: 
 23: resource "aws_ssm_parameter" "log_group_app" {
 24:   name   = local.ssm_keys.log_group_app
 25:   type   = "SecureString"
 26:   key_id = aws_kms_key.app_secrets.key_id
 27:   value  = aws_cloudwatch_log_group.app.name
 28: }
 29: 
 30: # ----------------------------------------------------------------------------
 31: # User-data script
 32: #
 33: # Renders a templated bash script that installs Docker + Compose + CloudWatch
 34: # Agent, fetches release metadata from SSM and the compose file from S3,
 35: # performs ECR auth, then `docker compose up -d`.
 36: # ----------------------------------------------------------------------------
 37: locals {
 38:   user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tpl", {
 39:     aws_region         = var.aws_region
 40:     ssm_compose_object = local.ssm_keys.compose_object
 41:     ssm_backend_tag    = local.ssm_keys.backend_image_tag
 42:     ssm_frontend_tag   = local.ssm_keys.frontend_image_tag
 43:     ssm_release_id     = local.ssm_keys.release_id
 44:     ssm_db_endpoint    = local.ssm_keys.db_endpoint
 45:     ssm_db_name        = local.ssm_keys.db_name
 46:     secret_db_app_user = aws_secretsmanager_secret.db_app_user.name
 47:     secret_admin       = aws_secretsmanager_secret.admin.name
 48:     secret_jwt         = aws_secretsmanager_secret.jwt.name
 49:     secret_ses         = aws_secretsmanager_secret.ses.name
 50:     backend_repo_url   = aws_ecr_repository.this["backend"].repository_url
 51:     frontend_repo_url  = aws_ecr_repository.this["frontend"].repository_url
 52:     log_group_name     = aws_cloudwatch_log_group.app.name
 53:     deployment_account = var.deployment_account_id
 54:     app_subdomain      = var.app_subdomain
 55:   }))
 56: }
 57: 
 58: # ----------------------------------------------------------------------------
 59: # Launch Template + ASG
 60: # ----------------------------------------------------------------------------
 61: module "asg" {
 62:   # checkov:skip=CKV_TF_1:source pinned via registry tag (~> 7.7). Commit-hash pinning rejected for upstream-maintained modules; CKV_TF_2 (tag pin) covers the supply-chain intent.
 63:   source  = "terraform-aws-modules/autoscaling/aws"
 64:   version = "~> 7.7"
 65: 
 66:   name = "${local.name_prefix}-asg"
 67: 
 68:   min_size            = var.asg_min_size
 69:   desired_capacity    = var.asg_desired_capacity
 70:   max_size            = var.asg_max_size
 71:   vpc_zone_identifier = module.vpc.private_subnets
 72:   health_check_type   = "ELB"
 73: 
 74:   # First boot on a fresh Ubuntu image runs apt + AWS CLI v2 install + CWA
 75:   # install + ECR pull + Spring Boot startup. On t3.small with cold caches
 76:   # this regularly takes 4-7 min. 300s grace was racing the slowest path
 77:   # and producing one unhealthy instance per refresh; 600s gives Spring
 78:   # Boot plus the actuator probe enough headroom.
 79:   health_check_grace_period = 600
 80: 
 81:   # Attach to ALB target group created in alb.tf.
 82:   target_group_arns = [module.alb.target_groups["app"].arn]
 83: 
 84:   # Launch Template
 85:   create_launch_template = true
 86:   launch_template_name   = "${local.name_prefix}-lt"
 87:   update_default_version = true
 88: 
 89:   image_id      = data.aws_ssm_parameter.ubuntu_ami.value
 90:   instance_type = var.instance_type
 91:   user_data     = local.user_data
 92: 
 93:   iam_instance_profile_name = aws_iam_instance_profile.app.name
 94: 
 95:   security_groups = [aws_security_group.app.id]
 96: 
 97:   metadata_options = {
 98:     http_endpoint               = "enabled"
 99:     http_tokens                 = "required" # IMDSv2 required
100:     http_put_response_hop_limit = 2          # 2 = container-friendly (Docker bridge)
101:     instance_metadata_tags      = "enabled"
102:   }
103: 
104:   block_device_mappings = [
105:     {
106:       device_name = "/dev/sda1"
107:       ebs = {
108:         volume_size           = 30
109:         volume_type           = "gp3"
110:         encrypted             = true
111:         delete_on_termination = true
112:       }
113:     }
114:   ]
115: 
116:   tag_specifications = [
117:     {
118:       resource_type = "instance"
119:       tags          = merge(local.common_tags, { Name = "${local.name_prefix}-app" })
120:     },
121:     {
122:       resource_type = "volume"
123:       tags          = local.common_tags
124:     }
125:   ]
126: 
127:   # Target tracking on ALB request count per target.
128:   scaling_policies = {
129:     request_count = {
130:       policy_type = "TargetTrackingScaling"
131:       target_tracking_configuration = {
132:         predefined_metric_specification = {
133:           predefined_metric_type = "ALBRequestCountPerTarget"
134:           resource_label         = "${module.alb.arn_suffix}/${module.alb.target_groups["app"].arn_suffix}"
135:         }
136:         target_value = 200
137:       }
138:     }
139:     cpu = {
140:       policy_type = "TargetTrackingScaling"
141:       target_tracking_configuration = {
142:         predefined_metric_specification = {
143:           predefined_metric_type = "ASGAverageCPUUtilization"
144:         }
145:         target_value = 60
146:       }
147:     }
148:   }
149: 
150:   # Instance refresh: launch-before-terminate posture (min_healthy=100).
151:   instance_refresh = {
152:     strategy = "Rolling"
153:     preferences = {
154:       min_healthy_percentage = 100
155:       max_healthy_percentage = 200
156:       # Match health_check_grace_period; warmup of 180s undercounts a cold
157:       # boot and starts pre-tracking metrics on a not-yet-ready instance.
158:       instance_warmup = 300
159:       auto_rollback   = true
160:     }
161:     triggers = ["tag"]
162:   }
163: 
164:   enabled_metrics = [
165:     "GroupInServiceInstances",
166:     "GroupDesiredCapacity",
167:     "GroupTotalInstances",
168:     "GroupPendingInstances",
169:     "GroupTerminatingInstances",
170:   ]
171: 
172:   tags = local.common_tags
173: }
````

## File: infra/envs/prod/secrets.tf
````hcl
  1: ###############################################################################
  2: # Secrets Manager + KMS for application runtime secrets.
  3: #
  4: # - Master DB password is created by RDS-managed master credentials in rds.tf.
  5: # - App-user DB password is generated here (Terraform random_password) and
  6: #   the matching MySQL account is provisioned by aws_lambda_function.db_bootstrap
  7: #   (see db_bootstrap.tf), which is invoked by terraform_data.db_bootstrap on
  8: #   RDS replacement or on app-user secret rotation. Re-running the Lambda is
  9: #   idempotent (CREATE USER IF NOT EXISTS + ALTER USER syncs the password).
 10: # - Admin bootstrap secret is generated and seeded by the backend's startup
 11: #   routine if not already present.
 12: # - JWT signing key is generated here.
 13: # - SES sender config is a plain JSON struct of identity + region.
 14: ###############################################################################
 15: 
 16: # CMK for application secrets, SSM parameters, and CloudWatch log groups.
 17: # Policy must allow CloudWatch Logs service to use the key for the specific
 18: # log groups, otherwise CreateLogGroup fails with AccessDeniedException.
 19: resource "aws_kms_key" "app_secrets" {
 20:   description = "App secrets, SSM parameters, and log group encryption"
 21:   # Dev default: KMS minimum (7). Re-apply creates a new key anyway; this
 22:   # just minimizes how long the old pending-deletion key sits in the account.
 23:   deletion_window_in_days = 7
 24:   enable_key_rotation     = true
 25: 
 26:   policy = jsonencode({
 27:     Version = "2012-10-17"
 28:     Statement = [
 29:       {
 30:         Sid       = "EnableRootPermissions"
 31:         Effect    = "Allow"
 32:         Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${var.deployment_account_id}:root" }
 33:         Action    = "kms:*"
 34:         Resource  = "*"
 35:       },
 36:       {
 37:         Sid       = "AllowCloudWatchLogsUseOfKey"
 38:         Effect    = "Allow"
 39:         Principal = { Service = "logs.${var.aws_region}.amazonaws.com" }
 40:         Action = [
 41:           "kms:Encrypt",
 42:           "kms:Decrypt",
 43:           "kms:ReEncrypt*",
 44:           "kms:GenerateDataKey*",
 45:           "kms:DescribeKey",
 46:         ]
 47:         Resource = "*"
 48:         Condition = {
 49:           # ArnLike supports a list of patterns (any-match). The first covers
 50:           # the application/VPC-flow log groups under /<project>/<env>/...;
 51:           # the second covers AWS WAF logging targets, which must start with
 52:           # "aws-waf-logs-" per the WAF logging-destination naming rule.
 53:           ArnLike = {
 54:             "kms:EncryptionContext:aws:logs:arn" = [
 55:               "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${var.deployment_account_id}:log-group:/${var.project}/${var.environment}/*",
 56:               "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${var.deployment_account_id}:log-group:aws-waf-logs-${var.project}-${var.environment}*",
 57:             ]
 58:           }
 59:         }
 60:       },
 61:       {
 62:         Sid       = "AllowSnsUseOfKey"
 63:         Effect    = "Allow"
 64:         Principal = { Service = "sns.amazonaws.com" }
 65:         Action    = ["kms:Decrypt", "kms:GenerateDataKey*"]
 66:         Resource  = "*"
 67:       },
 68:       {
 69:         Sid       = "AllowEventsToPublishToSnsViaKey"
 70:         Effect    = "Allow"
 71:         Principal = { Service = "events.amazonaws.com" }
 72:         Action    = ["kms:Decrypt", "kms:GenerateDataKey*"]
 73:         Resource  = "*"
 74:       }
 75:     ]
 76:   })
 77: }
 78: 
 79: resource "aws_kms_alias" "app_secrets" {
 80:   name          = "alias/${local.name_prefix}-secrets"
 81:   target_key_id = aws_kms_key.app_secrets.key_id
 82: }
 83: 
 84: # ----------------------------------------------------------------------------
 85: # Application DB user
 86: # ----------------------------------------------------------------------------
 87: resource "random_password" "db_app_user" {
 88:   length           = 32
 89:   special          = true
 90:   override_special = "!#%&*+-=?_"
 91: }
 92: 
 93: resource "random_password" "admin_bootstrap" {
 94:   length  = 24
 95:   special = false
 96: }
 97: 
 98: resource "random_password" "jwt_signing" {
 99:   length  = 64
100:   special = false
101: }
102: 
103: resource "aws_secretsmanager_secret" "db_app_user" {
104:   # checkov:skip=CKV2_AWS_57:rotation Lambda is intentionally out of scope for this reference impl; rotation handled manually for dev-only env. Wire aws_secretsmanager_secret_rotation + a rotation Lambda for live use.
105:   name        = "${local.secret_prefix}/db/app-user"
106:   description = "App user credentials (least-privileged DB role)"
107:   kms_key_id  = aws_kms_key.app_secrets.arn
108:   # Dev default: 0 = delete immediately on `terraform destroy`. This avoids
109:   # the 7-day PendingDeletion window that otherwise blocks a re-apply with
110:   # the same secret name. Bump to 7-30 before going live.
111:   recovery_window_in_days = 0
112: }
113: 
114: resource "aws_secretsmanager_secret_version" "db_app_user" {
115:   secret_id = aws_secretsmanager_secret.db_app_user.id
116:   secret_string = jsonencode({
117:     username = var.db_app_username
118:     password = random_password.db_app_user.result
119:   })
120: }
121: 
122: # ----------------------------------------------------------------------------
123: # Admin bootstrap (idempotent seed at startup)
124: # ----------------------------------------------------------------------------
125: resource "aws_secretsmanager_secret" "admin" {
126:   # checkov:skip=CKV2_AWS_57:bootstrap admin secret read once at app startup; rotation Lambda intentionally out of scope.
127:   name        = "${local.secret_prefix}/admin"
128:   description = "Bootstrap admin user. Read once at app startup."
129:   kms_key_id  = aws_kms_key.app_secrets.arn
130:   # Dev default: 0 = delete immediately on `terraform destroy`. This avoids
131:   # the 7-day PendingDeletion window that otherwise blocks a re-apply with
132:   # the same secret name. Bump to 7-30 before going live.
133:   recovery_window_in_days = 0
134: }
135: 
136: resource "aws_secretsmanager_secret_version" "admin" {
137:   secret_id = aws_secretsmanager_secret.admin.id
138:   secret_string = jsonencode({
139:     username = "admin@${var.root_domain}"
140:     password = random_password.admin_bootstrap.result
141:   })
142: }
143: 
144: # ----------------------------------------------------------------------------
145: # JWT signing secret
146: # ----------------------------------------------------------------------------
147: resource "aws_secretsmanager_secret" "jwt" {
148:   # checkov:skip=CKV2_AWS_57:JWT signing key rotation requires coordinated app-side key roll; rotation Lambda intentionally out of scope for this reference impl.
149:   name        = "${local.secret_prefix}/jwt"
150:   description = "HMAC signing key for backend JWT"
151:   kms_key_id  = aws_kms_key.app_secrets.arn
152:   # Dev default: 0 = delete immediately on `terraform destroy`. This avoids
153:   # the 7-day PendingDeletion window that otherwise blocks a re-apply with
154:   # the same secret name. Bump to 7-30 before going live.
155:   recovery_window_in_days = 0
156: }
157: 
158: resource "aws_secretsmanager_secret_version" "jwt" {
159:   secret_id = aws_secretsmanager_secret.jwt.id
160:   secret_string = jsonencode({
161:     signing_key = random_password.jwt_signing.result
162:     issuer      = "https://${var.app_subdomain}"
163:   })
164: }
165: 
166: # ----------------------------------------------------------------------------
167: # SES sender config
168: # ----------------------------------------------------------------------------
169: resource "aws_secretsmanager_secret" "ses" {
170:   # checkov:skip=CKV2_AWS_57:SES sender config is non-credential JSON (region+identity); rotation does not apply.
171:   name        = "${local.secret_prefix}/ses"
172:   description = "SES sender identity / region configuration"
173:   kms_key_id  = aws_kms_key.app_secrets.arn
174:   # Dev default: 0 = delete immediately on `terraform destroy`. This avoids
175:   # the 7-day PendingDeletion window that otherwise blocks a re-apply with
176:   # the same secret name. Bump to 7-30 before going live.
177:   recovery_window_in_days = 0
178: }
179: 
180: resource "aws_secretsmanager_secret_version" "ses" {
181:   secret_id = aws_secretsmanager_secret.ses.id
182:   secret_string = jsonencode({
183:     region        = var.aws_region
184:     sender_domain = var.ses_sender_subdomain
185:     from_address  = var.ses_from_address
186:   })
187: }
188: 
189: # ----------------------------------------------------------------------------
190: # Non-secret runtime config (kept as SSM Parameter Store, not Secrets Manager)
191: # ----------------------------------------------------------------------------
192: resource "aws_ssm_parameter" "compose_object" {
193:   # The instance user data downloads docker-compose.prod.yml from this
194:   # location. The value is set later via CI (or by an operator copying the
195:   # compose file to S3 and writing the s3:// URI here).
196:   # SecureString + CMK to satisfy CKV2_AWS_34 (operationally the value is
197:   # an s3:// URI, not a secret, but encryption is cheap and uniform).
198:   name        = local.ssm_keys.compose_object
199:   description = "S3 URI of docker-compose.prod.yml used by EC2 user data"
200:   type        = "SecureString"
201:   key_id      = aws_kms_key.app_secrets.key_id
202:   value       = "PENDING"
203: 
204:   lifecycle {
205:     # CI updates the value via `aws ssm put-parameter --overwrite`; ignore so
206:     # Terraform doesn't revert it on next apply. Same applies to the three
207:     # release-pointer params below.
208:     ignore_changes = [value]
209:   }
210: }
211: 
212: resource "aws_ssm_parameter" "backend_image_tag" {
213:   name        = local.ssm_keys.backend_image_tag
214:   description = "Backend image tag (commit SHA) consumed by user data"
215:   type        = "SecureString"
216:   key_id      = aws_kms_key.app_secrets.key_id
217:   value       = var.initial_backend_image_tag
218: 
219:   lifecycle {
220:     # CI/CD updates this on each release; we don't want Terraform to revert it.
221:     ignore_changes = [value]
222:   }
223: }
224: 
225: resource "aws_ssm_parameter" "frontend_image_tag" {
226:   name   = local.ssm_keys.frontend_image_tag
227:   type   = "SecureString"
228:   key_id = aws_kms_key.app_secrets.key_id
229:   value  = var.initial_frontend_image_tag
230:   lifecycle {
231:     ignore_changes = [value]
232:   }
233: }
234: 
235: resource "aws_ssm_parameter" "release_id" {
236:   name   = local.ssm_keys.release_id
237:   type   = "SecureString"
238:   key_id = aws_kms_key.app_secrets.key_id
239:   value  = "bootstrap"
240:   lifecycle {
241:     ignore_changes = [value]
242:   }
243: }
244: 
245: # ----------------------------------------------------------------------------
246: # ASG capacity, exposed as SSM parameters so app-deploy can re-arm capacity
247: # after `app-destroy` scales it to 0/0/0 without duplicating the desired
248: # values into GitHub repo vars. Terraform stays the single source of truth:
249: # bumping `var.asg_*` and re-applying immediately changes what the next
250: # deploy will scale back to.
251: #
252: # Plain `String` (not SecureString): these are non-sensitive operational
253: # config; KMS overhead and the resulting kms:Decrypt grant on the deploy
254: # role would be noise.
255: # ----------------------------------------------------------------------------
256: resource "aws_ssm_parameter" "asg_min_size" {
257:   name        = local.ssm_keys.asg_min_size
258:   description = "Canonical ASG MinSize. app-deploy reads this to re-arm capacity after a destroy."
259:   type        = "String"
260:   value       = tostring(var.asg_min_size)
261: }
262: 
263: resource "aws_ssm_parameter" "asg_desired_capacity" {
264:   name        = local.ssm_keys.asg_desired_capacity
265:   description = "Canonical ASG DesiredCapacity."
266:   type        = "String"
267:   value       = tostring(var.asg_desired_capacity)
268: }
269: 
270: resource "aws_ssm_parameter" "asg_max_size" {
271:   name        = local.ssm_keys.asg_max_size
272:   description = "Canonical ASG MaxSize."
273:   type        = "String"
274:   value       = tostring(var.asg_max_size)
275: }
````

## File: .github/workflows/app-destroy.yml
````yaml
  1: ###############################################################################
  2: # app-destroy
  3: #
  4: # Tears down only the application-layer artifacts (ECR images, ASG instances,
  5: # SSM release pointers, S3 compose object). Leaves the underlying
  6: # infrastructure intact so a fresh deploy can come up over the same VPC/ALB/RDS.
  7: #
  8: # Sequence:
  9: #   1. Confirm the user typed the destroy phrase exactly.
 10: #   2. Set the ASG min/desired/max to 0 and wait until in-service count is 0.
 11: #      This stops the running containers without churning the launch template.
 12: #   3. Reset the three SSM release pointers to "bootstrap" so a future
 13: #      instance launch won't try to pull a deleted image tag.
 14: #   4. Delete the docker-compose.prod.yml S3 object referenced by the
 15: #      compose-object SSM parameter.
 16: #   5. Empty both ECR repositories (delete every image / image-index in
 17: #      `java-app/backend` and `java-app/frontend`).
 18: #
 19: # Use `infra-destroy.yml` afterwards to remove the underlying infrastructure
 20: # itself.
 21: #
 22: # Two explicit gates are required to proceed:
 23: #   confirm                   = DESTROY
 24: #   acknowledge_runtime_break = I-ACKNOWLEDGE-RUNTIME-BREAK
 25: #
 26: # Local act invocation:
 27: #   act workflow_dispatch -W .github/workflows/app-destroy.yml \
 28: #     --input confirm=DESTROY \
 29: #     --input acknowledge_runtime_break=I-ACKNOWLEDGE-RUNTIME-BREAK
 30: ###############################################################################
 31: name: app-destroy
 32: on:
 33:   workflow_dispatch:
 34:     inputs:
 35:       confirm:
 36:         description: 'Type DESTROY (uppercase) to confirm'
 37:         required: true
 38:         default: ''
 39:       acknowledge_runtime_break:
 40:         # Second explicit gate. Scaling the ASG to 0/0/0, deleting the
 41:         # docker-compose.prod.yml S3 object, and purging ECR are all
 42:         # destructive in ways that *will* break the running app even if
 43:         # the underlying VPC/ALB/RDS stays up. The next app-deploy now
 44:         # self-heals (it re-arms the ASG and re-publishes the compose
 45:         # object), but a destroy still tears down live traffic between
 46:         # those two moments. Forcing a second typed acknowledgement
 47:         # makes single-click triggers (web UI, gh cli typo, automation
 48:         # accident) fail fast.
 49:         description: "Type 'I-ACKNOWLEDGE-RUNTIME-BREAK' to proceed"
 50:         required: true
 51:         default: ''
 52: permissions:
 53:   id-token: write
 54:   contents: read
 55: concurrency:
 56:   group: app-destroy
 57:   cancel-in-progress: false
 58: jobs:
 59:   destroy:
 60:     name: tear down app layer
 61:     runs-on: ubuntu-latest
 62:     environment: prod   # forces the environment-protection rule (manual approval)
 63:     env:
 64:       AWS_PAGER: ""
 65:     steps:
 66:       - name: Validate confirmation phrase
 67:         run: |
 68:           if [ "${{ github.event.inputs.confirm }}" != "DESTROY" ]; then
 69:             echo "::error::confirm input must be exactly 'DESTROY'."
 70:             exit 1
 71:           fi
 72:           if [ "${{ github.event.inputs.acknowledge_runtime_break }}" != "I-ACKNOWLEDGE-RUNTIME-BREAK" ]; then
 73:             echo "::error::acknowledge_runtime_break input must be exactly 'I-ACKNOWLEDGE-RUNTIME-BREAK'."
 74:             exit 1
 75:           fi
 76:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
 77:       # Ensures `aws` is on PATH. GitHub-hosted ubuntu-latest already ships
 78:       # AWS CLI v2; nektos/act's default medium image does not. Idempotent.
 79:       - name: Ensure AWS CLI present
 80:         shell: bash
 81:         run: |
 82:           set -euo pipefail
 83:           if command -v aws >/dev/null 2>&1; then
 84:             aws --version
 85:             exit 0
 86:           fi
 87:           tmp=$(mktemp -d)
 88:           curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp/awscliv2.zip"
 89:           unzip -q "$tmp/awscliv2.zip" -d "$tmp"
 90:           sudo "$tmp/aws/install" --update
 91:           aws --version
 92:       # Real GitHub runners only: assume DEPLOYMENT_ROLE_ARN via OIDC.
 93:       # Skipped under `act` (env.ACT==true), where static AWS credentials are
 94:       # already provided to the container via --env-file (.github/env.local).
 95:       # Skipping prevents this action from clobbering the env-loaded creds and
 96:       # from failing when no real OIDC token issuer is present.
 97:       - uses: aws-actions/configure-aws-credentials@61815dcd50bd041e203e49132bacad1fd04d2708 # v5.1.1
 98:         if: ${{ env.ACT != 'true' }}
 99:         with:
100:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
101:           aws-region: ${{ vars.AWS_REGION }}
102:           role-session-name: gha-app-destroy
103:       # -------------------------------------------------------------------
104:       # 1. Resolve ASG name (deterministic in this stack, but follow the
105:       #    same Tags-based lookup the deploy workflow uses).
106:       # -------------------------------------------------------------------
107:       - id: asg
108:         name: Resolve ASG name
109:         run: |
110:           NAME=$(aws autoscaling describe-auto-scaling-groups \
111:             --query "AutoScalingGroups[?Tags[?Key=='Project' && Value=='java-app'] && Tags[?Key=='Environment' && Value=='prod']].AutoScalingGroupName | [0]" \
112:             --output text)
113:           if [ "$NAME" = "None" ] || [ -z "$NAME" ]; then
114:             NAME="java-app-prod-asg"
115:           fi
116:           echo "name=$NAME" >> "$GITHUB_OUTPUT"
117:       # -------------------------------------------------------------------
118:       # 2. Scale ASG to 0 and wait for instances to drain.
119:       # -------------------------------------------------------------------
120:       - name: Scale ASG to 0
121:         run: |
122:           aws autoscaling update-auto-scaling-group \
123:             --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
124:             --min-size 0 --desired-capacity 0 --max-size 0
125:       - name: Wait for ASG to drain
126:         run: |
127:           for i in $(seq 1 60); do
128:             COUNT=$(aws autoscaling describe-auto-scaling-groups \
129:               --auto-scaling-group-names "${{ steps.asg.outputs.name }}" \
130:               --query "AutoScalingGroups[0].Instances | length(@)" \
131:               --output text)
132:             echo "in-service instances: $COUNT"
133:             if [ "$COUNT" = "0" ]; then exit 0; fi
134:             sleep 15
135:           done
136:           echo "::error::timed out waiting for ASG to drain"
137:           exit 1
138:       # -------------------------------------------------------------------
139:       # 3. Reset release pointers so a re-scale doesn't pull a deleted tag.
140:       # -------------------------------------------------------------------
141:       - name: Reset SSM release pointers to 'bootstrap'
142:         run: |
143:           KMS_ALIAS="alias/java-app-prod-secrets"
144:           for p in /java-app/prod/backend-image-tag /java-app/prod/frontend-image-tag /java-app/prod/release-id; do
145:             aws ssm put-parameter --name "$p" --type SecureString --key-id "$KMS_ALIAS" --overwrite --value "bootstrap"
146:           done
147:       # -------------------------------------------------------------------
148:       # 4. Delete the published compose-object from S3.
149:       # -------------------------------------------------------------------
150:       - name: Delete compose object in S3
151:         run: |
152:           BUCKET="java-app-prod-config-${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
153:           aws s3 rm "s3://$BUCKET/docker-compose.prod.yml" || true
154:       # -------------------------------------------------------------------
155:       # 5. Empty both ECR repositories.
156:       # -------------------------------------------------------------------
157:       - name: Purge ECR images
158:         run: |
159:           for repo in java-app/backend java-app/frontend; do
160:             echo "purging $repo"
161:             IDS=$(aws ecr list-images --repository-name "$repo" --query 'imageIds[*]' --output json)
162:             COUNT=$(echo "$IDS" | jq 'length')
163:             if [ "$COUNT" -gt 0 ]; then
164:               # batch-delete-image accepts up to 100 image IDs at a time;
165:               # if there are more, page in chunks.
166:               echo "$IDS" | jq -c '. as $a | range(0; ($a | length); 100) | $a[.:.+100]' | \
167:                 while read -r CHUNK; do
168:                   aws ecr batch-delete-image \
169:                     --repository-name "$repo" \
170:                     --image-ids "$CHUNK"
171:                 done
172:             fi
173:           done
````

## File: docs/index.html
````html
  1: <!DOCTYPE html>
  2: <html lang="en">
  3: <head>
  4:   <meta charset="UTF-8">
  5:   <meta name="viewport" content="width=device-width, initial-scale=1.0">
  6:   <title>Dockerized Java App on EC2 - Documentation</title>
  7:   <meta name="description" content="Project documentation for deploying Dockerized Java applications on AWS EC2, including architecture, deployment, operations, security, and ADRs.">
  8:   <meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1">
  9:   <meta name="author" content="Tal Orlik">
 10:   <link rel="canonical" href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/index.html">
 11:   <meta property="og:type" content="website">
 12:   <meta property="og:url" content="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/index.html">
 13:   <meta property="og:title" content="Dockerized Java App on EC2 - Documentation">
 14:   <meta property="og:description" content="Production-shaped Dockerized Java deployment reference with Terraform IaC and GitHub Actions CI/CD.">
 15:   <meta property="og:image" content="https://github.com/talorlik/dockerized-java-app-on-ec2/raw/main/docs/header_banner.png">
 16:   <meta property="og:site_name" content="Dockerized Java App on EC2">
 17:   <meta property="og:locale" content="en_US">
 18:   <meta name="twitter:card" content="summary_large_image">
 19:   <meta name="twitter:title" content="Dockerized Java App on EC2 - Documentation">
 20:   <meta name="twitter:description" content="Architecture, deployment, operations, and security documentation for the project.">
 21:   <meta name="twitter:image" content="https://github.com/talorlik/dockerized-java-app-on-ec2/raw/main/docs/header_banner.png">
 22:   <meta name="theme-color" content="#0366d6">
 23:   <link rel="icon" type="image/x-icon" href="favicon.ico">
 24:   <link id="theme-stylesheet" rel="stylesheet" href="light-theme.css">
 25:   <script type="application/ld+json">
 26:     {
 27:       "@context": "https://schema.org",
 28:       "@type": "TechArticle",
 29:       "headline": "Dockerized Java App on EC2 - Documentation",
 30:       "description": "Project documentation for deploying Dockerized Java applications on AWS EC2, including architecture, deployment, operations, security, and ADRs.",
 31:       "url": "https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/index.html",
 32:       "image": "https://github.com/talorlik/dockerized-java-app-on-ec2/raw/main/docs/header_banner.png",
 33:       "inLanguage": "en",
 34:       "author": {
 35:         "@type": "Person",
 36:         "name": "Tal Orlik"
 37:       },
 38:       "publisher": {
 39:         "@type": "Organization",
 40:         "name": "Dockerized Java App on EC2"
 41:       },
 42:       "mainEntityOfPage": {
 43:         "@type": "WebPage",
 44:         "@id": "https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/index.html"
 45:       }
 46:     }
 47:   </script>
 48: </head>
 49: <body>
 50:   <a href="#main-content" class="skip-link">Skip to main content</a>
 51:   <nav class="navbar">
 52:     <div class="nav-container">
 53:       <a href="#hero" class="nav-logo">Dockerized Java App Docs</a>
 54:       <button class="mobile-menu-toggle" id="mobileMenuToggle" aria-label="Toggle navigation menu">☰</button>
 55:       <ul class="nav-menu" id="navMenu">
 56:         <li><a href="#overview">Overview</a></li>
 57:         <li><a href="#getting-started">Getting Started</a></li>
 58:         <li><a href="#architecture">Architecture</a></li>
 59:         <li><a href="#documentation">Documentation</a></li>
 60:         <li><a href="#operations">Operations</a></li>
 61:         <li><a href="#security">Security</a></li>
 62:         <li><a href="#repository">Repository</a></li>
 63:         <li>
 64:           <button id="themeToggle" class="theme-toggle" aria-label="Toggle theme" title="Toggle theme">
 65:             <span id="sunIcon" class="icon hidden">☀️</span>
 66:             <span id="moonIcon" class="icon">🌙</span>
 67:           </button>
 68:         </li>
 69:       </ul>
 70:     </div>
 71:   </nav>
 72:   <main id="main-content">
 73:     <section id="hero" class="hero">
 74:       <h1>Dockerized Java App on EC2</h1>
 75:       <p>
 76:         Production-shaped reference implementation for deploying Dockerized Java
 77:         applications on EC2 Auto Scaling behind an ALB, with RDS MySQL,
 78:         Terraform infrastructure, and GitHub Actions delivery workflows. The
 79:         signup app included here is a sample workload.
 80:       </p>
 81:       <img src="header_banner.png" alt="Dockerized Java app architecture banner" class="hero-banner">
 82:     </section>
 83:     <section id="overview">
 84:       <h2>Overview</h2>
 85:       <div class="doc-grid">
 86:         <article class="card">
 87:           <h3>What This Project Includes</h3>
 88:           <ul>
 89:             <li>Spring Boot backend with JWT auth, RBAC, and Flyway migrations</li>
 90:             <li>Nginx frontend container proxying <code>/api/*</code> to backend</li>
 91:             <li>Private RDS MySQL (central shared DB) with stateless EC2 compute</li>
 92:             <li>Terraform-managed AWS foundation across deployment and domain accounts</li>
 93:             <li>GitHub Actions OIDC delivery with ASG Instance Refresh rollout</li>
 94:           </ul>
 95:           <p class="ask-docs-inline">
 96:             <a href="https://notebooklm.google.com/notebook/df2387ab-6685-4322-bb3d-7add2e7bf341/preview" target="_blank" rel="noopener noreferrer" class="ask-docs-link">
 97:               <span class="ask-docs-icon" aria-hidden="true">
 98:                 <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
 99:                   <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
100:                 </svg>
101:               </span>
102:               Ask the docs
103:             </a>
104:           </p>
105:         </article>
106:         <article class="card">
107:           <h3>Target Runtime Topology</h3>
108:           <p>
109:             Ingress path: Internet -&gt; Route53 alias -&gt; ALB HTTPS listener -&gt;
110:             EC2 ASG private subnets -&gt; Docker Compose frontend/backend -&gt; RDS MySQL.
111:           </p>
112:           <p>
113:             Primary endpoint: <code>https://java.talorlik.com</code>.
114:             Operations and architecture details are aligned with
115:             <code>PROJECT_OVERVIEW.md</code>, PRD, and Technical Requirements docs.
116:           </p>
117:         </article>
118:       </div>
119:     </section>
120:     <section id="getting-started">
121:       <h2>Getting Started</h2>
122:       <div class="doc-grid">
123:         <article class="card">
124:           <h3>Prerequisites Checklist</h3>
125:           <ul>
126:             <li>DEPLOYMENT account for ALB, EC2/ASG, RDS, ECR, IAM, Secrets Manager, and ACM</li>
127:             <li>DOMAIN account (or same account) hosting Route53 zone for <code>talorlik.com</code></li>
128:             <li><code>DEPLOYMENT_ROLE_ARN</code> with GitHub OIDC trust configured</li>
129:             <li><code>DOMAIN_ROUTE53_ROLE_ARN</code> allowing DNS record updates (when cross-account)</li>
130:             <li>ACM certificate in DEPLOYMENT account for <code>java.talorlik.com</code></li>
131:             <li>GitHub variables: <code>AWS_REGION</code>, <code>DEPLOYMENT_ACCOUNT_ID</code>, <code>DOMAIN_ACCOUNT_ID</code>, <code>HOSTED_ZONE_ID</code></li>
132:             <li>GitHub secrets: <code>ACM_CERTIFICATE_ARN</code>, <code>DEPLOYMENT_ROLE_ARN</code>, <code>DOMAIN_ROUTE53_ROLE_ARN</code></li>
133:             <li>GitHub Environment named <code>prod</code> for apply/destroy workflows</li>
134:           </ul>
135:         </article>
136:         <article class="card">
137:           <h3>Deploy From Scratch</h3>
138:           <ol>
139:             <li>Complete one-time prerequisites from <code>README.md</code>: DEPLOYMENT account, DOMAIN account role chain, ACM cert, GitHub vars/secrets, and <code>prod</code> environment.</li>
140:             <li>Bootstrap remote Terraform state in <code>infra/bootstrap</code> and copy the backend block output into <code>infra/envs/prod/backend.tf</code>.</li>
141:             <li>Optionally run <code>infra-plan.yml</code>, then run <code>infra-apply.yml</code> to provision VPC, ALB, ASG, RDS, ECR, IAM, Route53, and observability resources.</li>
142:             <li>Run <code>app-deploy.yml</code> to execute CI gates, push SHA-tagged images to ECR, update SSM release pointers, and trigger ASG instance refresh.</li>
143:             <li>Retrieve first admin credentials from Secrets Manager and sign in.</li>
144:           </ol>
145:         </article>
146:         <article class="card">
147:           <h3>Deploy Commands</h3>
148:           <pre><code># 1) Bootstrap state (local, one-shot)
149: cd infra/bootstrap
150: export AWS_REGION=us-east-1
151: terraform init
152: terraform apply -var aws_region=us-east-1 -var state_bucket_name="java-app-tfstate-&lt;DEPLOYMENT_ACCOUNT_ID&gt;-us-east-1"
153: terraform output backend_block_example
154: # 2) (Optional) Terraform plan workflow
155: gh workflow run infra-plan.yml
156: gh run watch
157: # 3) Apply infrastructure
158: gh workflow run infra-apply.yml
159: gh run watch
160: # 4) Deploy app images + refresh ASG
161: gh workflow run app-deploy.yml
162: gh run watch</code></pre>
163:         </article>
164:         <article class="card">
165:           <h3>Destroy Stack (Reverse Order)</h3>
166:           <p>
167:             Destroy follows the README sequence. Both workflow-based destroy paths require
168:             the exact confirmation value <code>DESTROY</code>.
169:           </p>
170:           <pre><code># 1) Tear down application layer
171: gh workflow run app-destroy.yml -f confirm=DESTROY
172: gh run watch
173: # 2) Tear down production infrastructure
174: gh workflow run infra-destroy.yml -f confirm=DESTROY -f run_app_cleanup=true
175: gh run watch</code></pre>
176:           <p>
177:             Optional: remove <code>infra/bootstrap</code> resources only when decommissioning
178:             the project completely.
179:           </p>
180:         </article>
181:       </div>
182:     </section>
183:     <section id="architecture">
184:       <h2>Architecture</h2>
185:       <div class="card">
186:         <p>
187:           Route53 aliases <code>java.talorlik.com</code> to an internet-facing ALB.
188:           The ALB forwards to EC2 instances in an Auto Scaling Group, where
189:           frontend and backend containers run via Docker Compose. The backend
190:           connects to private RDS MySQL, and secrets are sourced from AWS
191:           Secrets Manager.
192:         </p>
193:       </div>
194:       <figure class="architecture-diagram-wrapper" aria-label="Project architecture diagram">
195:         <img src="auxiliary/architecture-diagrams/diagrams/java_app_architecture.png" alt="Project architecture diagram" class="architecture-diagram">
196:       </figure>
197:       <div class="card">
198:         <h3>Key Paths</h3>
199:         <ul>
200:           <li><code>app/backend/</code> - Spring Boot application</li>
201:           <li><code>app/frontend/</code> - static frontend and Nginx config</li>
202:           <li><code>app/docker/</code> - local and prod compose files</li>
203:           <li><code>infra/envs/prod/</code> - production Terraform environment</li>
204:           <li><code>.github/workflows/</code> - CI/CD pipelines</li>
205:         </ul>
206:       </div>
207:     </section>
208:     <section id="documentation">
209:       <h2>Documentation</h2>
210:       <h3>Core Documentation</h3>
211:       <div class="doc-grid">
212:         <div class="doc-item">
213:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/planning/PROJECT_OVERVIEW.md" target="_blank" rel="noopener noreferrer">Project Overview</a>
214:           <p>Canonical architecture and implementation blueprint.</p>
215:         </div>
216:         <div class="doc-item">
217:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/planning/PRODUCT_REQUIREMENTS_DOCUMENT.md" target="_blank" rel="noopener noreferrer">Product Requirements</a>
218:           <p>Product scope and feature requirements.</p>
219:         </div>
220:         <div class="doc-item">
221:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/planning/TECHNICAL_REQUIREMENTS_REFERENCE.md" target="_blank" rel="noopener noreferrer">Technical Requirements</a>
222:           <p>Detailed technical constraints and expected behavior.</p>
223:         </div>
224:         <div class="doc-item">
225:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/architecture/ARCHITECTURE.md" target="_blank" rel="noopener noreferrer">Architecture Guide</a>
226:           <p>Architecture-focused implementation reference.</p>
227:         </div>
228:       </div>
229:       <h3>Operations Guides</h3>
230:       <div class="doc-grid">
231:         <div class="doc-item">
232:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/operations_guide/00-prerequisites.md" target="_blank" rel="noopener noreferrer">00 - Prerequisites</a>
233:           <p>Account, IAM, and environment prerequisites.</p>
234:         </div>
235:         <div class="doc-item">
236:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/operations_guide/01-bootstrap-state.md" target="_blank" rel="noopener noreferrer">01 - Bootstrap State</a>
237:           <p>Terraform remote state bootstrap process.</p>
238:         </div>
239:         <div class="doc-item">
240:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/operations_guide/02-domain-account-dns.md" target="_blank" rel="noopener noreferrer">02 - Domain Account DNS</a>
241:           <p>Cross-account Route53 and DNS setup.</p>
242:         </div>
243:         <div class="doc-item">
244:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/operations_guide/03-deployment.md" target="_blank" rel="noopener noreferrer">03 - Deployment</a>
245:           <p>Production deployment steps and sequencing.</p>
246:         </div>
247:         <div class="doc-item">
248:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/operations_guide/04-operations.md" target="_blank" rel="noopener noreferrer">04 - Operations</a>
249:           <p>Runbook for day-2 operations and lifecycle tasks.</p>
250:         </div>
251:         <div class="doc-item">
252:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/operations_guide/05-security-model.md" target="_blank" rel="noopener noreferrer">05 - Security Model</a>
253:           <p>Security baseline and hardening model.</p>
254:         </div>
255:       </div>
256:       <h3>Planning and Decisions</h3>
257:       <div class="doc-grid">
258:         <div class="doc-item">
259:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/planning/ENGINEERING_EXECUTION_BACKLOG.md" target="_blank" rel="noopener noreferrer">Engineering Execution Backlog</a>
260:           <p>Execution plan and work breakdown.</p>
261:         </div>
262:         <div class="doc-item">
263:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/planning/INITIAL_HL_DESCRIPTION.md" target="_blank" rel="noopener noreferrer">Initial High-Level Description</a>
264:           <p>Initial project framing and goals.</p>
265:         </div>
266:         <div class="doc-item">
267:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/adr/0001-frontend-stack.md" target="_blank" rel="noopener noreferrer">ADR 0001 - Frontend Stack</a>
268:           <p>Decision record for frontend technology.</p>
269:         </div>
270:         <div class="doc-item">
271:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/adr/0002-auth-model.md" target="_blank" rel="noopener noreferrer">ADR 0002 - Auth Model</a>
272:           <p>Authentication and authorization decision.</p>
273:         </div>
274:         <div class="doc-item">
275:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/adr/0003-waf.md" target="_blank" rel="noopener noreferrer">ADR 0003 - WAF</a>
276:           <p>Web application firewall decision record.</p>
277:         </div>
278:         <div class="doc-item">
279:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/adr/0004-ubuntu-resolution.md" target="_blank" rel="noopener noreferrer">ADR 0004 - Ubuntu Resolution</a>
280:           <p>Base OS selection and resolution details.</p>
281:         </div>
282:         <div class="doc-item">
283:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/adr/0005-secret-rotation.md" target="_blank" rel="noopener noreferrer">ADR 0005 - Secret Rotation</a>
284:           <p>Secret rotation model and operational stance.</p>
285:         </div>
286:         <div class="doc-item">
287:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/adr/0006-provider-account-model.md" target="_blank" rel="noopener noreferrer">ADR 0006 - Provider Account Model</a>
288:           <p>AWS provider and account topology decision.</p>
289:         </div>
290:         <div class="doc-item">
291:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/adr/0007-dev-environment-cycle-defaults.md" target="_blank" rel="noopener noreferrer">ADR 0007 - Dev Environment Cycle Defaults</a>
292:           <p>Dev-cycle defaults and production-revert checklist.</p>
293:         </div>
294:         <div class="doc-item">
295:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/adr/0008-mysql-8-4-upgrade.md" target="_blank" rel="noopener noreferrer">ADR 0008 - MySQL 8.4 Upgrade</a>
296:           <p>RDS MySQL 8.0 to 8.4 upgrade decision and follow-up actions.</p>
297:         </div>
298:       </div>
299:       <h3>NotebookLM and Diagram Docs</h3>
300:       <div class="doc-grid">
301:         <div class="doc-item">
302:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/NotebookLM/WELCOME_NOTE.md" target="_blank" rel="noopener noreferrer">NotebookLM Welcome Note</a>
303:           <p>NotebookLM onboarding and context guidance.</p>
304:         </div>
305:         <div class="doc-item">
306:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/NotebookLM/SLIDE_DECK_DETAILED_INSTRUCTIONS.md" target="_blank" rel="noopener noreferrer">Slide Deck Detailed Instructions</a>
307:           <p>Detailed prompts for presentation generation.</p>
308:         </div>
309:         <div class="doc-item">
310:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/NotebookLM/SLIDE_DECK_PRESENTER_INSTRUCTIONS.md" target="_blank" rel="noopener noreferrer">Slide Deck Presenter Instructions</a>
311:           <p>Presenter notes and delivery prompts.</p>
312:         </div>
313:         <div class="doc-item">
314:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/NotebookLM/QUIZ_GENERATION_INSTRUCTIONS.md" target="_blank" rel="noopener noreferrer">Quiz Generation Instructions</a>
315:           <p>Prompting guide for quiz generation workflows.</p>
316:         </div>
317:         <div class="doc-item">
318:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/NotebookLM/FLASHCARD_GENERATION_INSTRUCTIONS.md" target="_blank" rel="noopener noreferrer">Flashcard Generation Instructions</a>
319:           <p>Prompting guide for flashcard generation.</p>
320:         </div>
321:         <div class="doc-item">
322:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/architecture-diagrams/SETUP.md" target="_blank" rel="noopener noreferrer">Architecture Diagram Setup</a>
323:           <p>How to generate and maintain architecture diagrams.</p>
324:         </div>
325:         <div class="doc-item">
326:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/architecture-diagrams/INSTRUCTIONS.md" target="_blank" rel="noopener noreferrer">Architecture Diagram Instructions</a>
327:           <p>Diagram authoring and export instructions.</p>
328:         </div>
329:         <div class="doc-item">
330:           <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/architecture-diagrams/AGENT.md" target="_blank" rel="noopener noreferrer">Architecture Diagram Agent Notes</a>
331:           <p>Agent-specific notes for diagram workflows.</p>
332:         </div>
333:       </div>
334:     </section>
335:     <section id="operations">
336:       <h2>Operations</h2>
337:       <div class="card ask-docs-card">
338:         <a href="https://notebooklm.google.com/notebook/df2387ab-6685-4322-bb3d-7add2e7bf341/preview" target="_blank" rel="noopener noreferrer" class="ask-docs-link">
339:           <span class="ask-docs-icon" aria-hidden="true">
340:             <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
341:               <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
342:             </svg>
343:           </span>
344:           Ask about this project
345:         </a>
346:       </div>
347:       <div class="doc-grid">
348:         <article class="card">
349:           <h3>Release Workflow</h3>
350:           <ul>
351:             <li><code>ci.yml</code> gates backend tests, compose smoke, e2e, and Terraform checks</li>
352:             <li><code>infra-plan.yml</code> produces plan artifacts for infrastructure changes</li>
353:             <li><code>infra-apply.yml</code> applies production infrastructure and config object wiring</li>
354:             <li><code>app-deploy.yml</code> publishes immutable SHA image tags and rolls ASG safely</li>
355:             <li><code>app-destroy.yml</code> and <code>infra-destroy.yml</code> execute controlled teardown</li>
356:           </ul>
357:         </article>
358:         <article class="card">
359:           <h3>Notes</h3>
360:           <p>
361:             Image tags are release-specific. The deployment model updates SSM
362:             image tag parameters and performs launch-before-terminate refreshes.
363:           </p>
364:           <p>
365:             Health checks are performed after deployment to verify application
366:             readiness.
367:           </p>
368:           <p>
369:             For MySQL 8.4 auth-plugin preflight and recovery details, use the
370:             runbook at
371:             <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/operations_guide/runbooks/2026-05-08_appuser_auth_plugin_conversion.md" target="_blank" rel="noopener noreferrer">Appuser Auth Plugin Conversion</a>. Routine
372:             <code>appuser</code> provisioning, password sync on rotation, and
373:             auth-plugin alignment on engine upgrade are handled automatically
374:             by <code>aws_lambda_function.db_bootstrap</code> (see
375:             <code>infra/envs/prod/db_bootstrap.tf</code>); the runbook above
376:             is the manual fall-back.
377:           </p>
378:           <p>
379:             For ASG-flap diagnostics (instances launched + terminated in a
380:             tight loop), use the runbook at
381:             <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/operations_guide/runbooks/2026-05-10_asg_flapping_investigation.md" target="_blank" rel="noopener noreferrer">ASG Flapping Investigation (RB-ASG-001)</a>.
382:             Covers the S3-read IAM grant on the compose bucket and the DB
383:             bootstrap Lambda dependency.
384:           </p>
385:         </article>
386:         <article class="card">
387:           <h3>Local CI Loop (<code>act</code>)</h3>
388:           <p>
389:             Every workflow runs locally under
390:             <a href="https://github.com/nektos/act" target="_blank" rel="noopener noreferrer">nektos/act</a>.
391:             <code>.actrc</code> pins
392:             <code>catthehacker/ubuntu:full-24.04</code> and loads
393:             <code>.github/{env,secrets,vars}.local</code>; templates live next
394:             to them as <code>*.example</code>. The
395:             <code>aws-actions/configure-aws-credentials</code> OIDC step is
396:             gated <code>if: env.ACT != 'true'</code> in every AWS-touching
397:             workflow, and <code>app-deploy.yml</code> carries an
398:             <code>act</code>-only ECR docker login fallback so
399:             <code>docker push</code> picks up credentials reliably.
400:           </p>
401:           <pre><code># Quality gate.
402: act -W .github/workflows/ci.yml workflow_dispatch
403: # Single CI job (skip the heavier compose-smoke).
404: act -W .github/workflows/ci.yml workflow_dispatch -j backend
405: # Build/push deploy job (writes to real ECR + ASG; restrict scope).
406: act -W .github/workflows/app-deploy.yml workflow_dispatch -j build-test
407: # Terraform plan (read-only).
408: act -W .github/workflows/infra-plan.yml workflow_dispatch</code></pre>
409:           <p>
410:             Full audit and rationale:
411:             <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/docs/auxiliary/operations_guide/2026-05-09_workflows_act_alignment_review.md" target="_blank" rel="noopener noreferrer">2026-05-09 Workflows / <code>act</code> Alignment Review</a>.
412:             <code>terraform apply</code> and <code>terraform destroy</code>
413:             paths are intentionally not exercised under <code>act</code>.
414:           </p>
415:         </article>
416:       </div>
417:     </section>
418:     <section id="security">
419:       <h2>Security</h2>
420:       <div class="card">
421:         <ul>
422:           <li>No public RDS access; DB lives in private subnets only</li>
423:           <li>EC2 access uses SSM Session Manager, not SSH ingress</li>
424:           <li>Secrets are stored in Secrets Manager, never committed in repo</li>
425:           <li>WAF is attached to ALB with managed rule groups and rate limiting</li>
426:           <li>IMDSv2 and least-privilege IAM are part of the baseline model</li>
427:         </ul>
428:       </div>
429:     </section>
430:     <section id="repository">
431:       <h2>Repository</h2>
432:       <div class="card">
433:         <p>
434:           GitHub: <a href="https://github.com/talorlik/dockerized-java-app-on-ec2" target="_blank" rel="noopener noreferrer">talorlik/dockerized-java-app-on-ec2</a>
435:         </p>
436:         <p>
437:           Root README: <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/README.md" target="_blank" rel="noopener noreferrer">README.md</a>
438:         </p>
439:       </div>
440:     </section>
441:   </main>
442:   <footer>
443:     <p><strong>Dockerized Java App Documentation</strong></p>
444:     <p>Copyright (c) Tal Orlik</p>
445:   </footer>
446:   <button id="scrollToTopButton" class="scroll-to-top" aria-label="Scroll to top" title="Scroll to top">
447:     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
448:       <path d="M18 15l-6-6-6 6"></path>
449:     </svg>
450:   </button>
451:   <script src="main.js"></script>
452: </body>
453: </html>
````

## File: infra/envs/prod/iam.tf
````hcl
  1: ###############################################################################
  2: # IAM
  3: #
  4: # Instance role used by EC2 app nodes. Permissions:
  5: #   - Read approved secrets and SSM parameters.
  6: #   - Pull from ECR.
  7: #   - Write logs/metrics to CloudWatch.
  8: #   - Send mail through SES from the approved identity.
  9: #   - SSM Session Manager (no SSH).
 10: ###############################################################################
 11: 
 12: data "aws_iam_policy_document" "ec2_assume" {
 13:   statement {
 14:     actions = ["sts:AssumeRole"]
 15:     principals {
 16:       type        = "Service"
 17:       identifiers = ["ec2.amazonaws.com"]
 18:     }
 19:   }
 20: }
 21: 
 22: resource "aws_iam_role" "app_instance" {
 23:   name               = "${local.name_prefix}-app-instance"
 24:   assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
 25:   tags               = local.common_tags
 26: }
 27: 
 28: # AWS-managed: SSM core (Session Manager).
 29: resource "aws_iam_role_policy_attachment" "ssm_core" {
 30:   role       = aws_iam_role.app_instance.name
 31:   policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
 32: }
 33: 
 34: # AWS-managed: CloudWatch Agent server policy.
 35: resource "aws_iam_role_policy_attachment" "cw_agent" {
 36:   role       = aws_iam_role.app_instance.name
 37:   policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
 38: }
 39: 
 40: # AWS-managed: ECR read-only.
 41: resource "aws_iam_role_policy_attachment" "ecr_pull" {
 42:   role       = aws_iam_role.app_instance.name
 43:   policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 44: }
 45: 
 46: # Inline: scoped read of approved secrets, SSM params, and SES send from
 47: # the approved identity only.
 48: #
 49: # Per-statement CKV_AWS_111 / CKV_AWS_356 notes:
 50: #   - Writes are now scoped to the project's log groups (PutCloudWatchLogs).
 51: #   - The remaining "*" resources (DescribeLogGroups, GetAuthorizationToken,
 52: #     SetInstanceHealth) have no resource-level scoping in IAM; the
 53: #     suppression below documents that.
 54: data "aws_iam_policy_document" "app_inline" {
 55:   # checkov:skip=CKV_AWS_356:Remaining wildcard resources are on actions that have no resource-level scoping in IAM (logs:DescribeLogGroups, ecr:GetAuthorizationToken, autoscaling:SetInstanceHealth).
 56:   # checkov:skip=CKV_AWS_111:Same as above; the write actions logs:Create*/PutLogEvents are scoped to the app log group ARN. SetInstanceHealth is a write action that AWS does not resource-scope.
 57: 
 58:   # Secrets Manager read for known ARNs.
 59:   statement {
 60:     sid    = "ReadAppSecrets"
 61:     effect = "Allow"
 62:     actions = [
 63:       "secretsmanager:GetSecretValue",
 64:       "secretsmanager:DescribeSecret",
 65:     ]
 66:     resources = [
 67:       aws_secretsmanager_secret.db_app_user.arn,
 68:       aws_secretsmanager_secret.admin.arn,
 69:       aws_secretsmanager_secret.jwt.arn,
 70:       aws_secretsmanager_secret.ses.arn,
 71:       module.rds.db_instance_master_user_secret_arn,
 72:     ]
 73:   }
 74: 
 75:   # SSM Parameter Store reads under the project namespace.
 76:   statement {
 77:     sid    = "ReadAppSsmParams"
 78:     effect = "Allow"
 79:     actions = [
 80:       "ssm:GetParameter",
 81:       "ssm:GetParameters",
 82:       "ssm:GetParametersByPath",
 83:     ]
 84:     resources = ["arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${var.deployment_account_id}:parameter${local.secret_prefix}/*"]
 85:   }
 86: 
 87:   # KMS decrypt for the secrets/parameters CMK.
 88:   statement {
 89:     sid       = "DecryptAppCmk"
 90:     effect    = "Allow"
 91:     actions   = ["kms:Decrypt", "kms:DescribeKey"]
 92:     resources = [aws_kms_key.app_secrets.arn]
 93:   }
 94: 
 95:   # CloudWatch Logs writes scoped to the app log group (group + streams).
 96:   statement {
 97:     sid    = "PutCloudWatchLogs"
 98:     effect = "Allow"
 99:     actions = [
100:       "logs:CreateLogGroup",
101:       "logs:CreateLogStream",
102:       "logs:PutLogEvents",
103:       "logs:DescribeLogStreams",
104:     ]
105:     resources = [
106:       aws_cloudwatch_log_group.app.arn,
107:       "${aws_cloudwatch_log_group.app.arn}:*",
108:     ]
109:   }
110: 
111:   # logs:DescribeLogGroups has no resource-level scoping in IAM.
112:   statement {
113:     sid       = "DescribeLogGroupsAccountWide"
114:     effect    = "Allow"
115:     actions   = ["logs:DescribeLogGroups"]
116:     resources = ["*"]
117:   }
118: 
119:   # SES: send only from the approved identity.
120:   statement {
121:     sid    = "SesSendFromApprovedIdentity"
122:     effect = "Allow"
123:     actions = [
124:       "ses:SendEmail",
125:       "ses:SendRawEmail",
126:     ]
127:     resources = [
128:       "arn:${data.aws_partition.current.partition}:ses:${var.aws_region}:${var.deployment_account_id}:identity/${var.ses_sender_subdomain}",
129:     ]
130:   }
131: 
132:   # ECR: GetAuthorizationToken is account-scoped (must be *).
133:   statement {
134:     sid       = "EcrAuth"
135:     effect    = "Allow"
136:     actions   = ["ecr:GetAuthorizationToken"]
137:     resources = ["*"]
138:   }
139: 
140:   # S3 read of the published docker-compose object. The bucket is created
141:   # out-of-band by .github/workflows/infra-apply.yml using the deterministic
142:   # name "${var.project}-${var.environment}-config-${var.deployment_account_id}";
143:   # user-data resolves the s3:// URI from SSM /java-app/prod/compose-object and
144:   # runs `aws s3 cp` at boot. Without this grant the HEAD on the object returns
145:   # 403, user-data fails, the ERR trap calls self_unhealthy with
146:   # --no-should-respect-grace-period, and the ASG flaps every ~115s. The object
147:   # is encrypted with aws_kms_key.app_secrets; KMS Decrypt is granted in the
148:   # DecryptAppCmk statement above. See runbook RB-ASG-001
149:   # (docs/auxiliary/operations_guide/runbooks/2026-05-10_asg_flapping_investigation.md).
150:   statement {
151:     sid    = "ReadComposeObject"
152:     effect = "Allow"
153:     actions = [
154:       "s3:GetObject",
155:     ]
156:     resources = [
157:       "arn:${data.aws_partition.current.partition}:s3:::${var.project}-${var.environment}-config-${var.deployment_account_id}/docker-compose.prod.yml",
158:     ]
159:   }
160: 
161:   # Allow the user-data boot script to mark its own instance Unhealthy if
162:   # the actuator never returns UP within the boot deadline. Without this
163:   # the box would linger as a black hole behind the ALB until the grace
164:   # period expires; with it the ASG replaces it immediately.
165:   # SetInstanceHealth has no resource-level scoping in IAM, so this must
166:   # be Resource:* and is gated by the aws:SourceArn condition matching the
167:   # caller's own instance ARN, scoping it in practice to instances of THIS
168:   # ASG even if the role were ever reused elsewhere.
169:   statement {
170:     sid       = "SelfMarkInstanceUnhealthy"
171:     effect    = "Allow"
172:     actions   = ["autoscaling:SetInstanceHealth"]
173:     resources = ["*"]
174:   }
175: }
176: 
177: resource "aws_iam_policy" "app_inline" {
178:   name   = "${local.name_prefix}-app-inline"
179:   policy = data.aws_iam_policy_document.app_inline.json
180: }
181: 
182: resource "aws_iam_role_policy_attachment" "app_inline" {
183:   role       = aws_iam_role.app_instance.name
184:   policy_arn = aws_iam_policy.app_inline.arn
185: }
186: 
187: resource "aws_iam_instance_profile" "app" {
188:   name = "${local.name_prefix}-app-instance"
189:   role = aws_iam_role.app_instance.name
190: }
191: 
192: ###############################################################################
193: # AWS Service-Linked Roles
194: #
195: # EC2 Auto Scaling and Elastic Load Balancing both rely on account-scoped
196: # SLRs. They are pre-created out-of-band by the GitHub Actions workflows
197: # (.github/workflows/infra-apply.yml and infra-destroy.yml) using
198: # `aws iam create-service-linked-role` before `terraform init`. They are
199: # intentionally not managed by Terraform: they are account-wide singletons,
200: # never deleted by this stack, and pre-creation in the workflow eliminates
201: # the original race against ASG capacity validation without import blocks
202: # or removed-blocks gymnastics.
203: ###############################################################################
````

## File: .github/workflows/app-deploy.yml
````yaml
  1: name: app-deploy
  2: on:
  3:   workflow_dispatch:
  4:     inputs:
  5:       image_tag:
  6:         description: "Override image tag (defaults to commit SHA)"
  7:         required: false
  8: permissions:
  9:   id-token: write
 10:   contents: read
 11: concurrency:
 12:   group: app-deploy
 13:   cancel-in-progress: false
 14: jobs:
 15:   build-test:
 16:     name: build + test (gate)
 17:     uses: ./.github/workflows/ci.yml
 18:     secrets: inherit
 19:   deploy:
 20:     name: build, push, refresh
 21:     needs: build-test
 22:     runs-on: ubuntu-latest
 23:     environment: prod
 24:     env:
 25:       AWS_PAGER: ""
 26:     steps:
 27:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
 28:       # Ensures `aws` is on PATH. GitHub-hosted ubuntu-latest already ships
 29:       # AWS CLI v2; nektos/act's default medium image does not. Idempotent.
 30:       - name: Ensure AWS CLI present
 31:         shell: bash
 32:         run: |
 33:           set -euo pipefail
 34:           if command -v aws >/dev/null 2>&1; then
 35:             aws --version
 36:             exit 0
 37:           fi
 38:           tmp=$(mktemp -d)
 39:           curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp/awscliv2.zip"
 40:           unzip -q "$tmp/awscliv2.zip" -d "$tmp"
 41:           sudo "$tmp/aws/install" --update
 42:           aws --version
 43:       # Real GitHub runners only: assume DEPLOYMENT_ROLE_ARN via OIDC.
 44:       # Skipped under `act` (env.ACT==true), where static AWS credentials are
 45:       # already provided to the container via --env-file (.github/env.local).
 46:       # Skipping prevents this action from clobbering the env-loaded creds and
 47:       # from failing when no real OIDC token issuer is present.
 48:       - uses: aws-actions/configure-aws-credentials@61815dcd50bd041e203e49132bacad1fd04d2708 # v5.1.1
 49:         if: ${{ env.ACT != 'true' }}
 50:         with:
 51:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
 52:           aws-region: ${{ vars.AWS_REGION }}
 53:           role-session-name: gha-app-deploy
 54:       - id: tag
 55:         run: |
 56:           TAG="${{ github.event.inputs.image_tag }}"
 57:           if [ -z "$TAG" ]; then TAG="sha-${GITHUB_SHA::12}"; fi
 58:           echo "tag=$TAG" >> $GITHUB_OUTPUT
 59:       # Real GitHub runners only. The action's JS path performs
 60:       # GetAuthorizationToken + `docker login` and registers a Post step that
 61:       # logs out at job end. Under `act`, switch to a shell login below to
 62:       # avoid the action's HOME/credential-helper edge cases inside the
 63:       # catthehacker runner image.
 64:       - uses: aws-actions/amazon-ecr-login@19d944daaa35f0fa1d3f7f8af1d3f2e5de25c5b7 # v2.1.4
 65:         if: ${{ env.ACT != 'true' }}
 66:         id: ecr
 67:         with:
 68:           registries: ${{ vars.DEPLOYMENT_ACCOUNT_ID }}
 69:       # `act`-only fallback. Uses the AWS CLI installed by the previous step
 70:       # and the static creds loaded from .github/env.local. Writes plain
 71:       # base64 `auths` entries into $HOME/.docker/config.json, which is what
 72:       # docker push in subsequent steps reads. No Post-step logout under act
 73:       # by design - the runner container is ephemeral.
 74:       - name: ECR docker login (act fallback)
 75:         if: ${{ env.ACT == 'true' }}
 76:         shell: bash
 77:         run: |
 78:           set -euo pipefail
 79:           aws ecr get-login-password --region "${{ vars.AWS_REGION }}" \
 80:             | docker login \
 81:                 --username AWS \
 82:                 --password-stdin \
 83:                 "${{ vars.DEPLOYMENT_ACCOUNT_ID }}.dkr.ecr.${{ vars.AWS_REGION }}.amazonaws.com"
 84:       - name: Resolve ECR repo URLs
 85:         id: repos
 86:         run: |
 87:           ACC="${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
 88:           REG="${{ vars.AWS_REGION }}"
 89:           echo "backend=$ACC.dkr.ecr.$REG.amazonaws.com/java-app/backend"   >> $GITHUB_OUTPUT
 90:           echo "frontend=$ACC.dkr.ecr.$REG.amazonaws.com/java-app/frontend" >> $GITHUB_OUTPUT
 91:       - name: Build + push backend
 92:         run: |
 93:           docker build -t ${{ steps.repos.outputs.backend }}:${{ steps.tag.outputs.tag }} app/backend
 94:           docker push ${{ steps.repos.outputs.backend }}:${{ steps.tag.outputs.tag }}
 95:       - name: Build + push frontend
 96:         run: |
 97:           docker build -t ${{ steps.repos.outputs.frontend }}:${{ steps.tag.outputs.tag }} app/frontend
 98:           docker push ${{ steps.repos.outputs.frontend }}:${{ steps.tag.outputs.tag }}
 99:       - name: Update SSM release params
100:         # Parameters are created by Terraform as SecureString under the
101:         # app-secrets CMK (alias/java-app-prod-secrets). --overwrite preserves
102:         # the existing type/key when neither --type nor --key-id is passed,
103:         # but we set them explicitly so a put-parameter against a (re-)created
104:         # param still lands as SecureString.
105:         run: |
106:           KMS_ALIAS="alias/java-app-prod-secrets"
107:           aws ssm put-parameter --name "/java-app/prod/backend-image-tag"  --type SecureString --key-id "$KMS_ALIAS" --overwrite --value "${{ steps.tag.outputs.tag }}"
108:           aws ssm put-parameter --name "/java-app/prod/frontend-image-tag" --type SecureString --key-id "$KMS_ALIAS" --overwrite --value "${{ steps.tag.outputs.tag }}"
109:           aws ssm put-parameter --name "/java-app/prod/release-id"         --type SecureString --key-id "$KMS_ALIAS" --overwrite --value "${{ github.sha }}"
110:       # ------------------------------------------------------------------
111:       # Publish docker-compose.prod.yml to the config bucket.
112:       #
113:       # `app-destroy` deletes this object as part of tearing down the app
114:       # layer, so a deploy must always re-publish it before instances boot.
115:       # SSE-KMS uses the existing app-secrets CMK so the bucket policy
116:       # (kms-only PutObject) accepts the upload.
117:       # The step is idempotent: a no-op when the bucket already holds an
118:       # identical object (S3 still records a new version because the bucket
119:       # is versioned, but the cost is trivial and it removes the destroy/
120:       # deploy ordering hazard).
121:       # ------------------------------------------------------------------
122:       - name: Publish docker-compose.prod.yml to S3
123:         run: |
124:           BUCKET="java-app-prod-config-${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
125:           aws s3 cp app/docker/docker-compose.prod.yml \
126:             "s3://$BUCKET/docker-compose.prod.yml" \
127:             --sse aws:kms \
128:             --sse-kms-key-id alias/java-app-prod-secrets
129:       - name: Resolve ASG name
130:         id: asg
131:         run: |
132:           NAME=$(aws autoscaling describe-auto-scaling-groups \
133:             --query "AutoScalingGroups[?Tags[?Key=='Project' && Value=='java-app'] && Tags[?Key=='Environment' && Value=='prod']].AutoScalingGroupName | [0]" \
134:             --output text)
135:           if [ "$NAME" = "None" ] || [ -z "$NAME" ]; then
136:             # Fallback to deterministic name pattern
137:             NAME="java-app-prod-asg"
138:           fi
139:           echo "name=$NAME" >> $GITHUB_OUTPUT
140:       # ------------------------------------------------------------------
141:       # Re-arm ASG capacity if `app-destroy` (or any operator) scaled it
142:       # to 0/0/0. Without this step a deploy after a destroy is a silent
143:       # no-op: instance-refresh on an empty ASG returns Successful with
144:       # InstancesToUpdate=0 and the post-deploy smoke 503s against an
145:       # empty target group.
146:       #
147:       # Capacity targets are read from SSM parameters owned by Terraform
148:       # (var.asg_min_size / var.asg_desired_capacity / var.asg_max_size,
149:       # surfaced as /java-app/prod/asg/{min-size,desired-capacity,max-size}).
150:       # Hardcoded fallbacks to 2/2/6 cover the cold-start case before the
151:       # first apply that introduced these parameters.
152:       #
153:       # Output `scaled_from_zero` is consumed by the refresh steps below:
154:       # when true, fresh instances launched by the scale-up are already on
155:       # the latest LT and an instance refresh would needlessly cycle them.
156:       # ------------------------------------------------------------------
157:       - name: Re-arm ASG capacity if at zero
158:         id: rearm
159:         run: |
160:           set -euo pipefail
161:           NAME="${{ steps.asg.outputs.name }}"
162:           # Read canonical capacity from SSM (terraform-managed). Each lookup
163:           # falls back to its hardcoded default if the parameter isn't there
164:           # yet (first deploy after this change, before terraform apply).
165:           ssm_get() {
166:             aws ssm get-parameter --name "$1" --query 'Parameter.Value' --output text 2>/dev/null || echo ""
167:           }
168:           MIN=$(ssm_get /java-app/prod/asg/min-size);         MIN="${MIN:-2}"
169:           DES=$(ssm_get /java-app/prod/asg/desired-capacity); DES="${DES:-2}"
170:           MAX=$(ssm_get /java-app/prod/asg/max-size);         MAX="${MAX:-6}"
171:           echo "target capacity (from SSM/defaults): min=$MIN desired=$DES max=$MAX"
172:           read -r CUR_MIN CUR_DES CUR_MAX <<< "$(aws autoscaling describe-auto-scaling-groups \
173:             --auto-scaling-group-names "$NAME" \
174:             --query 'AutoScalingGroups[0].[MinSize,DesiredCapacity,MaxSize]' \
175:             --output text)"
176:           echo "current min=$CUR_MIN desired=$CUR_DES max=$CUR_MAX"
177:           if [ "$CUR_MIN" = "0" ] && [ "$CUR_DES" = "0" ] && [ "$CUR_MAX" = "0" ]; then
178:             echo "ASG is at 0/0/0; scaling to $MIN/$DES/$MAX"
179:             aws autoscaling update-auto-scaling-group \
180:               --auto-scaling-group-name "$NAME" \
181:               --min-size "$MIN" --desired-capacity "$DES" --max-size "$MAX"
182:             echo "scaled_from_zero=true"  >> "$GITHUB_OUTPUT"
183:           else
184:             echo "scaled_from_zero=false" >> "$GITHUB_OUTPUT"
185:           fi
186:       # Skipped when we just scaled from 0: the new instances launched by
187:       # the scale-up are already on the current launch template version.
188:       - name: Trigger ASG instance refresh
189:         id: refresh
190:         if: steps.rearm.outputs.scaled_from_zero != 'true'
191:         run: |
192:           REFRESH_ID=$(aws autoscaling start-instance-refresh \
193:             --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
194:             --preferences '{"MinHealthyPercentage":100,"MaxHealthyPercentage":200,"InstanceWarmup":300,"AutoRollback":false}' \
195:             --query 'InstanceRefreshId' --output text)
196:           echo "id=$REFRESH_ID" >> $GITHUB_OUTPUT
197:       - name: Wait for refresh to complete
198:         if: steps.rearm.outputs.scaled_from_zero != 'true'
199:         run: |
200:           set -e
201:           for i in $(seq 1 90); do
202:             S=$(aws autoscaling describe-instance-refreshes \
203:               --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
204:               --instance-refresh-ids "${{ steps.refresh.outputs.id }}" \
205:               --query 'InstanceRefreshes[0].Status' --output text)
206:             P=$(aws autoscaling describe-instance-refreshes \
207:               --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
208:               --instance-refresh-ids "${{ steps.refresh.outputs.id }}" \
209:               --query 'InstanceRefreshes[0].PercentageComplete' --output text)
210:             echo "refresh status=$S percent=$P"
211:             case "$S" in
212:               Successful) exit 0 ;;
213:               Failed|Cancelled|RollbackFailed|RollbackSuccessful)
214:                 echo "refresh ended with $S"; exit 1 ;;
215:             esac
216:             sleep 20
217:           done
218:           echo "timed out waiting for refresh"
219:           exit 1
220:       # ------------------------------------------------------------------
221:       # Gate the smoke on actual ALB target health, not on instance-refresh
222:       # status. This prevents the 503 race from re-occurring: refresh can
223:       # report Successful before targets stabilise, and (worse) refresh on
224:       # an empty ASG returns Successful instantly.
225:       # 60 * 15s = 900s ceiling: covers cold-boot user-data (4-7 min) +
226:       # ELB unhealthy threshold (3 * 15s = 45s) + slack.
227:       # ------------------------------------------------------------------
228:       - name: Resolve target group ARN
229:         id: tg
230:         run: |
231:           NAME="${{ steps.asg.outputs.name }}"
232:           TG_ARN=$(aws autoscaling describe-auto-scaling-groups \
233:             --auto-scaling-group-names "$NAME" \
234:             --query 'AutoScalingGroups[0].TargetGroupARNs[0]' --output text)
235:           echo "arn=$TG_ARN" >> "$GITHUB_OUTPUT"
236:       - name: Wait for target group healthy
237:         run: |
238:           set -e
239:           for i in $(seq 1 60); do
240:             HEALTHY=$(aws elbv2 describe-target-health \
241:               --target-group-arn "${{ steps.tg.outputs.arn }}" \
242:               --query "length(TargetHealthDescriptions[?TargetHealth.State=='healthy'])" \
243:               --output text)
244:             TOTAL=$(aws elbv2 describe-target-health \
245:               --target-group-arn "${{ steps.tg.outputs.arn }}" \
246:               --query "length(TargetHealthDescriptions[*])" \
247:               --output text)
248:             echo "TG healthy=$HEALTHY total=$TOTAL"
249:             if [ "$HEALTHY" -ge 1 ]; then exit 0; fi
250:             sleep 15
251:           done
252:           echo "no healthy targets in target group after 900s"
253:           exit 1
254:       - name: Post-deploy smoke
255:         run: |
256:           # 72 * 10s = 720s. TG-health gate above already proves at least
257:           # one target is healthy; this loop additionally confirms the
258:           # public ALB FQDN serves a 200 with status=UP, covering DNS
259:           # propagation and listener-rule configuration.
260:           for i in $(seq 1 72); do
261:             if curl -fsS --max-time 10 "https://java.talorlik.com/actuator/health" | grep -q '"status":"UP"'; then
262:               echo "smoke ok"; exit 0
263:             fi
264:             sleep 10
265:           done
266:           echo "smoke failed"; exit 1
````

## File: infra/envs/prod/alb.tf
````hcl
  1: ###############################################################################
  2: # ALB - public, HTTPS on 443 (with HTTP/80 -> HTTPS redirect), ACM cert from
  3: # DEPLOYMENT account.
  4: #
  5: # Target group is on HTTP 8080 against EC2 instances. Access logs land in S3.
  6: ###############################################################################
  7: 
  8: # ----------------------------------------------------------------------------
  9: # ALB access log bucket
 10: # ----------------------------------------------------------------------------
 11: 
 12: # AWS-owned ELB account ID per region (us-east-1 specifically).
 13: # Reference: AWS docs - ELB access logs require account-scoped delivery perms.
 14: locals {
 15:   elb_log_account_id_by_region = {
 16:     "us-east-1"      = "127311923021"
 17:     "us-east-2"      = "033677994240"
 18:     "us-west-1"      = "027434742980"
 19:     "us-west-2"      = "797873946194"
 20:     "eu-west-1"      = "156460612806"
 21:     "eu-central-1"   = "054676820928"
 22:     "ap-southeast-1" = "114774131450"
 23:     "ap-southeast-2" = "783225319266"
 24:     "ap-northeast-1" = "582318560864"
 25:   }
 26:   elb_log_account_id = lookup(local.elb_log_account_id_by_region, var.aws_region, "127311923021")
 27: }
 28: 
 29: resource "aws_s3_bucket" "alb_logs" {
 30:   # checkov:skip=CKV_AWS_144:single-region reference impl; CRR out of scope
 31:   # checkov:skip=CKV2_AWS_62:no consumer for S3 event notifications
 32:   bucket        = "${local.name_prefix}-alb-logs-${var.deployment_account_id}"
 33:   force_destroy = var.alb_logs_force_destroy
 34:   tags          = local.common_tags
 35: }
 36: 
 37: # Server-access logging for the ALB-logs bucket itself. Target is the
 38: # bootstrap access_logs bucket (deterministic name; managed by the bootstrap
 39: # state, not this stack). Without this, CKV_AWS_18 fails on the bucket.
 40: resource "aws_s3_bucket_logging" "alb_logs" {
 41:   bucket        = aws_s3_bucket.alb_logs.id
 42:   target_bucket = "java-app-tfstate-${var.deployment_account_id}-${var.aws_region}-access-logs"
 43:   target_prefix = "alb-logs-access/"
 44: }
 45: 
 46: resource "aws_s3_bucket_versioning" "alb_logs" {
 47:   bucket = aws_s3_bucket.alb_logs.id
 48:   versioning_configuration {
 49:     status = "Enabled"
 50:   }
 51: }
 52: 
 53: resource "aws_s3_bucket_public_access_block" "alb_logs" {
 54:   bucket                  = aws_s3_bucket.alb_logs.id
 55:   block_public_acls       = true
 56:   block_public_policy     = true
 57:   ignore_public_acls      = true
 58:   restrict_public_buckets = true
 59: }
 60: 
 61: resource "aws_s3_bucket_ownership_controls" "alb_logs" {
 62:   bucket = aws_s3_bucket.alb_logs.id
 63:   rule {
 64:     object_ownership = "BucketOwnerEnforced"
 65:   }
 66: }
 67: 
 68: resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
 69:   # checkov:skip=CKV_AWS_145:ALB log delivery does not support SSE-KMS CMK on the legacy account-id grant path; AES256 is the supported choice for ALB log targets in regions like us-east-1.
 70:   bucket = aws_s3_bucket.alb_logs.id
 71:   rule {
 72:     # ALB log delivery requires SSE-S3 (AES256), not SSE-KMS, for older
 73:     # account-id-based grant; keep AES256 for compatibility.
 74:     apply_server_side_encryption_by_default {
 75:       sse_algorithm = "AES256"
 76:     }
 77:   }
 78: }
 79: 
 80: resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
 81:   bucket = aws_s3_bucket.alb_logs.id
 82:   rule {
 83:     id     = "expire"
 84:     status = "Enabled"
 85: 
 86:     # Empty filter = applies to all objects (required by aws provider 5.x).
 87:     filter {}
 88: 
 89:     expiration {
 90:       days = 90
 91:     }
 92: 
 93:     abort_incomplete_multipart_upload {
 94:       days_after_initiation = 7
 95:     }
 96:   }
 97: }
 98: 
 99: data "aws_iam_policy_document" "alb_logs" {
100:   # Legacy regions (incl. us-east-1): writes come from the per-region ELB
101:   # AWS-owned account. Source: AWS docs - "Enable access logs for your
102:   # Application Load Balancer".
103:   statement {
104:     sid       = "AllowELBAccountPutObject"
105:     effect    = "Allow"
106:     actions   = ["s3:PutObject"]
107:     resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${var.deployment_account_id}/*"]
108:     principals {
109:       type        = "AWS"
110:       identifiers = ["arn:${data.aws_partition.current.partition}:iam::${local.elb_log_account_id}:root"]
111:     }
112:   }
113: 
114:   # Newer regions / future-proofing: writes come from the ELB log-delivery
115:   # service principal. Harmless in legacy regions.
116:   statement {
117:     sid       = "AllowELBLogDeliveryServicePut"
118:     effect    = "Allow"
119:     actions   = ["s3:PutObject"]
120:     resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${var.deployment_account_id}/*"]
121:     principals {
122:       type        = "Service"
123:       identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
124:     }
125:   }
126: 
127:   statement {
128:     sid       = "AllowELBLogDeliveryServiceGetAcl"
129:     effect    = "Allow"
130:     actions   = ["s3:GetBucketAcl"]
131:     resources = [aws_s3_bucket.alb_logs.arn]
132:     principals {
133:       type        = "Service"
134:       identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
135:     }
136:   }
137: 
138:   statement {
139:     sid       = "DenyInsecureTransport"
140:     effect    = "Deny"
141:     actions   = ["s3:*"]
142:     resources = [aws_s3_bucket.alb_logs.arn, "${aws_s3_bucket.alb_logs.arn}/*"]
143:     principals {
144:       type        = "*"
145:       identifiers = ["*"]
146:     }
147:     condition {
148:       test     = "Bool"
149:       variable = "aws:SecureTransport"
150:       values   = ["false"]
151:     }
152:   }
153: }
154: 
155: resource "aws_s3_bucket_policy" "alb_logs" {
156:   bucket = aws_s3_bucket.alb_logs.id
157:   policy = data.aws_iam_policy_document.alb_logs.json
158: }
159: 
160: # ----------------------------------------------------------------------------
161: # ALB
162: # ----------------------------------------------------------------------------
163: module "alb" {
164:   # checkov:skip=CKV_TF_1:source pinned via registry tag (~> 9.10). Commit-hash pinning rejected for upstream-maintained modules; CKV_TF_2 (tag pin) covers the supply-chain intent.
165:   source  = "terraform-aws-modules/alb/aws"
166:   version = "~> 9.10"
167: 
168:   name               = "${local.name_prefix}-alb"
169:   load_balancer_type = "application"
170: 
171:   vpc_id          = module.vpc.vpc_id
172:   subnets         = module.vpc.public_subnets
173:   security_groups = [aws_security_group.alb.id]
174: 
175:   # Variable-controlled so dev cycles don't need an out-of-band CLI flip
176:   # before destroy. See var.alb_deletion_protection for live-mode guidance.
177:   enable_deletion_protection = var.alb_deletion_protection
178:   drop_invalid_header_fields = true
179:   idle_timeout               = 60
180: 
181:   access_logs = {
182:     bucket  = aws_s3_bucket.alb_logs.id
183:     enabled = true
184:     # No prefix - keeps bucket-policy resource path simple as
185:     # bucket-arn/AWSLogs/<account>/*. If you reintroduce a prefix here,
186:     # you must add the same prefix to the s3:PutObject Resource list in
187:     # data "aws_iam_policy_document" "alb_logs".
188:   }
189: 
190:   listeners = {
191:     # Public HTTPS - terminates TLS using the wildcard ACM cert and forwards
192:     # to the app target group on HTTP/8080.
193:     https = {
194:       port            = local.alb_https_port
195:       protocol        = "HTTPS"
196:       ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
197:       certificate_arn = var.acm_certificate_arn
198: 
199:       forward = {
200:         target_group_key = "app"
201:       }
202:     }
203: 
204:     # Public HTTP - 301 redirect to HTTPS so users typing
205:     # http://java.talorlik.com land on the secure URL automatically.
206:     http_redirect = {
207:       port     = local.alb_http_port
208:       protocol = "HTTP"
209: 
210:       redirect = {
211:         port        = tostring(local.alb_https_port)
212:         protocol    = "HTTPS"
213:         status_code = "HTTP_301"
214:       }
215:     }
216:   }
217: 
218:   target_groups = {
219:     app = {
220:       name                 = "${local.name_prefix}-tg"
221:       protocol             = "HTTP"
222:       port                 = local.app_port
223:       target_type          = "instance"
224:       deregistration_delay = 30
225:       protocol_version     = "HTTP1"
226: 
227:       # Don't auto-register - the ASG handles target registration.
228:       create_attachment = false
229: 
230:       health_check = {
231:         enabled             = true
232:         path                = "/actuator/health"
233:         protocol            = "HTTP"
234:         port                = "traffic-port"
235:         matcher             = "200"
236:         healthy_threshold   = 2
237:         unhealthy_threshold = 3
238:         interval            = 15
239:         timeout             = 5
240:       }
241: 
242:       stickiness = {
243:         enabled = false
244:         type    = "lb_cookie"
245:       }
246:     }
247:   }
248: 
249:   tags = local.common_tags
250: }
````

## File: infra/envs/prod/rds.tf
````hcl
  1: ###############################################################################
  2: # RDS MySQL 8.4 LTS (private, Multi-AZ, encrypted)
  3: #
  4: # - Master password managed by RDS in Secrets Manager (rotated by AWS).
  5: # - App user (`appuser`) is bootstrapped by aws_lambda_function.db_bootstrap
  6: #   (see db_bootstrap.tf). The Lambda is invoked by terraform_data.db_bootstrap
  7: #   on RDS replacement or app-user secret rotation, so the user survives
  8: #   `terraform destroy` + `terraform apply` cycles. Flyway then runs as
  9: #   appuser on backend startup to apply the schema migrations under
 10: #   app/backend/src/main/resources/db/migration/.
 11: # - Backups, deletion protection, performance insights, and slow-query logs
 12: #   are enabled per TR-DB-001..008.
 13: ###############################################################################
 14: 
 15: resource "aws_db_parameter_group" "mysql" {
 16:   name        = "${local.name_prefix}-mysql84"
 17:   family      = "mysql8.4"
 18:   description = "Custom MySQL 8.4 parameter group"
 19: 
 20:   # UTF-8 across the board
 21:   parameter {
 22:     name  = "character_set_server"
 23:     value = "utf8mb4"
 24:   }
 25:   parameter {
 26:     name  = "collation_server"
 27:     value = "utf8mb4_0900_ai_ci"
 28:   }
 29: 
 30:   # Slow query logging
 31:   parameter {
 32:     name         = "slow_query_log"
 33:     value        = "1"
 34:     apply_method = "immediate"
 35:   }
 36:   parameter {
 37:     name         = "long_query_time"
 38:     value        = "1"
 39:     apply_method = "immediate"
 40:   }
 41:   parameter {
 42:     name         = "log_output"
 43:     value        = "FILE"
 44:     apply_method = "immediate"
 45:   }
 46: 
 47:   # Connection sizing - tune as load grows
 48:   parameter {
 49:     name         = "max_connections"
 50:     value        = "200"
 51:     apply_method = "pending-reboot"
 52:   }
 53: 
 54:   tags = local.common_tags
 55: }
 56: 
 57: module "rds" {
 58:   # checkov:skip=CKV_TF_1:source pinned via registry tag (~> 6.10). Commit-hash pinning rejected for upstream-maintained modules; CKV_TF_2 (tag pin) covers the supply-chain intent.
 59:   source  = "terraform-aws-modules/rds/aws"
 60:   version = "~> 6.10"
 61: 
 62:   identifier = "${local.name_prefix}-mysql"
 63: 
 64:   engine               = "mysql"
 65:   engine_version       = var.rds_engine_version
 66:   family               = "mysql8.4"
 67:   major_engine_version = "8.4"
 68:   instance_class       = var.rds_instance_class
 69: 
 70:   # Required when bumping the major engine version on an existing instance.
 71:   # Flip back to false in a follow-up change once the 8.0 -> 8.4 upgrade
 72:   # has landed in prod. Tracked in ADR 0008.
 73:   allow_major_version_upgrade = false
 74: 
 75:   # Apply the version bump and parameter-group swap on the next maintenance
 76:   # event AWS schedules immediately, rather than waiting for the configured
 77:   # maintenance window. Take a manual snapshot before running terraform apply.
 78:   apply_immediately = true
 79: 
 80:   allocated_storage     = var.rds_allocated_storage_gb
 81:   max_allocated_storage = var.rds_max_allocated_storage_gb
 82:   storage_type          = "gp3"
 83:   storage_encrypted     = true
 84:   kms_key_id            = aws_kms_key.app_secrets.arn
 85: 
 86:   db_name  = var.db_name
 87:   username = "dbadmin" # master user; password is RDS-managed below
 88:   port     = local.db_port
 89: 
 90:   # RDS-managed master password in Secrets Manager (rotated by AWS).
 91:   manage_master_user_password             = true
 92:   master_user_secret_kms_key_id           = aws_kms_key.app_secrets.arn
 93:   master_user_password_rotate_immediately = false
 94: 
 95:   multi_az               = true
 96:   publicly_accessible    = false
 97:   vpc_security_group_ids = [aws_security_group.rds.id]
 98:   db_subnet_group_name   = module.vpc.database_subnet_group_name
 99: 
100:   backup_retention_period          = 14
101:   backup_window                    = "03:00-04:00"
102:   maintenance_window               = "Sun:04:30-Sun:05:30"
103:   deletion_protection              = var.rds_deletion_protection
104:   delete_automated_backups         = var.rds_delete_automated_backups
105:   skip_final_snapshot              = var.rds_skip_final_snapshot
106:   final_snapshot_identifier_prefix = "${local.name_prefix}-mysql84-final"
107: 
108:   # Use the AWS-managed default option group. Custom option groups are the
109:   # only kind that can wedge a destroy via retained snapshots/backups; we
110:   # have no MySQL options to set (everything tunable for our workload lives
111:   # in aws_db_parameter_group.mysql), so the engine default OG is sufficient
112:   # and cannot be lockup-blocked.
113:   #
114:   # Do NOT hard-pin option_group_name to "default:mysql-<major>-<minor>".
115:   # AWS lazily creates the per-engine default option group on first instance
116:   # provisioning in an account/region (verified 2026-05-08:
117:   # `aws rds describe-option-groups --major-engine-version 8.4` returns
118:   # empty in us-east-1 sandbox until the first 8.4 instance is created).
119:   # Leaving the argument unset lets the RDS API attach the engine default
120:   # automatically; the AWS provider treats option_group_name as Computed
121:   # when omitted, so no drift on subsequent plans.
122:   create_db_option_group = false
123: 
124:   performance_insights_enabled          = true
125:   performance_insights_retention_period = 7
126: 
127:   monitoring_interval    = 60
128:   create_monitoring_role = true
129:   monitoring_role_name   = "${local.name_prefix}-rds-monitoring"
130: 
131:   # Use the parameter group we manage outside the module (above).
132:   parameter_group_name            = aws_db_parameter_group.mysql.name
133:   create_db_parameter_group       = false
134:   enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
135: 
136:   tags = local.common_tags
137: }
138: 
139: # Expose the DB endpoint to user-data via SSM. SecureString + CMK so the
140: # parameter satisfies CKV2_AWS_34 even though the values themselves are not
141: # secret (endpoint hostname, db name).
142: resource "aws_ssm_parameter" "db_endpoint" {
143:   name   = local.ssm_keys.db_endpoint
144:   type   = "SecureString"
145:   key_id = aws_kms_key.app_secrets.key_id
146:   value  = module.rds.db_instance_address
147: }
148: 
149: resource "aws_ssm_parameter" "db_name" {
150:   name   = local.ssm_keys.db_name
151:   type   = "SecureString"
152:   key_id = aws_kms_key.app_secrets.key_id
153:   value  = var.db_name
154: }
````

## File: .github/workflows/infra-destroy.yml
````yaml
  1: ###############################################################################
  2: # infra-destroy
  3: #
  4: # Tears down the entire prod env created by `infra/envs/prod`. Bootstrap
  5: # state (S3 state bucket + KMS) is INTENTIONALLY left alone - destroying
  6: # remote state bricks future restores and is almost never what you want.
  7: #
  8: # Sequence:
  9: #   1. Confirm the user typed the destroy phrase exactly.
 10: #   2. Optional pre-step: run app-layer cleanup (scale ASG to 0, purge ECR,
 11: #      clear SSM release pointers, remove compose object) so the infra-side
 12: #      destroy doesn't trip on protected resources. Idempotent.
 13: #   3. Empty the ALB-logs bucket and the config bucket. Bucket policies
 14: #      block plaintext puts, so a normal `aws s3 rm` won't always recurse;
 15: #      we use s3api with versioning support.
 16: #   4. Disable ALB deletion protection (TF can't destroy a protected ALB
 17: #      and the resource attribute is set to `true` in module/alb.tf).
 18: #   5. terraform init + destroy against `infra/envs/prod`.
 19: #   6. Optional: delete manual RDS snapshots whose identifier starts with
 20: #      the instance prefix (independent of the deleted DB instance; persist
 21: #      forever otherwise). Gated on the `delete_manual_snapshots` input.
 22: #   7. Force-purge Secrets Manager secrets stuck in PendingDeletion.
 23: #   8. Prune stale Terraform state lockfiles in the state bucket.
 24: #
 25: # Run sparingly. The whole point of the bootstrap stack staying intact is
 26: # that the next `infra-apply` rebuilds the env without you re-creating the
 27: # state bucket.
 28: ###############################################################################
 29: name: infra-destroy
 30: on:
 31:   workflow_dispatch:
 32:     inputs:
 33:       confirm:
 34:         description: 'Type DESTROY (uppercase) to confirm'
 35:         required: true
 36:         default: ''
 37:       run_app_cleanup:
 38:         description: 'First run app-layer cleanup (recommended)'
 39:         type: boolean
 40:         required: false
 41:         default: true
 42:       delete_manual_snapshots:
 43:         description: 'Also delete all manual RDS snapshots for the instance (NO recovery after this)'
 44:         type: boolean
 45:         required: false
 46:         default: true
 47: permissions:
 48:   id-token: write
 49:   contents: read
 50: concurrency:
 51:   group: infra-destroy
 52:   cancel-in-progress: false
 53: jobs:
 54:   destroy:
 55:     name: tear down infra
 56:     runs-on: ubuntu-latest
 57:     environment: prod
 58:     env:
 59:       AWS_PAGER: ""
 60:     steps:
 61:       - name: Validate confirmation phrase
 62:         run: |
 63:           if [ "${{ github.event.inputs.confirm }}" != "DESTROY" ]; then
 64:             echo "::error::confirm input must be exactly 'DESTROY'."
 65:             exit 1
 66:           fi
 67:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
 68:       # Ensures `aws` is on PATH. GitHub-hosted ubuntu-latest already ships
 69:       # AWS CLI v2; nektos/act's default medium image does not. Idempotent.
 70:       - name: Ensure AWS CLI present
 71:         shell: bash
 72:         run: |
 73:           set -euo pipefail
 74:           if command -v aws >/dev/null 2>&1; then
 75:             aws --version
 76:             exit 0
 77:           fi
 78:           tmp=$(mktemp -d)
 79:           curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp/awscliv2.zip"
 80:           unzip -q "$tmp/awscliv2.zip" -d "$tmp"
 81:           sudo "$tmp/aws/install" --update
 82:           aws --version
 83:       # Real GitHub runners only: assume DEPLOYMENT_ROLE_ARN via OIDC.
 84:       # Skipped under `act` (env.ACT==true), where static AWS credentials are
 85:       # already provided to the container via --env-file (.github/env.local).
 86:       # Skipping prevents this action from clobbering the env-loaded creds and
 87:       # from failing when no real OIDC token issuer is present.
 88:       - uses: aws-actions/configure-aws-credentials@61815dcd50bd041e203e49132bacad1fd04d2708 # v5.1.1
 89:         if: ${{ env.ACT != 'true' }}
 90:         with:
 91:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
 92:           aws-region: ${{ vars.AWS_REGION }}
 93:           role-session-name: gha-infra-destroy
 94:       - uses: hashicorp/setup-terraform@b9cd54a3c349d3f38e8881555d616ced269862dd # v3.1.2
 95:         with:
 96:           terraform_version: 1.9.8
 97:       # -------------------------------------------------------------------
 98:       # 2. App-layer cleanup (best-effort, idempotent).
 99:       # -------------------------------------------------------------------
100:       - name: Resolve ASG name
101:         if: ${{ github.event.inputs.run_app_cleanup == 'true' }}
102:         id: asg
103:         run: |
104:           NAME=$(aws autoscaling describe-auto-scaling-groups \
105:             --query "AutoScalingGroups[?Tags[?Key=='Project' && Value=='java-app'] && Tags[?Key=='Environment' && Value=='prod']].AutoScalingGroupName | [0]" \
106:             --output text)
107:           if [ "$NAME" = "None" ] || [ -z "$NAME" ]; then NAME="java-app-prod-asg"; fi
108:           echo "name=$NAME" >> "$GITHUB_OUTPUT"
109:       - name: Scale ASG to 0
110:         if: ${{ github.event.inputs.run_app_cleanup == 'true' }}
111:         run: |
112:           aws autoscaling update-auto-scaling-group \
113:             --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
114:             --min-size 0 --desired-capacity 0 --max-size 0 || true
115:           for i in $(seq 1 60); do
116:             COUNT=$(aws autoscaling describe-auto-scaling-groups \
117:               --auto-scaling-group-names "${{ steps.asg.outputs.name }}" \
118:               --query "AutoScalingGroups[0].Instances | length(@)" \
119:               --output text 2>/dev/null || echo "0")
120:             echo "in-service instances: $COUNT"
121:             if [ "$COUNT" = "0" ]; then break; fi
122:             sleep 15
123:           done
124:       - name: Purge ECR images
125:         if: ${{ github.event.inputs.run_app_cleanup == 'true' }}
126:         run: |
127:           for repo in java-app/backend java-app/frontend; do
128:             IDS=$(aws ecr list-images --repository-name "$repo" --query 'imageIds[*]' --output json 2>/dev/null || echo "[]")
129:             COUNT=$(echo "$IDS" | jq 'length')
130:             if [ "$COUNT" -gt 0 ]; then
131:               echo "$IDS" | jq -c '. as $a | range(0; ($a | length); 100) | $a[.:.+100]' | \
132:                 while read -r CHUNK; do
133:                   aws ecr batch-delete-image --repository-name "$repo" --image-ids "$CHUNK" || true
134:                 done
135:             fi
136:           done
137:       # -------------------------------------------------------------------
138:       # 3. Stop ALB from writing new logs, then disable deletion protection,
139:       #    then empty buckets that TF refuses to remove (versioned).
140:       # -------------------------------------------------------------------
141:       - name: Disable ALB access logs and deletion protection
142:         run: |
143:           set -euo pipefail
144:           ARN=$(aws elbv2 describe-load-balancers \
145:             --query "LoadBalancers[?starts_with(LoadBalancerName, 'java-app-prod-alb')].LoadBalancerArn | [0]" \
146:             --output text)
147:           if [ -n "$ARN" ] && [ "$ARN" != "None" ]; then
148:             aws elbv2 modify-load-balancer-attributes \
149:               --load-balancer-arn "$ARN" \
150:               --attributes Key=access_logs.s3.enabled,Value=false \
151:                            Key=deletion_protection.enabled,Value=false
152:           else
153:             echo "no ALB found - it may already be gone"
154:           fi
155:       - name: Empty ALB log bucket
156:         run: |
157:           set -euo pipefail
158:           B="java-app-prod-alb-logs-${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
159:           if ! aws s3api head-bucket --bucket "$B" 2>/dev/null; then
160:             echo "bucket $B not present, skipping"
161:             exit 0
162:           fi
163:           # Paginate, build full delete payload in one jq call, stop when empty.
164:           while :; do
165:             PAYLOAD=$(aws s3api list-object-versions \
166:                         --bucket "$B" --max-items 900 --output json 2>/dev/null \
167:                       | jq -c '{Objects: [((.Versions // [])[]),
168:                                           ((.DeleteMarkers // [])[])
169:                                           | {Key, VersionId}],
170:                                Quiet: true}')
171:             COUNT=$(printf '%s' "$PAYLOAD" | jq '.Objects | length')
172:             [ "$COUNT" -eq 0 ] && break
173:             aws s3api delete-objects --bucket "$B" --delete "$PAYLOAD"
174:           done
175:       - name: Empty config (compose) bucket
176:         run: |
177:           set -euo pipefail
178:           B="java-app-prod-config-${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
179:           if ! aws s3api head-bucket --bucket "$B" 2>/dev/null; then
180:             echo "bucket $B not present, skipping"
181:             exit 0
182:           fi
183:           while :; do
184:             PAYLOAD=$(aws s3api list-object-versions \
185:                         --bucket "$B" --max-items 900 --output json 2>/dev/null \
186:                       | jq -c '{Objects: [((.Versions // [])[]),
187:                                           ((.DeleteMarkers // [])[])
188:                                           | {Key, VersionId}],
189:                                Quiet: true}')
190:             COUNT=$(printf '%s' "$PAYLOAD" | jq '.Objects | length')
191:             [ "$COUNT" -eq 0 ] && break
192:             aws s3api delete-objects --bucket "$B" --delete "$PAYLOAD"
193:           done
194:       # -------------------------------------------------------------------
195:       # 5. Terraform init, then RDS prep, then destroy.
196:       # -------------------------------------------------------------------
197:       # Pre-create AWS Service-Linked Roles. They are no longer managed by
198:       # Terraform, but covering the case where someone deleted them
199:       # out-of-band keeps `terraform plan -destroy` from failing on missing
200:       # IAM principals referenced by leftover ASG/ALB resources.
201:       - name: Ensure AWS service-linked roles exist
202:         run: |
203:           set -euo pipefail
204:           for SVC in autoscaling.amazonaws.com elasticloadbalancing.amazonaws.com; do
205:             if out=$(aws iam create-service-linked-role --aws-service-name "$SVC" 2>&1); then
206:               echo "Created SLR for $SVC"
207:             else
208:               if echo "$out" | grep -qiE 'has been taken in this account|already exists'; then
209:                 echo "SLR for $SVC already exists; skipping."
210:               else
211:                 echo "$out" >&2
212:                 exit 1
213:               fi
214:             fi
215:           done
216:       - name: terraform init
217:         working-directory: infra/envs/prod
218:         run: |
219:           terraform init \
220:             -backend-config="bucket=java-app-tfstate-${{ vars.DEPLOYMENT_ACCOUNT_ID }}-${{ vars.AWS_REGION }}" \
221:             -backend-config="region=${{ vars.AWS_REGION }}"
222:       # Disable RDS deletion protection imperatively, let any in-flight
223:       # modify settle, and purge orphan retained automated backups left
224:       # from prior failed destroys (those pin the parameter group's KMS
225:       # key and bloat backup quota).
226:       - name: Prepare RDS for destroy
227:         run: |
228:           set -euo pipefail
229:           DBI="java-app-prod-mysql"
230:           if aws rds describe-db-instances --db-instance-identifier "$DBI" >/dev/null 2>&1; then
231:             aws rds modify-db-instance \
232:               --db-instance-identifier "$DBI" \
233:               --no-deletion-protection \
234:               --apply-immediately >/dev/null
235:             # Wait up to ~30 min for available; ignore terminal failures.
236:             aws rds wait db-instance-available \
237:               --db-instance-identifier "$DBI" || true
238:           else
239:             echo "RDS instance $DBI not present"
240:           fi
241:           # Purge any retained automated backups for this DBI. delete_automated_backups
242:           # only fires inside DeleteDBInstance; orphans from earlier runs need this.
243:           aws rds describe-db-instance-automated-backups \
244:             --query "DBInstanceAutomatedBackups[?DBInstanceIdentifier=='$DBI'].DBInstanceAutomatedBackupsArn" \
245:             --output text | tr '\t' '\n' | while read -r ARN; do
246:               [ -z "$ARN" ] && continue
247:               echo "deleting orphan automated backup $ARN"
248:               aws rds delete-db-instance-automated-backup \
249:                 --db-instance-automated-backups-arn "$ARN" || true
250:             done
251:       - name: terraform destroy
252:         working-directory: infra/envs/prod
253:         env:
254:           TF_VAR_aws_region: ${{ vars.AWS_REGION }}
255:           TF_VAR_deployment_account_id: ${{ vars.DEPLOYMENT_ACCOUNT_ID }}
256:           TF_VAR_domain_account_id: ${{ vars.DOMAIN_ACCOUNT_ID }}
257:           TF_VAR_domain_account_route53_role_arn: ${{ secrets.DOMAIN_ROUTE53_ROLE_ARN }}
258:           TF_VAR_hosted_zone_id: ${{ vars.HOSTED_ZONE_ID }}
259:           TF_VAR_acm_certificate_arn: ${{ secrets.ACM_CERTIFICATE_ARN }}
260:           TF_VAR_rds_deletion_protection: "false"
261:           TF_VAR_rds_skip_final_snapshot: "true"
262:           TF_VAR_rds_delete_automated_backups: "true"
263:           TF_VAR_alb_logs_force_destroy: "true"
264:         run: |
265:           terraform destroy -input=false -auto-approve
266:       # -------------------------------------------------------------------
267:       # 6. Delete manual RDS snapshots (opt-in via input).
268:       #    Manual snapshots are independent of the now-deleted DB instance
269:       #    and persist until explicitly removed. Filtering by identifier
270:       #    prefix scopes the sweep to this stack's snapshots only. The
271:       #    earlier "Prepare RDS for destroy" step handles automated-backup
272:       #    orphans; this is the manual-snapshot equivalent.
273:       # -------------------------------------------------------------------
274:       - name: Delete manual RDS snapshots
275:         if: ${{ github.event.inputs.delete_manual_snapshots == 'true' }}
276:         run: |
277:           set -euo pipefail
278:           PREFIX="java-app-prod-mysql"
279:           SNAPS=$(aws rds describe-db-snapshots \
280:                     --snapshot-type manual \
281:                     --query "DBSnapshots[?starts_with(DBSnapshotIdentifier,'$PREFIX')].DBSnapshotIdentifier" \
282:                     --output text 2>/dev/null || true)
283:           if [ -z "$SNAPS" ]; then
284:             echo "no manual snapshots matching prefix $PREFIX"
285:             exit 0
286:           fi
287:           for SNAP in $SNAPS; do
288:             echo "deleting manual snapshot $SNAP"
289:             aws rds delete-db-snapshot --db-snapshot-identifier "$SNAP" || true
290:           done
291:       # -------------------------------------------------------------------
292:       # 7. Force-purge Secrets Manager secrets that Terraform left in
293:       #    PendingDeletion state. Without this, the next `infra-apply`
294:       #    fails with InvalidRequestException ("a secret with this name
295:       #    is already scheduled for deletion") for the 7-day recovery
296:       #    window. The script only acts on secrets whose DeletedDate is
297:       #    set, so it is a no-op on a clean account. Runs even if an
298:       #    earlier step failed, so a partial destroy still clears the
299:       #    name reservations it created.
300:       # -------------------------------------------------------------------
301:       - name: Force-purge pending-deletion secrets
302:         if: ${{ always() }}
303:         run: |
304:           chmod +x .github/scripts/purge_pending_secrets.sh
305:           .github/scripts/purge_pending_secrets.sh
306:       # -------------------------------------------------------------------
307:       # 8. Prune stale Terraform state lockfiles. With native S3 locking
308:       #    (use_lockfile=true), an apply that dies between "lock" and
309:       #    "unlock" leaves a `<key>.tflock` (and sometimes `<key>.tflock.info`)
310:       #    object in the state bucket. Without removal the next apply
311:       #    fails with "Error acquiring the state lock". Idempotent: lists
312:       #    only the lock objects under the prod state prefix and deletes
313:       #    if any exist. Runs even if earlier destroy steps failed so a
314:       #    half-finished destroy does not wedge the next attempt.
315:       # -------------------------------------------------------------------
316:       - name: Prune stale tfstate lockfiles
317:         if: ${{ always() }}
318:         run: |
319:           set -euo pipefail
320:           BUCKET="java-app-tfstate-${{ vars.DEPLOYMENT_ACCOUNT_ID }}-${{ vars.AWS_REGION }}"
321:           PREFIX="java-app/prod/"
322:           # List every object whose key matches the lockfile suffixes.
323:           KEYS=$(aws s3api list-objects-v2 \
324:                    --bucket "$BUCKET" \
325:                    --prefix "$PREFIX" \
326:                    --query 'Contents[?ends_with(Key, `.tflock`) || ends_with(Key, `.tflock.info`)].Key' \
327:                    --output text 2>/dev/null || echo "")
328:           if [ -z "$KEYS" ] || [ "$KEYS" = "None" ]; then
329:             echo "no stale lockfiles under s3://$BUCKET/$PREFIX"
330:             exit 0
331:           fi
332:           echo "$KEYS" | tr '\t' '\n' | while read -r KEY; do
333:             [ -z "$KEY" ] && continue
334:             echo "removing s3://$BUCKET/$KEY"
335:             aws s3api delete-object --bucket "$BUCKET" --key "$KEY" >/dev/null
336:           done
````

## File: .github/workflows/infra-apply.yml
````yaml
  1: name: infra-apply
  2: on:
  3:   workflow_dispatch:
  4:     inputs:
  5:       purge_pending_secrets:
  6:         description: >
  7:           Force-delete any Secrets Manager secrets at the project's well-known
  8:           paths that are currently in PendingDeletion state. Use only when a
  9:           re-apply after `terraform destroy` is blocked by the 7-day recovery
 10:           window. Safe to enable: skips healthy secrets.
 11:         type: boolean
 12:         required: false
 13:         default: false
 14: permissions:
 15:   id-token: write
 16:   contents: read
 17: concurrency:
 18:   group: infra-apply
 19:   cancel-in-progress: false
 20: jobs:
 21:   apply:
 22:     runs-on: ubuntu-latest
 23:     environment: prod
 24:     # AWS CLI v2 pipes JSON through `less` by default. Act's medium image has
 25:     # no `less`, causing aws shell-outs to exit 253. Disable pager job-wide so
 26:     # every step (SLR creation, SSM put-parameter, S3 ops, terraform outputs)
 27:     # gets the same defaulting on real GitHub runners and under act.
 28:     env:
 29:       AWS_PAGER: ""
 30:     steps:
 31:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
 32:       # Ensures `aws` is on PATH. GitHub-hosted ubuntu-latest already ships
 33:       # AWS CLI v2; nektos/act's default medium image does not. Idempotent:
 34:       # if `aws` is already present we just print the version and exit.
 35:       - name: Ensure AWS CLI present
 36:         shell: bash
 37:         run: |
 38:           set -euo pipefail
 39:           if command -v aws >/dev/null 2>&1; then
 40:             aws --version
 41:             exit 0
 42:           fi
 43:           tmp=$(mktemp -d)
 44:           curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp/awscliv2.zip"
 45:           unzip -q "$tmp/awscliv2.zip" -d "$tmp"
 46:           sudo "$tmp/aws/install" --update
 47:           aws --version
 48:       # Real GitHub runners only: assume DEPLOYMENT_ROLE_ARN via OIDC.
 49:       # Skipped under `act` (env.ACT==true), where static AWS credentials are
 50:       # already provided to the container via --env-file (.github/env.local).
 51:       # Skipping prevents this action from clobbering the env-loaded creds and
 52:       # from failing when no real OIDC token issuer is present.
 53:       - uses: aws-actions/configure-aws-credentials@61815dcd50bd041e203e49132bacad1fd04d2708 # v5.1.1
 54:         if: ${{ env.ACT != 'true' }}
 55:         with:
 56:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
 57:           aws-region: ${{ vars.AWS_REGION }}
 58:           role-session-name: gha-infra-apply
 59:       - uses: hashicorp/setup-terraform@b9cd54a3c349d3f38e8881555d616ced269862dd # v3.1.2
 60:         with:
 61:           terraform_version: 1.9.8
 62:       # Opt-in: purge any project secrets stuck in PendingDeletion. Runs only
 63:       # when the workflow is dispatched with `purge_pending_secrets=true`.
 64:       # See .github/scripts/purge_pending_secrets.sh for the rationale.
 65:       - name: Purge pending-deletion secrets (opt-in)
 66:         if: ${{ inputs.purge_pending_secrets == 'true' }}
 67:         run: |
 68:           chmod +x .github/scripts/purge_pending_secrets.sh
 69:           .github/scripts/purge_pending_secrets.sh
 70:       # Pre-create AWS Service-Linked Roles before Terraform runs.
 71:       # SLRs are account-wide singletons that Terraform does not manage; the
 72:       # AWS API returns InvalidInput if they already exist, which `|| true`
 73:       # swallows for idempotency. This eliminates the historical race where
 74:       # ASG capacity validation fired before AWS auto-created the SLR.
 75:       - name: Ensure AWS service-linked roles exist
 76:         run: |
 77:           set -euo pipefail
 78:           for SVC in autoscaling.amazonaws.com elasticloadbalancing.amazonaws.com; do
 79:             if out=$(aws iam create-service-linked-role --aws-service-name "$SVC" 2>&1); then
 80:               echo "Created SLR for $SVC"
 81:             else
 82:               # Tolerate "already exists" only; surface anything else.
 83:               if echo "$out" | grep -qiE 'has been taken in this account|already exists'; then
 84:                 echo "SLR for $SVC already exists; skipping."
 85:               else
 86:                 echo "$out" >&2
 87:                 exit 1
 88:               fi
 89:             fi
 90:           done
 91:       - name: init
 92:         working-directory: infra/envs/prod
 93:         run: |
 94:           terraform init \
 95:             -backend-config="bucket=java-app-tfstate-${{ vars.DEPLOYMENT_ACCOUNT_ID }}-${{ vars.AWS_REGION }}" \
 96:             -backend-config="region=${{ vars.AWS_REGION }}"
 97:       - name: plan
 98:         working-directory: infra/envs/prod
 99:         env:
100:           TF_VAR_aws_region: ${{ vars.AWS_REGION }}
101:           TF_VAR_deployment_account_id: ${{ vars.DEPLOYMENT_ACCOUNT_ID }}
102:           TF_VAR_domain_account_id: ${{ vars.DOMAIN_ACCOUNT_ID }}
103:           TF_VAR_domain_account_route53_role_arn: ${{ secrets.DOMAIN_ROUTE53_ROLE_ARN }}
104:           TF_VAR_hosted_zone_id: ${{ vars.HOSTED_ZONE_ID }}
105:           TF_VAR_acm_certificate_arn: ${{ secrets.ACM_CERTIFICATE_ARN }}
106:         run: terraform plan -input=false -out=tfplan
107:       - name: apply
108:         working-directory: infra/envs/prod
109:         run: terraform apply -input=false -auto-approve tfplan
110:       - name: outputs
111:         working-directory: infra/envs/prod
112:         run: terraform output -no-color
113:       - name: Upload compose file to S3 (compose-object pointer)
114:         env:
115:           AWS_REGION: ${{ vars.AWS_REGION }}
116:         run: |
117:           set -euo pipefail
118:           BUCKET="java-app-prod-config-${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
119:           # us-east-1 must NOT pass --create-bucket-configuration; every
120:           # other region requires LocationConstraint. The conditional avoids
121:           # the cryptic "InvalidLocationConstraint" / "IllegalLocationConstraint"
122:           # error in either direction.
123:           if [ "$AWS_REGION" = "us-east-1" ]; then
124:             CREATE_ARGS=(--bucket "$BUCKET" --region "$AWS_REGION")
125:           else
126:             CREATE_ARGS=(--bucket "$BUCKET" --region "$AWS_REGION" \
127:               --create-bucket-configuration "LocationConstraint=$AWS_REGION")
128:           fi
129:           # Retry loop. Conditions tolerated:
130:           #   BucketAlreadyOwnedByYou - bucket survives across infra cycles, success.
131:           #   OperationAborted        - bucket was just deleted, S3 still settling
132:           #                             (typical 30-60s after a recent infra-destroy).
133:           #   BucketAlreadyExists     - someone else owns the global name; fatal.
134:           # Any other error: fatal.
135:           for attempt in $(seq 1 30); do
136:             if out=$(aws s3api create-bucket "${CREATE_ARGS[@]}" 2>&1); then
137:               echo "compose bucket created."
138:               break
139:             fi
140:             case "$out" in
141:               *BucketAlreadyOwnedByYou*)
142:                 echo "compose bucket already exists in this account; reusing."
143:                 break
144:                 ;;
145:               *OperationAborted*|*"A conflicting conditional operation"*)
146:                 echo "post-delete settling (attempt $attempt/30); sleeping 10s"
147:                 sleep 10
148:                 ;;
149:               *BucketAlreadyExists*)
150:                 echo "ERROR: bucket name $BUCKET is taken globally by another AWS account." >&2
151:                 echo "$out" >&2
152:                 exit 1
153:                 ;;
154:               *)
155:                 echo "ERROR: create-bucket failed:" >&2
156:                 echo "$out" >&2
157:                 exit 1
158:                 ;;
159:             esac
160:           done
161:           aws s3api put-public-access-block --bucket "$BUCKET" \
162:             --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
163:           aws s3 cp app/docker/docker-compose.prod.yml "s3://$BUCKET/docker-compose.prod.yml"
164:           # Compose-object SSM param is created by Terraform as SecureString
165:           # under alias/java-app-prod-secrets. Match the type/key-id explicitly
166:           # so put-parameter --overwrite cannot drift to plain String.
167:           aws ssm put-parameter --name "/java-app/prod/compose-object" \
168:             --type SecureString --key-id "alias/java-app-prod-secrets" --overwrite \
169:             --value "s3://$BUCKET/docker-compose.prod.yml"
````

## File: .github/workflows/ci.yml
````yaml
  1: name: ci
  2: on:
  3:   workflow_dispatch:
  4:   # Allow other workflows (e.g. app-deploy) to use this as a quality gate.
  5:   workflow_call:
  6: permissions:
  7:   contents: read
  8: concurrency:
  9:   group: ci-${{ github.ref }}
 10:   cancel-in-progress: true
 11: jobs:
 12:   docs-drift:
 13:     name: docs drift guard
 14:     runs-on: ubuntu-latest
 15:     steps:
 16:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
 17:       - name: Run docs drift check script
 18:         run: |
 19:           chmod +x .github/scripts/docs_drift_check.sh
 20:           .github/scripts/docs_drift_check.sh
 21:   backend:
 22:     name: backend tests
 23:     runs-on: ubuntu-latest
 24:     steps:
 25:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
 26:       - uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 # v5.2.0
 27:         with:
 28:           distribution: temurin
 29:           java-version: "21"
 30:           cache: maven
 31:       - name: Backend unit + integration tests (Testcontainers MySQL)
 32:         working-directory: app/backend
 33:         env:
 34:           # Explicit DOCKER_HOST removes ambiguity in docker-java's discovery
 35:           # path. github-hosted ubuntu-latest exposes the daemon socket here;
 36:           # act mounts the host's daemon socket here when --container-daemon-
 37:           # socket is the default.
 38:           DOCKER_HOST: unix:///var/run/docker.sock
 39:           # Ryuk is testcontainers' cleanup sidecar. It works fine on full
 40:           # github-hosted VMs but is unreliable when the daemon is reached
 41:           # via a bind-mounted socket from inside an act container (Ryuk
 42:           # tracks the test process's PID against the host PID namespace).
 43:           # Disabling Ryuk in ephemeral CI is safe and standard practice.
 44:           TESTCONTAINERS_RYUK_DISABLED: "true"
 45:         # ./mvnw resolves Maven 3.9.9 from .mvn/wrapper/maven-wrapper.properties.
 46:         # Works on github-hosted runners and on nektos/act images that lack
 47:         # a system mvn. The chmod is defensive: if git failed to preserve the
 48:         # +x bit (Windows clones with core.fileMode=false, archive downloads,
 49:         # certain fs imports), the wrapper still runs. No-op when already +x.
 50:         #
 51:         # Failsafe + Testcontainers ITs run unconditionally. The previously
 52:         # documented act-only short-circuit to Surefire-only existed to dodge
 53:         # the slim catthehacker image's stale docker CLI (API floor 1.32 vs
 54:         # the daemon's 1.40 minimum). `.actrc` now pins
 55:         # catthehacker/ubuntu:full-24.04, which ships a current docker CLI,
 56:         # so the workaround is no longer required.
 57:         #
 58:         # Under act the JVM runs inside the runner container while every
 59:         # Testcontainers-spawned container (MySQL here) is a sibling on the
 60:         # host docker daemon (socket is bind-mounted, not nested). Mapped
 61:         # ports publish to the daemon host's loopback, not to the runner
 62:         # container's loopback, so testcontainers' default
 63:         # `getHost() = localhost` resolution would fail. Setting
 64:         # TESTCONTAINERS_HOST_OVERRIDE to `host.docker.internal` only when
 65:         # ACT is set forces mapped-port resolution at the daemon host. On
 66:         # github-hosted runners ACT is unset, the export is skipped, and
 67:         # testcontainers' default `getHost()` is used. The
 68:         # `host.docker.internal` alias is injected into every container's
 69:         # /etc/hosts natively by Docker Desktop and OrbStack on macOS;
 70:         # plain Linux Docker Engine daemons need a `--add-host` (see the
 71:         # `.actrc` header for the CLI invocation).
 72:         run: |
 73:           chmod +x ./mvnw
 74:           if [ "${ACT:-}" = "true" ]; then
 75:             export TESTCONTAINERS_HOST_OVERRIDE=host.docker.internal
 76:           fi
 77:           ./mvnw -B -ntp verify
 78:       - name: Upload surefire reports
 79:         # Uploads to the GitHub-hosted artifact backend on real CI.
 80:         # Skipped under act: `actions/upload-artifact@v6` negotiates with
 81:         # the GitHub Actions Results Service, which act's emulated
 82:         # `--artifact-server-path` does not yet implement for the v6
 83:         # receiver path; the upload returns 401 unauthorized and fails
 84:         # the job. Locally, surefire/failsafe XML is still on disk under
 85:         # app/backend/target/{surefire,failsafe}-reports/ via the bind
 86:         # mount. `always()` keeps reports captured on real CI even when
 87:         # the test step exits non-zero.
 88:         if: ${{ always() && !env.ACT }}
 89:         uses: actions/upload-artifact@b7c566a772e6b6bfb58ed0dc250532a479d7789f # v6.0.0
 90:         with:
 91:           name: backend-test-reports
 92:           path: |
 93:             app/backend/target/surefire-reports/**
 94:             app/backend/target/failsafe-reports/**
 95:   frontend:
 96:     name: frontend lint/build (no-op for vanilla JS)
 97:     runs-on: ubuntu-latest
 98:     steps:
 99:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
100:       - name: Sanity check static assets
101:         run: |
102:           test -f app/frontend/src/index.html
103:           test -f app/frontend/nginx.conf
104:   compose-smoke:
105:     name: docker compose smoke + playwright
106:     runs-on: ubuntu-latest
107:     needs: [backend, frontend]
108:     steps:
109:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
110:       # Resolves the host that subsequent steps use to reach the compose
111:       # stack and the backend.
112:       #
113:       # `docker compose up` from inside the act runner targets the host's
114:       # docker daemon (socket is bind-mounted). Compose containers publish
115:       # their ports to the daemon host's loopback, which is reachable from
116:       # the runner container as `host.docker.internal` - an alias injected
117:       # natively by Docker Desktop and OrbStack on macOS, and addable via
118:       # `--add-host` on plain Linux daemons (see `.actrc` header). On
119:       # github-hosted runners the runner IS the host, so plain `localhost`
120:       # works; ACT is unset there and the else branch is selected.
121:       #
122:       # Job/workflow-level `env:` blocks cannot reference the `env`
123:       # context (would be self-referential and is rejected by the
124:       # GitHub Actions / act schema validator). Resolving the values in
125:       # a shell step that writes to `$GITHUB_ENV` is the canonical
126:       # workaround and exposes BACKEND_HOST + E2E_BASE_URL to every
127:       # subsequent step in the job without any expression voodoo.
128:       - name: Resolve runtime backend host
129:         run: |
130:           if [ "${ACT:-}" = "true" ]; then
131:             echo "BACKEND_HOST=host.docker.internal"            >> "$GITHUB_ENV"
132:             echo "E2E_BASE_URL=http://host.docker.internal:8080" >> "$GITHUB_ENV"
133:           else
134:             echo "BACKEND_HOST=localhost"                        >> "$GITHUB_ENV"
135:             echo "E2E_BASE_URL=http://localhost:8080"            >> "$GITHUB_ENV"
136:           fi
137:       - name: Build images and start compose stack
138:         working-directory: app/docker
139:         run: |
140:           docker compose -f docker-compose.local.yml build
141:           docker compose -f docker-compose.local.yml up -d
142:           docker compose -f docker-compose.local.yml ps
143:       - name: Wait for backend health
144:         run: |
145:           for i in $(seq 1 60); do
146:             if curl -fsS "http://${BACKEND_HOST}:8080/actuator/health"; then
147:               echo
148:               echo "backend ready"
149:               exit 0
150:             fi
151:             sleep 5
152:           done
153:           echo "backend never became healthy"
154:           docker compose -f app/docker/docker-compose.local.yml logs --no-color || true
155:           exit 1
156:       - name: Setup Node + Playwright
157:         uses: actions/setup-node@48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e # v6.4.0
158:         with:
159:           node-version: "24"
160:       - name: Install + run Playwright
161:         working-directory: tests/e2e
162:         # E2E_BASE_URL is exported via `$GITHUB_ENV` in the
163:         # "Resolve runtime backend host" step; Playwright's config picks
164:         # it up from the process env, so no per-step env block is needed.
165:         run: |
166:           npm install
167:           npx playwright install --with-deps chromium
168:           npm run test:ci
169:       - name: Compose logs (always)
170:         if: always()
171:         working-directory: app/docker
172:         run: docker compose -f docker-compose.local.yml logs --no-color || true
173:       - name: Compose down
174:         if: always()
175:         working-directory: app/docker
176:         run: docker compose -f docker-compose.local.yml down -v
177:       - name: Upload Playwright report
178:         # Uploads to the GitHub-hosted artifact backend on real CI.
179:         # Skipped under act: same v6 receiver incompatibility as the
180:         # backend surefire upload above. Locally, the HTML report is on
181:         # disk at tests/e2e/playwright-report/ via the bind mount.
182:         # `always()` keeps it captured on real CI even when test steps
183:         # exit non-zero.
184:         if: ${{ always() && !env.ACT }}
185:         uses: actions/upload-artifact@b7c566a772e6b6bfb58ed0dc250532a479d7789f # v6.0.0
186:         with:
187:           name: playwright-report
188:           path: tests/e2e/playwright-report
189:   iac-checks:
190:     name: terraform fmt/validate + tflint + checkov
191:     runs-on: ubuntu-latest
192:     steps:
193:       - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
194:       - uses: hashicorp/setup-terraform@b9cd54a3c349d3f38e8881555d616ced269862dd # v3.1.2
195:         with:
196:           terraform_version: 1.9.8
197:       - name: terraform fmt
198:         run: terraform fmt -check -recursive infra
199:       - name: validate bootstrap
200:         working-directory: infra/bootstrap
201:         run: terraform init -backend=false && terraform validate
202:       - name: validate prod
203:         working-directory: infra/envs/prod
204:         run: terraform init -backend=false && terraform validate
205:       - uses: terraform-linters/setup-tflint@b480b8fcdaa6f2c577f8e4fa799e89e756bb7c93 # v6.2.2
206:         with: { tflint_version: latest }
207:       - run: tflint --init && tflint --recursive
208:       - name: checkov
209:         uses: bridgecrewio/checkov-action@9201a8e6eaa919e3444d7c4ca691896efde4f033 # v12
210:         with:
211:           directory: infra
212:           framework: terraform
213:           soft_fail: true
214:           # Pull the vendored aws modules (vpc, alb, rds, autoscaling, ...)
215:           # so checkov can scan their resources too. Without this it logs
216:           # "Failed to download module ..." and silently skips them.
217:           download_external_modules: "true"
````
