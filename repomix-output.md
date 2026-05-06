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
  workflows/
    app-deploy.yml
    app-destroy.yml
    ci.yml
    infra-apply.yml
    infra-destroy.yml
    infra-plan.yml
app/
  backend/
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
                  JwtAuthenticationFilter.java
                  JwtService.java
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
  dark-theme.css
  index.html
  light-theme.css
  main.js
infra/
  bootstrap/
    main.tf
    outputs.tf
    providers.tf
    variables.tf
    versions.tf
  envs/
    prod/
      templates/
        user_data.sh.tpl
      alb.tf
      asg.tf
      backend.tf
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
      variables.tf
      versions.tf
      waf.tf
tests/
  e2e/
    specs/
      smoke.spec.ts
    playwright.config.ts
.editorconfig
.gitattributes
.gitignore
repomix.config.json
```

# Files

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
140: section {
141:   max-width: 1200px;
142:   margin: 0 auto;
143:   padding: 40px 20px 0 20px;
144:   scroll-margin-top: 100px;
145: }
146: section h2 {
147:   font-size: 2em;
148:   margin-bottom: 20px;
149:   padding-bottom: 10px;
150:   border-bottom: 2px solid var(--border-color);
151: }
152: section h3 {
153:   font-size: 1.5em;
154:   margin-bottom: 15px;
155: }
156: .card {
157:   background: var(--section-bg);
158:   border: 1px solid var(--border-color);
159:   border-radius: 6px;
160:   padding: 20px;
161:   margin-bottom: 20px;
162:   box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
163: }
164: .doc-grid {
165:   display: grid;
166:   grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
167:   gap: 20px;
168:   margin-top: 20px;
169: }
170: ul, ol {
171:   list-style-position: inside;
172: }
173: a {
174:   color: var(--link-color);
175:   text-decoration: none;
176: }
177: a:hover {
178:   text-decoration: underline;
179: }
180: p {
181:   margin-bottom: 15px;
182: }
183: code {
184:   background-color: var(--code-bg);
185:   padding: 2px 6px;
186:   border-radius: 3px;
187:   border: 1px solid var(--border-color);
188:   color: #f85149;
189: }
190: pre {
191:   background-color: var(--code-bg);
192:   padding: 16px;
193:   border-radius: 6px;
194:   overflow-x: auto;
195:   border: 1px solid var(--border-color);
196: }
197: pre code {
198:   background: none;
199:   padding: 0;
200:   border: none;
201:   color: var(--text-color);
202: }
203: footer {
204:   background-color: var(--section-bg);
205:   border-top: 1px solid var(--border-color);
206:   padding: 30px 20px;
207:   text-align: center;
208:   color: #8b949e;
209: }
210: .scroll-to-top {
211:   position: fixed;
212:   bottom: 30px;
213:   right: 30px;
214:   width: 50px;
215:   height: 50px;
216:   border-radius: 50%;
217:   background-color: rgba(88, 166, 255, 0.15);
218:   border: 2px solid rgba(88, 166, 255, 0.3);
219:   color: var(--primary-color);
220:   cursor: pointer;
221:   display: flex;
222:   align-items: center;
223:   justify-content: center;
224:   z-index: 999;
225:   opacity: 0;
226:   visibility: hidden;
227:   pointer-events: none;
228:   transition: opacity 0.3s ease, visibility 0.3s ease;
229: }
230: .scroll-to-top.visible {
231:   opacity: 1;
232:   visibility: visible;
233:   pointer-events: auto;
234: }
235: @media (max-width: 768px) {
236:   .mobile-menu-toggle {
237:     display: block;
238:   }
239:   .nav-menu {
240:     position: fixed;
241:     left: -100%;
242:     top: 60px;
243:     flex-direction: column;
244:     background-color: var(--nav-bg);
245:     width: 100%;
246:     text-align: center;
247:     transition: 0.3s;
248:     padding: 20px 0;
249:     border-bottom: 1px solid var(--border-color);
250:   }
251:   .nav-menu.active {
252:     left: 0;
253:   }
254: }
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
  8:   <meta property="og:type" content="website">
  9:   <meta property="og:title" content="Dockerized Java App on EC2 - Documentation">
 10:   <meta property="og:description" content="Production-shaped Dockerized Java deployment reference with Terraform IaC and GitHub Actions CI/CD.">
 11:   <meta property="og:image" content="https://github.com/talorlik/dockerized-java-app-on-ec2/raw/main/docs/header_banner.png">
 12:   <meta name="twitter:card" content="summary_large_image">
 13:   <meta name="twitter:title" content="Dockerized Java App on EC2 - Documentation">
 14:   <meta name="twitter:description" content="Architecture, deployment, operations, and security documentation for the project.">
 15:   <meta name="twitter:image" content="https://github.com/talorlik/dockerized-java-app-on-ec2/raw/main/docs/header_banner.png">
 16:   <link rel="icon" type="image/x-icon" href="favicon.ico">
 17:   <link id="theme-stylesheet" rel="stylesheet" href="light-theme.css">
 18: </head>
 19: <body>
 20:   <a href="#main-content" class="skip-link">Skip to main content</a>
 21:   <nav class="navbar">
 22:     <div class="nav-container">
 23:       <a href="#hero" class="nav-logo">Dockerized Java App Docs</a>
 24:       <button class="mobile-menu-toggle" id="mobileMenuToggle" aria-label="Toggle navigation menu">☰</button>
 25:       <ul class="nav-menu" id="navMenu">
 26:         <li><a href="#overview">Overview</a></li>
 27:         <li><a href="#getting-started">Getting Started</a></li>
 28:         <li><a href="#architecture">Architecture</a></li>
 29:         <li><a href="#documentation">Documentation</a></li>
 30:         <li><a href="#operations">Operations</a></li>
 31:         <li><a href="#security">Security</a></li>
 32:         <li><a href="#repository">Repository</a></li>
 33:         <li>
 34:           <button id="themeToggle" class="theme-toggle" aria-label="Toggle theme" title="Toggle theme">
 35:             <span id="sunIcon" class="icon hidden">☀️</span>
 36:             <span id="moonIcon" class="icon">🌙</span>
 37:           </button>
 38:         </li>
 39:       </ul>
 40:     </div>
 41:   </nav>
 42:   <main id="main-content">
 43:     <section id="hero" class="hero">
 44:       <h1>Dockerized Java App on EC2</h1>
 45:       <p>
 46:         Production-shaped reference implementation for deploying Dockerized Java
 47:         applications on EC2 Auto Scaling behind an ALB, with RDS MySQL,
 48:         Terraform infrastructure, and GitHub Actions delivery workflows. The
 49:         signup app included here is a sample workload.
 50:       </p>
 51:       <img src="header_banner.png" alt="Dockerized Java app architecture banner" class="hero-banner">
 52:     </section>
 53:     <section id="overview">
 54:       <h2>Overview</h2>
 55:       <div class="doc-grid">
 56:         <article class="card">
 57:           <h3>What This Project Includes</h3>
 58:           <ul>
 59:             <li>Spring Boot backend with JWT auth, RBAC, and Flyway migrations</li>
 60:             <li>Nginx frontend container proxying <code>/api/*</code> to backend</li>
 61:             <li>Private RDS MySQL (central shared DB) with stateless EC2 compute</li>
 62:             <li>Terraform-managed AWS foundation across deployment and domain accounts</li>
 63:             <li>GitHub Actions OIDC delivery with ASG Instance Refresh rollout</li>
 64:           </ul>
 65:         </article>
 66:         <article class="card">
 67:           <h3>Target Runtime Topology</h3>
 68:           <p>
 69:             Ingress path: Internet -&gt; Route53 alias -&gt; ALB HTTPS listener -&gt;
 70:             EC2 ASG private subnets -&gt; Docker Compose frontend/backend -&gt; RDS MySQL.
 71:           </p>
 72:           <p>
 73:             Primary endpoint: <code>https://java.talorlik.com</code>.
 74:             Operations and architecture details are aligned with
 75:             <code>PROJECT_OVERVIEW.md</code>, PRD, and Technical Requirements docs.
 76:           </p>
 77:         </article>
 78:       </div>
 79:     </section>
 80:     <section id="getting-started">
 81:       <h2>Getting Started</h2>
 82:       <div class="doc-grid">
 83:         <article class="card">
 84:           <h3>Prerequisites Checklist</h3>
 85:           <ul>
 86:             <li>DEPLOYMENT account for ALB, EC2/ASG, RDS, ECR, IAM, Secrets Manager, and ACM</li>
 87:             <li>DOMAIN account (or same account) hosting Route53 zone for <code>talorlik.com</code></li>
 88:             <li><code>DEPLOYMENT_ROLE_ARN</code> with GitHub OIDC trust configured</li>
 89:             <li><code>DOMAIN_ROUTE53_ROLE_ARN</code> allowing DNS record updates (when cross-account)</li>
 90:             <li>ACM certificate in DEPLOYMENT account for <code>java.talorlik.com</code></li>
 91:             <li>GitHub variables: <code>AWS_REGION</code>, <code>DEPLOYMENT_ACCOUNT_ID</code>, <code>DOMAIN_ACCOUNT_ID</code>, <code>HOSTED_ZONE_ID</code></li>
 92:             <li>GitHub secrets: <code>ACM_CERTIFICATE_ARN</code>, <code>DEPLOYMENT_ROLE_ARN</code>, <code>DOMAIN_ROUTE53_ROLE_ARN</code></li>
 93:             <li>GitHub Environment named <code>prod</code> for apply/destroy workflows</li>
 94:           </ul>
 95:         </article>
 96:         <article class="card">
 97:           <h3>Deploy From Scratch</h3>
 98:           <ol>
 99:             <li>Complete one-time prerequisites from <code>README.md</code>: DEPLOYMENT account, DOMAIN account role chain, ACM cert, GitHub vars/secrets, and <code>prod</code> environment.</li>
100:             <li>Bootstrap remote Terraform state in <code>infra/bootstrap</code> and copy the backend block output into <code>infra/envs/prod/backend.tf</code>.</li>
101:             <li>Optionally run <code>infra-plan.yml</code>, then run <code>infra-apply.yml</code> to provision VPC, ALB, ASG, RDS, ECR, IAM, Route53, and observability resources.</li>
102:             <li>Run <code>app-deploy.yml</code> to execute CI gates, push SHA-tagged images to ECR, update SSM release pointers, and trigger ASG instance refresh.</li>
103:             <li>Retrieve first admin credentials from Secrets Manager and sign in.</li>
104:           </ol>
105:         </article>
106:         <article class="card">
107:           <h3>Deploy Commands</h3>
108:           <pre><code># 1) Bootstrap state (local, one-shot)
109: cd infra/bootstrap
110: export AWS_REGION=us-east-1
111: terraform init
112: terraform apply -var aws_region=us-east-1 -var state_bucket_name="java-app-tfstate-&lt;DEPLOYMENT_ACCOUNT_ID&gt;-us-east-1"
113: terraform output backend_block_example
114: # 2) (Optional) Terraform plan workflow
115: gh workflow run infra-plan.yml
116: gh run watch
117: # 3) Apply infrastructure
118: gh workflow run infra-apply.yml
119: gh run watch
120: # 4) Deploy app images + refresh ASG
121: gh workflow run app-deploy.yml
122: gh run watch</code></pre>
123:         </article>
124:         <article class="card">
125:           <h3>Destroy Stack (Reverse Order)</h3>
126:           <p>
127:             Destroy follows the README sequence. Both workflow-based destroy paths require
128:             the exact confirmation value <code>DESTROY</code>.
129:           </p>
130:           <pre><code># 1) Tear down application layer
131: gh workflow run app-destroy.yml -f confirm=DESTROY
132: gh run watch
133: # 2) Tear down production infrastructure
134: gh workflow run infra-destroy.yml -f confirm=DESTROY -f run_app_cleanup=true
135: gh run watch</code></pre>
136:           <p>
137:             Optional: remove <code>infra/bootstrap</code> resources only when decommissioning
138:             the project completely.
139:           </p>
140:         </article>
141:       </div>
142:     </section>
143:     <section id="architecture">
144:       <h2>Architecture</h2>
145:       <div class="card">
146:         <p>
147:           Route53 aliases <code>java.talorlik.com</code> to an internet-facing ALB.
148:           The ALB forwards to EC2 instances in an Auto Scaling Group, where
149:           frontend and backend containers run via Docker Compose. The backend
150:           connects to private RDS MySQL, and secrets are sourced from AWS
151:           Secrets Manager.
152:         </p>
153:       </div>
154:       <div class="card">
155:         <h3>Key Paths</h3>
156:         <ul>
157:           <li><code>app/backend/</code> - Spring Boot application</li>
158:           <li><code>app/frontend/</code> - static frontend and Nginx config</li>
159:           <li><code>app/docker/</code> - local and prod compose files</li>
160:           <li><code>infra/envs/prod/</code> - production Terraform environment</li>
161:           <li><code>.github/workflows/</code> - CI/CD pipelines</li>
162:         </ul>
163:       </div>
164:     </section>
165:     <section id="documentation">
166:       <h2>Documentation</h2>
167:       <div class="doc-grid">
168:         <article class="card">
169:           <h3>Operator Guides</h3>
170:           <ul>
171:             <li><a href="auxiliary/operations_guide/00-prerequisites.md">00 - Prerequisites</a></li>
172:             <li><a href="auxiliary/operations_guide/01-bootstrap-state.md">01 - Bootstrap State</a></li>
173:             <li><a href="auxiliary/operations_guide/02-domain-account-dns.md">02 - Domain Account DNS</a></li>
174:             <li><a href="auxiliary/operations_guide/03-deployment.md">03 - Deployment</a></li>
175:             <li><a href="auxiliary/operations_guide/04-operations.md">04 - Operations</a></li>
176:             <li><a href="auxiliary/operations_guide/05-security-model.md">05 - Security Model</a></li>
177:           </ul>
178:         </article>
179:         <article class="card">
180:           <h3>Planning Documents</h3>
181:           <ul>
182:             <li><a href="auxiliary/planning/PROJECT_OVERVIEW.md">Project Overview</a></li>
183:             <li><a href="auxiliary/planning/PRODUCT_REQUIREMENTS_DOCUMENT.md">Product Requirements</a></li>
184:             <li><a href="auxiliary/planning/TECHNICAL_REQUIREMENTS_REFERENCE.md">Technical Requirements</a></li>
185:             <li><a href="auxiliary/planning/ENGINEERING_EXECUTION_BACKLOG.md">Engineering Backlog</a></li>
186:             <li><a href="auxiliary/planning/INITIAL_HL_DESCRIPTION.md">Initial High-Level Description</a></li>
187:           </ul>
188:         </article>
189:         <article class="card">
190:           <h3>Architecture Decision Records</h3>
191:           <ul>
192:             <li><a href="auxiliary/adr/0001-frontend-stack.md">ADR 0001 - Frontend Stack</a></li>
193:             <li><a href="auxiliary/adr/0002-auth-model.md">ADR 0002 - Auth Model</a></li>
194:             <li><a href="auxiliary/adr/0003-waf.md">ADR 0003 - WAF</a></li>
195:             <li><a href="auxiliary/adr/0004-ubuntu-resolution.md">ADR 0004 - Ubuntu Resolution</a></li>
196:             <li><a href="auxiliary/adr/0005-secret-rotation.md">ADR 0005 - Secret Rotation</a></li>
197:             <li><a href="auxiliary/adr/0006-provider-account-model.md">ADR 0006 - Provider Account Model</a></li>
198:           </ul>
199:         </article>
200:       </div>
201:     </section>
202:     <section id="operations">
203:       <h2>Operations</h2>
204:       <div class="doc-grid">
205:         <article class="card">
206:           <h3>Release Workflow</h3>
207:           <ul>
208:             <li><code>ci.yml</code> gates backend tests, compose smoke, e2e, and Terraform checks</li>
209:             <li><code>infra-plan.yml</code> produces plan artifacts for infrastructure changes</li>
210:             <li><code>infra-apply.yml</code> applies production infrastructure and config object wiring</li>
211:             <li><code>app-deploy.yml</code> publishes immutable SHA image tags and rolls ASG safely</li>
212:             <li><code>app-destroy.yml</code> and <code>infra-destroy.yml</code> execute controlled teardown</li>
213:           </ul>
214:         </article>
215:         <article class="card">
216:           <h3>Notes</h3>
217:           <p>
218:             Image tags are release-specific. The deployment model updates SSM
219:             image tag parameters and performs launch-before-terminate refreshes.
220:           </p>
221:           <p>
222:             Health checks are performed after deployment to verify application
223:             readiness.
224:           </p>
225:         </article>
226:       </div>
227:     </section>
228:     <section id="security">
229:       <h2>Security</h2>
230:       <div class="card">
231:         <ul>
232:           <li>No public RDS access; DB lives in private subnets only</li>
233:           <li>EC2 access uses SSM Session Manager, not SSH ingress</li>
234:           <li>Secrets are stored in Secrets Manager, never committed in repo</li>
235:           <li>WAF is attached to ALB with managed rule groups and rate limiting</li>
236:           <li>IMDSv2 and least-privilege IAM are part of the baseline model</li>
237:         </ul>
238:       </div>
239:     </section>
240:     <section id="repository">
241:       <h2>Repository</h2>
242:       <div class="card">
243:         <p>
244:           GitHub: <a href="https://github.com/talorlik/dockerized-java-app-on-ec2" target="_blank" rel="noopener noreferrer">talorlik/dockerized-java-app-on-ec2</a>
245:         </p>
246:         <p>
247:           Root README: <a href="https://github.com/talorlik/dockerized-java-app-on-ec2/blob/main/README.md" target="_blank" rel="noopener noreferrer">README.md</a>
248:         </p>
249:       </div>
250:     </section>
251:   </main>
252:   <footer>
253:     <p><strong>Dockerized Java App Documentation</strong></p>
254:     <p>Copyright (c) Tal Orlik</p>
255:   </footer>
256:   <button id="scrollToTopButton" class="scroll-to-top" aria-label="Scroll to top" title="Scroll to top">
257:     <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
258:       <path d="M18 15l-6-6-6 6"></path>
259:     </svg>
260:   </button>
261:   <script src="main.js"></script>
262: </body>
263: </html>
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
139: section {
140:   max-width: 1200px;
141:   margin: 0 auto;
142:   padding: 40px 20px 0 20px;
143:   scroll-margin-top: 100px;
144: }
145: section h2 {
146:   font-size: 2em;
147:   margin-bottom: 20px;
148:   padding-bottom: 10px;
149:   border-bottom: 2px solid var(--border-color);
150: }
151: section h3 {
152:   font-size: 1.5em;
153:   margin-bottom: 15px;
154: }
155: .card {
156:   background: var(--bg-color);
157:   border: 1px solid var(--border-color);
158:   border-radius: 6px;
159:   padding: 20px;
160:   margin-bottom: 20px;
161:   box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
162: }
163: .doc-grid {
164:   display: grid;
165:   grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
166:   gap: 20px;
167:   margin-top: 20px;
168: }
169: ul, ol {
170:   list-style-position: inside;
171: }
172: a {
173:   color: var(--link-color);
174:   text-decoration: none;
175: }
176: a:hover {
177:   text-decoration: underline;
178: }
179: p {
180:   margin-bottom: 15px;
181: }
182: code {
183:   background-color: var(--code-bg);
184:   padding: 2px 6px;
185:   border-radius: 3px;
186:   border: 1px solid var(--border-color);
187:   color: #d73a49;
188: }
189: pre {
190:   background-color: var(--code-bg);
191:   padding: 16px;
192:   border-radius: 6px;
193:   overflow-x: auto;
194:   border: 1px solid var(--border-color);
195: }
196: pre code {
197:   background: none;
198:   padding: 0;
199:   border: none;
200:   color: var(--text-color);
201: }
202: footer {
203:   background-color: var(--section-bg);
204:   border-top: 1px solid var(--border-color);
205:   padding: 30px 20px;
206:   text-align: center;
207:   color: #586069;
208: }
209: .scroll-to-top {
210:   position: fixed;
211:   bottom: 30px;
212:   right: 30px;
213:   width: 50px;
214:   height: 50px;
215:   border-radius: 50%;
216:   background-color: rgba(3, 102, 214, 0.15);
217:   border: 2px solid rgba(3, 102, 214, 0.3);
218:   color: var(--primary-color);
219:   cursor: pointer;
220:   display: flex;
221:   align-items: center;
222:   justify-content: center;
223:   z-index: 999;
224:   opacity: 0;
225:   visibility: hidden;
226:   pointer-events: none;
227:   transition: opacity 0.3s ease, visibility 0.3s ease;
228: }
229: .scroll-to-top.visible {
230:   opacity: 1;
231:   visibility: visible;
232:   pointer-events: auto;
233: }
234: @media (max-width: 768px) {
235:   .mobile-menu-toggle {
236:     display: block;
237:   }
238:   .nav-menu {
239:     position: fixed;
240:     left: -100%;
241:     top: 60px;
242:     flex-direction: column;
243:     background-color: var(--nav-bg);
244:     width: 100%;
245:     text-align: center;
246:     transition: 0.3s;
247:     padding: 20px 0;
248:     border-bottom: 1px solid var(--border-color);
249:   }
250:   .nav-menu.active {
251:     left: 0;
252:   }
253: }
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
 21: ###############################################################################
 22: name: app-destroy
 23: on:
 24:   workflow_dispatch:
 25:     inputs:
 26:       confirm:
 27:         description: 'Type DESTROY (uppercase) to confirm'
 28:         required: true
 29:         default: ''
 30: permissions:
 31:   id-token: write
 32:   contents: read
 33: concurrency:
 34:   group: app-destroy
 35:   cancel-in-progress: false
 36: jobs:
 37:   destroy:
 38:     name: tear down app layer
 39:     runs-on: ubuntu-latest
 40:     environment: prod   # forces the environment-protection rule (manual approval)
 41:     steps:
 42:       - name: Validate confirmation phrase
 43:         run: |
 44:           if [ "${{ github.event.inputs.confirm }}" != "DESTROY" ]; then
 45:             echo "::error::confirm input must be exactly 'DESTROY'."
 46:             exit 1
 47:           fi
 48:       - uses: actions/checkout@v4
 49:       - uses: aws-actions/configure-aws-credentials@v4
 50:         with:
 51:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
 52:           aws-region: ${{ vars.AWS_REGION }}
 53:           role-session-name: gha-app-destroy
 54:       # -------------------------------------------------------------------
 55:       # 1. Resolve ASG name (deterministic in this stack, but follow the
 56:       #    same Tags-based lookup the deploy workflow uses).
 57:       # -------------------------------------------------------------------
 58:       - id: asg
 59:         name: Resolve ASG name
 60:         run: |
 61:           NAME=$(aws autoscaling describe-auto-scaling-groups \
 62:             --query "AutoScalingGroups[?Tags[?Key=='Project' && Value=='java-app'] && Tags[?Key=='Environment' && Value=='prod']].AutoScalingGroupName | [0]" \
 63:             --output text)
 64:           if [ "$NAME" = "None" ] || [ -z "$NAME" ]; then
 65:             NAME="java-app-prod-asg"
 66:           fi
 67:           echo "name=$NAME" >> "$GITHUB_OUTPUT"
 68:       # -------------------------------------------------------------------
 69:       # 2. Scale ASG to 0 and wait for instances to drain.
 70:       # -------------------------------------------------------------------
 71:       - name: Scale ASG to 0
 72:         run: |
 73:           aws autoscaling update-auto-scaling-group \
 74:             --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
 75:             --min-size 0 --desired-capacity 0 --max-size 0
 76:       - name: Wait for ASG to drain
 77:         run: |
 78:           for i in $(seq 1 60); do
 79:             COUNT=$(aws autoscaling describe-auto-scaling-groups \
 80:               --auto-scaling-group-names "${{ steps.asg.outputs.name }}" \
 81:               --query "AutoScalingGroups[0].Instances | length(@)" \
 82:               --output text)
 83:             echo "in-service instances: $COUNT"
 84:             if [ "$COUNT" = "0" ]; then exit 0; fi
 85:             sleep 15
 86:           done
 87:           echo "::error::timed out waiting for ASG to drain"
 88:           exit 1
 89:       # -------------------------------------------------------------------
 90:       # 3. Reset release pointers so a re-scale doesn't pull a deleted tag.
 91:       # -------------------------------------------------------------------
 92:       - name: Reset SSM release pointers to 'bootstrap'
 93:         run: |
 94:           for p in /java-app/prod/backend-image-tag /java-app/prod/frontend-image-tag /java-app/prod/release-id; do
 95:             aws ssm put-parameter --name "$p" --type String --overwrite --value "bootstrap"
 96:           done
 97:       # -------------------------------------------------------------------
 98:       # 4. Delete the published compose-object from S3.
 99:       # -------------------------------------------------------------------
100:       - name: Delete compose object in S3
101:         run: |
102:           BUCKET="java-app-prod-config-${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
103:           aws s3 rm "s3://$BUCKET/docker-compose.prod.yml" || true
104:       # -------------------------------------------------------------------
105:       # 5. Empty both ECR repositories.
106:       # -------------------------------------------------------------------
107:       - name: Purge ECR images
108:         run: |
109:           for repo in java-app/backend java-app/frontend; do
110:             echo "purging $repo"
111:             IDS=$(aws ecr list-images --repository-name "$repo" --query 'imageIds[*]' --output json)
112:             COUNT=$(echo "$IDS" | jq 'length')
113:             if [ "$COUNT" -gt 0 ]; then
114:               # batch-delete-image accepts up to 100 image IDs at a time;
115:               # if there are more, page in chunks.
116:               echo "$IDS" | jq -c '. as $a | range(0; ($a | length); 100) | $a[.:.+100]' | \
117:                 while read -r CHUNK; do
118:                   aws ecr batch-delete-image \
119:                     --repository-name "$repo" \
120:                     --image-ids "$CHUNK"
121:                 done
122:             fi
123:           done
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
12:     public Aws getAws() { return aws; }
13:     public Secrets getSecrets() { return secrets; }
14:     public Jwt getJwt() { return jwt; }
15:     public Verification getVerification() { return verification; }
16:     public RateLimit getRateLimit() { return rateLimit; }
17:     public Cors getCors() { return cors; }
18:     public Ses getSes() { return ses; }
19:     public static class Aws { private String region = "us-east-1";
20:         public String getRegion() { return region; } public void setRegion(String r) { this.region = r; } }
21:     public static class Secrets {
22:         private String jwtSecretName;
23:         private String sesSecretName;
24:         private String adminSecretName;
25:         public String getJwtSecretName() { return jwtSecretName; }
26:         public void setJwtSecretName(String v) { this.jwtSecretName = v; }
27:         public String getSesSecretName() { return sesSecretName; }
28:         public void setSesSecretName(String v) { this.sesSecretName = v; }
29:         public String getAdminSecretName() { return adminSecretName; }
30:         public void setAdminSecretName(String v) { this.adminSecretName = v; }
31:     }
32:     public static class Jwt {
33:         private long expirationMinutes = 60;
34:         public long getExpirationMinutes() { return expirationMinutes; }
35:         public void setExpirationMinutes(long v) { this.expirationMinutes = v; }
36:     }
37:     public static class Verification {
38:         private int codeLength = 6;
39:         private int ttlMinutes = 30;
40:         private int maxAttempts = 5;
41:         public int getCodeLength() { return codeLength; } public void setCodeLength(int v) { codeLength = v; }
42:         public int getTtlMinutes() { return ttlMinutes; } public void setTtlMinutes(int v) { ttlMinutes = v; }
43:         public int getMaxAttempts() { return maxAttempts; } public void setMaxAttempts(int v) { maxAttempts = v; }
44:     }
45:     public static class RateLimit {
46:         private int loginPerMinute = 10;
47:         private int verifyPerMinute = 10;
48:         private int signupPerHour = 20;
49:         public int getLoginPerMinute() { return loginPerMinute; } public void setLoginPerMinute(int v) { loginPerMinute = v; }
50:         public int getVerifyPerMinute() { return verifyPerMinute; } public void setVerifyPerMinute(int v) { verifyPerMinute = v; }
51:         public int getSignupPerHour() { return signupPerHour; } public void setSignupPerHour(int v) { signupPerHour = v; }
52:     }
53:     public static class Cors {
54:         private String allowedOrigin;
55:         public String getAllowedOrigin() { return allowedOrigin; } public void setAllowedOrigin(String v) { allowedOrigin = v; }
56:     }
57:     public static class Ses {
58:         private boolean enabled = true;
59:         public boolean isEnabled() { return enabled; } public void setEnabled(boolean v) { enabled = v; }
60:     }
61: }
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
47:         try {
48:             var resp = sm.getSecretValue(GetSecretValueRequest.builder()
49:                 .secretId(props.getSecrets().getAdminSecretName())
50:                 .build());
51:             JsonNode json = mapper.readTree(resp.secretString());
52:             String email = json.get("username").asText().toLowerCase();
53:             String password = json.get("password").asText();
54:             if (users.existsByEmailIgnoreCase(email)) {
55:                 log.info("Admin user already present (idempotent skip)");
56:                 return;
57:             }
58:             Role admin = roles.findByName(Role.ADMIN).orElseThrow();
59:             Role user  = roles.findByName(Role.USER).orElseThrow();
60:             User u = new User();
61:             u.setEmail(email);
62:             u.setFullName("Administrator");
63:             u.setPasswordHash(encoder.encode(password));
64:             u.setVerified(true);
65:             u.setEnabled(true);
66:             u.setRoles(new HashSet<>(List.of(admin, user)));
67:             users.save(u);
68:             // Do not log the password. Email is fine; it's not secret.
69:             log.info("Admin user seeded: {}", email);
70:         } catch (Exception e) {
71:             log.error("Admin seed failed: {}", e.getClass().getSimpleName());
72:             // Re-throwing would block startup. Better to keep app available.
73:         }
74:     }
75: }
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

## File: app/backend/src/main/java/com/talorlik/javaapp/security/JwtService.java
````java
 1: package com.talorlik.javaapp.security;
 2: import com.fasterxml.jackson.databind.JsonNode;
 3: import com.fasterxml.jackson.databind.ObjectMapper;
 4: import com.talorlik.javaapp.config.AppProperties;
 5: import io.jsonwebtoken.Claims;
 6: import io.jsonwebtoken.Jwts;
 7: import io.jsonwebtoken.security.Keys;
 8: import jakarta.annotation.PostConstruct;
 9: import org.springframework.stereotype.Component;
10: import software.amazon.awssdk.services.secretsmanager.SecretsManagerClient;
11: import software.amazon.awssdk.services.secretsmanager.model.GetSecretValueRequest;
12: import javax.crypto.SecretKey;
13: import java.nio.charset.StandardCharsets;
14: import java.util.Date;
15: import java.util.List;
16: import java.util.Map;
17: /**
18:  * Builds and parses HMAC-signed JWTs. Signing key is fetched from Secrets
19:  * Manager at startup (single-shot read; not rotated mid-process).
20:  */
21: @Component
22: public class JwtService {
23:     private final AppProperties props;
24:     private final SecretsManagerClient sm;
25:     private final ObjectMapper mapper = new ObjectMapper();
26:     private SecretKey key;
27:     private String issuer;
28:     public JwtService(AppProperties props, SecretsManagerClient sm) {
29:         this.props = props;
30:         this.sm = sm;
31:     }
32:     @PostConstruct
33:     void init() throws Exception {
34:         var resp = sm.getSecretValue(GetSecretValueRequest.builder()
35:             .secretId(props.getSecrets().getJwtSecretName())
36:             .build());
37:         JsonNode json = mapper.readTree(resp.secretString());
38:         String signingKey = json.get("signing_key").asText();
39:         this.issuer = json.has("issuer") ? json.get("issuer").asText() : "java-app";
40:         // jjwt requires >= 256-bit key for HS256
41:         this.key = Keys.hmacShaKeyFor(signingKey.getBytes(StandardCharsets.UTF_8));
42:     }
43:     public String issueToken(String subject, List<String> roles) {
44:         long now = System.currentTimeMillis();
45:         long exp = now + props.getJwt().getExpirationMinutes() * 60_000L;
46:         return Jwts.builder()
47:             .issuer(issuer)
48:             .subject(subject)
49:             .issuedAt(new Date(now))
50:             .expiration(new Date(exp))
51:             .claims(Map.of("roles", roles))
52:             .signWith(key, Jwts.SIG.HS256)
53:             .compact();
54:     }
55:     public Claims parse(String token) {
56:         return Jwts.parser()
57:             .verifyWith(key)
58:             .requireIssuer(issuer)
59:             .build()
60:             .parseSignedClaims(token)
61:             .getPayload();
62:     }
63:     public long expirationSeconds() {
64:         return props.getJwt().getExpirationMinutes() * 60L;
65:     }
66: }
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

## File: app/backend/src/main/resources/application-test.yml
````yaml
 1: spring:
 2:   datasource:
 3:     url: jdbc:tc:mysql:8.0:///javaapp_test
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
23:     static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
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
 18:     <description>Java Signup Platform - Backend</description>
 19:     <properties>
 20:         <java.version>21</java.version>
 21:         <maven.compiler.source>21</maven.compiler.source>
 22:         <maven.compiler.target>21</maven.compiler.target>
 23:         <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
 24:         <jjwt.version>0.12.6</jjwt.version>
 25:         <aws.sdk.version>2.28.16</aws.sdk.version>
 26:         <testcontainers.version>1.20.4</testcontainers.version>
 27:         <bucket4j.version>8.10.1</bucket4j.version>
 28:     </properties>
 29:     <dependencies>
 30:         <!-- Web + validation -->
 31:         <dependency>
 32:             <groupId>org.springframework.boot</groupId>
 33:             <artifactId>spring-boot-starter-web</artifactId>
 34:         </dependency>
 35:         <dependency>
 36:             <groupId>org.springframework.boot</groupId>
 37:             <artifactId>spring-boot-starter-validation</artifactId>
 38:         </dependency>
 39:         <!-- Persistence -->
 40:         <dependency>
 41:             <groupId>org.springframework.boot</groupId>
 42:             <artifactId>spring-boot-starter-data-jpa</artifactId>
 43:         </dependency>
 44:         <dependency>
 45:             <groupId>com.mysql</groupId>
 46:             <artifactId>mysql-connector-j</artifactId>
 47:         </dependency>
 48:         <dependency>
 49:             <groupId>org.flywaydb</groupId>
 50:             <artifactId>flyway-core</artifactId>
 51:         </dependency>
 52:         <dependency>
 53:             <groupId>org.flywaydb</groupId>
 54:             <artifactId>flyway-mysql</artifactId>
 55:         </dependency>
 56:         <!-- Security + JWT -->
 57:         <dependency>
 58:             <groupId>org.springframework.boot</groupId>
 59:             <artifactId>spring-boot-starter-security</artifactId>
 60:         </dependency>
 61:         <dependency>
 62:             <groupId>io.jsonwebtoken</groupId>
 63:             <artifactId>jjwt-api</artifactId>
 64:             <version>${jjwt.version}</version>
 65:         </dependency>
 66:         <dependency>
 67:             <groupId>io.jsonwebtoken</groupId>
 68:             <artifactId>jjwt-impl</artifactId>
 69:             <version>${jjwt.version}</version>
 70:             <scope>runtime</scope>
 71:         </dependency>
 72:         <dependency>
 73:             <groupId>io.jsonwebtoken</groupId>
 74:             <artifactId>jjwt-jackson</artifactId>
 75:             <version>${jjwt.version}</version>
 76:             <scope>runtime</scope>
 77:         </dependency>
 78:         <!-- Actuator -->
 79:         <dependency>
 80:             <groupId>org.springframework.boot</groupId>
 81:             <artifactId>spring-boot-starter-actuator</artifactId>
 82:         </dependency>
 83:         <!-- AWS SDK v2 -->
 84:         <dependency>
 85:             <groupId>software.amazon.awssdk</groupId>
 86:             <artifactId>secretsmanager</artifactId>
 87:             <version>${aws.sdk.version}</version>
 88:         </dependency>
 89:         <dependency>
 90:             <groupId>software.amazon.awssdk</groupId>
 91:             <artifactId>sesv2</artifactId>
 92:             <version>${aws.sdk.version}</version>
 93:         </dependency>
 94:         <!-- Rate limiting -->
 95:         <dependency>
 96:             <groupId>com.bucket4j</groupId>
 97:             <artifactId>bucket4j-core</artifactId>
 98:             <version>${bucket4j.version}</version>
 99:         </dependency>
100:         <!-- ===== Test ===== -->
101:         <dependency>
102:             <groupId>org.springframework.boot</groupId>
103:             <artifactId>spring-boot-starter-test</artifactId>
104:             <scope>test</scope>
105:         </dependency>
106:         <dependency>
107:             <groupId>org.springframework.security</groupId>
108:             <artifactId>spring-security-test</artifactId>
109:             <scope>test</scope>
110:         </dependency>
111:         <dependency>
112:             <groupId>org.testcontainers</groupId>
113:             <artifactId>junit-jupiter</artifactId>
114:             <version>${testcontainers.version}</version>
115:             <scope>test</scope>
116:         </dependency>
117:         <dependency>
118:             <groupId>org.testcontainers</groupId>
119:             <artifactId>mysql</artifactId>
120:             <version>${testcontainers.version}</version>
121:             <scope>test</scope>
122:         </dependency>
123:     </dependencies>
124:     <build>
125:         <finalName>app</finalName>
126:         <plugins>
127:             <plugin>
128:                 <groupId>org.springframework.boot</groupId>
129:                 <artifactId>spring-boot-maven-plugin</artifactId>
130:                 <configuration>
131:                     <executable>true</executable>
132:                     <layers>
133:                         <enabled>true</enabled>
134:                     </layers>
135:                 </configuration>
136:             </plugin>
137:             <plugin>
138:                 <groupId>org.apache.maven.plugins</groupId>
139:                 <artifactId>maven-surefire-plugin</artifactId>
140:                 <configuration>
141:                     <includes>
142:                         <include>**/unit/**/*Test.java</include>
143:                         <include>**/*UnitTest.java</include>
144:                     </includes>
145:                 </configuration>
146:             </plugin>
147:             <plugin>
148:                 <groupId>org.apache.maven.plugins</groupId>
149:                 <artifactId>maven-failsafe-plugin</artifactId>
150:                 <configuration>
151:                     <includes>
152:                         <include>**/integration/**/*IT.java</include>
153:                         <include>**/*IT.java</include>
154:                     </includes>
155:                 </configuration>
156:                 <executions>
157:                     <execution>
158:                         <goals>
159:                             <goal>integration-test</goal>
160:                             <goal>verify</goal>
161:                         </goals>
162:                     </execution>
163:                 </executions>
164:             </plugin>
165:         </plugins>
166:     </build>
167: </project>
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
 9:     image: mysql:8.0
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
35:       AWS_REGION: us-east-1
36:       SES_ENABLED: "false"
37:       JWT_SECRET_NAME: disabled-local
38:       SES_SECRET_NAME: disabled-local
39:       ADMIN_SECRET_NAME: disabled-local
40:       APP_PUBLIC_URL: http://localhost:8080
41:     healthcheck:
42:       test: ["CMD", "curl", "-fsS", "http://localhost:8080/actuator/health"]
43:       interval: 10s
44:       timeout: 3s
45:       retries: 30
46:       start_period: 60s
47:     expose:
48:       - "8080"
49:   frontend:
50:     build:
51:       context: ../frontend
52:     image: java-app/frontend:dev
53:     ports:
54:       - "8080:80"
55:     depends_on:
56:       backend:
57:         condition: service_healthy
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

## File: app/frontend/src/index.html
````html
 1: <!doctype html>
 2: <html lang="en">
 3: <head>
 4:   <meta charset="utf-8" />
 5:   <meta name="viewport" content="width=device-width, initial-scale=1" />
 6:   <title>Java Signup Platform</title>
 7:   <link rel="stylesheet" href="/css/main.css" />
 8: </head>
 9: <body>
10:   <header class="topbar">
11:     <a class="brand" href="/">java.talorlik.com</a>
12:     <nav id="nav"></nav>
13:   </header>
14:   <main id="app"></main>
15:   <footer class="bottombar">
16:     <span>Java Signup Platform</span>
17:   </footer>
18:   <script type="module" src="/js/app.js"></script>
19: </body>
20: </html>
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
 22:   description             = "KMS key for Terraform state bucket (${var.state_bucket_name})"
 23:   deletion_window_in_days = 30
 24:   enable_key_rotation     = true
 25: 
 26:   policy = jsonencode({
 27:     Version = "2012-10-17"
 28:     Statement = [
 29:       {
 30:         Sid    = "EnableRootAccountPermissions"
 31:         Effect = "Allow"
 32:         Principal = {
 33:           AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
 34:         }
 35:         Action   = "kms:*"
 36:         Resource = "*"
 37:       }
 38:     ]
 39:   })
 40: }
 41: 
 42: resource "aws_kms_alias" "tfstate" {
 43:   name          = var.kms_alias
 44:   target_key_id = aws_kms_key.tfstate.key_id
 45: }
 46: 
 47: # ----------------------------------------------------------------------------
 48: # Optional access-log bucket
 49: # ----------------------------------------------------------------------------
 50: resource "aws_s3_bucket" "access_logs" {
 51:   count         = var.enable_access_logging ? 1 : 0
 52:   bucket        = "${var.state_bucket_name}-access-logs"
 53:   force_destroy = false
 54: }
 55: 
 56: resource "aws_s3_bucket_public_access_block" "access_logs" {
 57:   count                   = var.enable_access_logging ? 1 : 0
 58:   bucket                  = aws_s3_bucket.access_logs[0].id
 59:   block_public_acls       = true
 60:   block_public_policy     = true
 61:   ignore_public_acls      = true
 62:   restrict_public_buckets = true
 63: }
 64: 
 65: resource "aws_s3_bucket_ownership_controls" "access_logs" {
 66:   count  = var.enable_access_logging ? 1 : 0
 67:   bucket = aws_s3_bucket.access_logs[0].id
 68:   rule {
 69:     object_ownership = "BucketOwnerEnforced"
 70:   }
 71: }
 72: 
 73: resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
 74:   count  = var.enable_access_logging ? 1 : 0
 75:   bucket = aws_s3_bucket.access_logs[0].id
 76:   rule {
 77:     apply_server_side_encryption_by_default {
 78:       sse_algorithm = "AES256"
 79:     }
 80:   }
 81: }
 82: 
 83: # ----------------------------------------------------------------------------
 84: # Terraform state bucket
 85: # ----------------------------------------------------------------------------
 86: # NOTE: force_destroy is intentionally false. State buckets must never be
 87: # accidentally emptied.
 88: resource "aws_s3_bucket" "tfstate" {
 89:   bucket        = var.state_bucket_name
 90:   force_destroy = false
 91: }
 92: 
 93: resource "aws_s3_bucket_versioning" "tfstate" {
 94:   bucket = aws_s3_bucket.tfstate.id
 95:   versioning_configuration {
 96:     status = "Enabled"
 97:   }
 98: }
 99: 
100: resource "aws_s3_bucket_public_access_block" "tfstate" {
101:   bucket                  = aws_s3_bucket.tfstate.id
102:   block_public_acls       = true
103:   block_public_policy     = true
104:   ignore_public_acls      = true
105:   restrict_public_buckets = true
106: }
107: 
108: resource "aws_s3_bucket_ownership_controls" "tfstate" {
109:   bucket = aws_s3_bucket.tfstate.id
110:   rule {
111:     object_ownership = "BucketOwnerEnforced"
112:   }
113: }
114: 
115: resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
116:   bucket = aws_s3_bucket.tfstate.id
117:   rule {
118:     apply_server_side_encryption_by_default {
119:       sse_algorithm     = "aws:kms"
120:       kms_master_key_id = aws_kms_key.tfstate.arn
121:     }
122:     bucket_key_enabled = true
123:   }
124: }
125: 
126: resource "aws_s3_bucket_logging" "tfstate" {
127:   count         = var.enable_access_logging ? 1 : 0
128:   bucket        = aws_s3_bucket.tfstate.id
129:   target_bucket = aws_s3_bucket.access_logs[0].id
130:   target_prefix = "tfstate-access/"
131: }
132: 
133: # Enforce TLS for all requests against the state bucket
134: resource "aws_s3_bucket_policy" "tfstate_tls_only" {
135:   bucket = aws_s3_bucket.tfstate.id
136: 
137:   policy = jsonencode({
138:     Version = "2012-10-17"
139:     Statement = [
140:       {
141:         Sid       = "DenyInsecureTransport"
142:         Effect    = "Deny"
143:         Principal = "*"
144:         Action    = "s3:*"
145:         Resource = [
146:           aws_s3_bucket.tfstate.arn,
147:           "${aws_s3_bucket.tfstate.arn}/*"
148:         ]
149:         Condition = {
150:           Bool = {
151:             "aws:SecureTransport" = "false"
152:           }
153:         }
154:       }
155:     ]
156:   })
157: }
158: 
159: # Lifecycle: keep noncurrent versions for 90 days, abort incomplete uploads
160: resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
161:   bucket = aws_s3_bucket.tfstate.id
162: 
163:   rule {
164:     id     = "expire-noncurrent"
165:     status = "Enabled"
166: 
167:     noncurrent_version_expiration {
168:       noncurrent_days = 90
169:     }
170: 
171:     abort_incomplete_multipart_upload {
172:       days_after_initiation = 7
173:     }
174:   }
175: }
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
13: # Fail fast if the wrong account is used. Catches a class of footgun where the
14: # operator has stale credentials. terraform_data is built-in (no extra
15: # provider) and supports lifecycle.precondition.
16: resource "terraform_data" "account_guard" {
17:   input = data.aws_caller_identity.current.account_id
18: 
19:   lifecycle {
20:     precondition {
21:       condition     = data.aws_caller_identity.current.account_id == var.deployment_account_id
22:       error_message = "Active credentials target account ${data.aws_caller_identity.current.account_id} but var.deployment_account_id is ${var.deployment_account_id}."
23:     }
24:   }
25: }
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
13:   alias {
14:     name                   = module.alb.dns_name
15:     zone_id                = module.alb.zone_id
16:     evaluate_target_health = true
17:   }
18: }
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
21: }
22: 
23: resource "aws_sesv2_configuration_set" "app" {
24:   configuration_set_name = "${local.name_prefix}-ses"
25: 
26:   delivery_options {
27:     tls_policy = "REQUIRE"
28:   }
29: 
30:   reputation_options {
31:     reputation_metrics_enabled = true
32:   }
33: 
34:   sending_options {
35:     sending_enabled = true
36:   }
37: }
38: 
39: resource "aws_sesv2_configuration_set_event_destination" "cw" {
40:   configuration_set_name = aws_sesv2_configuration_set.app.configuration_set_name
41:   event_destination_name = "cloudwatch"
42: 
43:   event_destination {
44:     enabled = true
45:     matching_event_types = [
46:       "SEND", "REJECT", "BOUNCE", "COMPLAINT", "DELIVERY", "RENDERING_FAILURE", "DELIVERY_DELAY"
47:     ]
48:     cloud_watch_destination {
49:       dimension_configuration {
50:         default_dimension_value = "default"
51:         dimension_name          = "MessageTag"
52:         dimension_value_source  = "MESSAGE_TAG"
53:       }
54:     }
55:   }
56: }
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
32: rds_engine_version               = "8.0"
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
17:   }
18: }
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
````

## File: .github/workflows/infra-apply.yml
````yaml
 1: name: infra-apply
 2: on:
 3:   workflow_dispatch:
 4: permissions:
 5:   id-token: write
 6:   contents: read
 7: concurrency:
 8:   group: infra-apply
 9:   cancel-in-progress: false
10: jobs:
11:   apply:
12:     runs-on: ubuntu-latest
13:     environment: prod
14:     steps:
15:       - uses: actions/checkout@v4
16:       - uses: aws-actions/configure-aws-credentials@v4
17:         with:
18:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
19:           aws-region: ${{ vars.AWS_REGION }}
20:           role-session-name: gha-infra-apply
21:       - uses: hashicorp/setup-terraform@v3
22:         with:
23:           terraform_version: 1.9.8
24:       - name: init
25:         working-directory: infra/envs/prod
26:         run: |
27:           terraform init \
28:             -backend-config="bucket=java-app-tfstate-${{ vars.DEPLOYMENT_ACCOUNT_ID }}-${{ vars.AWS_REGION }}" \
29:             -backend-config="region=${{ vars.AWS_REGION }}"
30:       - name: plan
31:         working-directory: infra/envs/prod
32:         env:
33:           TF_VAR_aws_region: ${{ vars.AWS_REGION }}
34:           TF_VAR_deployment_account_id: ${{ vars.DEPLOYMENT_ACCOUNT_ID }}
35:           TF_VAR_domain_account_id: ${{ vars.DOMAIN_ACCOUNT_ID }}
36:           TF_VAR_domain_account_route53_role_arn: ${{ secrets.DOMAIN_ROUTE53_ROLE_ARN }}
37:           TF_VAR_hosted_zone_id: ${{ vars.HOSTED_ZONE_ID }}
38:           TF_VAR_acm_certificate_arn: ${{ secrets.ACM_CERTIFICATE_ARN }}
39:         run: terraform plan -input=false -out=tfplan
40:       - name: apply
41:         working-directory: infra/envs/prod
42:         run: terraform apply -input=false -auto-approve tfplan
43:       - name: outputs
44:         working-directory: infra/envs/prod
45:         run: terraform output -no-color
46:       - name: Upload compose file to S3 (compose-object pointer)
47:         env:
48:           AWS_REGION: ${{ vars.AWS_REGION }}
49:         run: |
50:           BUCKET="java-app-prod-config-${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
51:           # Best-effort - bucket may already exist from a prior run.
52:           aws s3api create-bucket --bucket "$BUCKET" --region "$AWS_REGION" 2>/dev/null || true
53:           aws s3api put-public-access-block --bucket "$BUCKET" \
54:             --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
55:           aws s3 cp app/docker/docker-compose.prod.yml "s3://$BUCKET/docker-compose.prod.yml"
56:           aws ssm put-parameter --name "/java-app/prod/compose-object" \
57:             --type String --overwrite \
58:             --value "s3://$BUCKET/docker-compose.prod.yml"
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
14:       - uses: actions/checkout@v4
15:       - uses: aws-actions/configure-aws-credentials@v4
16:         with:
17:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
18:           aws-region: ${{ vars.AWS_REGION }}
19:           role-session-name: gha-infra-plan
20:       - uses: hashicorp/setup-terraform@v3
21:         with:
22:           terraform_version: 1.9.8
23:       - name: terraform init
24:         working-directory: infra/envs/prod
25:         run: |
26:           terraform init \
27:             -backend-config="bucket=java-app-tfstate-${{ vars.DEPLOYMENT_ACCOUNT_ID }}-${{ vars.AWS_REGION }}" \
28:             -backend-config="region=${{ vars.AWS_REGION }}"
29:       - name: terraform fmt
30:         working-directory: infra/envs/prod
31:         run: terraform fmt -check
32:       - name: terraform validate
33:         working-directory: infra/envs/prod
34:         run: terraform validate
35:       - name: terraform plan
36:         working-directory: infra/envs/prod
37:         env:
38:           TF_VAR_aws_region: ${{ vars.AWS_REGION }}
39:           TF_VAR_deployment_account_id: ${{ vars.DEPLOYMENT_ACCOUNT_ID }}
40:           TF_VAR_domain_account_id: ${{ vars.DOMAIN_ACCOUNT_ID }}
41:           TF_VAR_domain_account_route53_role_arn: ${{ secrets.DOMAIN_ROUTE53_ROLE_ARN }}
42:           TF_VAR_hosted_zone_id: ${{ vars.HOSTED_ZONE_ID }}
43:           TF_VAR_acm_certificate_arn: ${{ secrets.ACM_CERTIFICATE_ARN }}
44:         run: |
45:           terraform plan -no-color -input=false -out=tfplan
46:           terraform show -no-color tfplan > plan.txt
47:       - uses: actions/upload-artifact@v4
48:         with:
49:           name: terraform-plan
50:           path: |
51:             infra/envs/prod/tfplan
52:             infra/envs/prod/plan.txt
53:       - name: Surface plan in job summary
54:         run: |
55:           {
56:             echo "### terraform plan"
57:             echo ""
58:             echo '```'
59:             head -c 60000 infra/envs/prod/plan.txt
60:             echo ""
61:             echo '```'
62:           } >> "$GITHUB_STEP_SUMMARY"
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
18:       hibernate.dialect: org.hibernate.dialect.MySQL8Dialect
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
59:   verification:
60:     code-length: 6
61:     ttl-minutes: 30
62:     max-attempts: 5
63:   rate-limit:
64:     login-per-minute: 10
65:     verify-per-minute: 10
66:     signup-per-hour: 20
67:   cors:
68:     allowed-origin: ${APP_PUBLIC_URL:https://java.talorlik.com}
69:   ses:
70:     enabled: ${SES_ENABLED:true}
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
 75: retry 5 10 apt-get install -y ca-certificates curl gnupg lsb-release jq unzip awscli
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
111: BACKEND_TAG=$(aws ssm get-parameter --region "$REGION" --name "${ssm_backend_tag}"  --query 'Parameter.Value' --output text)
112: FRONTEND_TAG=$(aws ssm get-parameter --region "$REGION" --name "${ssm_frontend_tag}" --query 'Parameter.Value' --output text)
113: RELEASE_ID=$(aws ssm get-parameter --region "$REGION" --name "${ssm_release_id}"   --query 'Parameter.Value' --output text)
114: DB_HOST=$(aws ssm get-parameter --region "$REGION" --name "${ssm_db_endpoint}"     --query 'Parameter.Value' --output text)
115: DB_NAME=$(aws ssm get-parameter --region "$REGION" --name "${ssm_db_name}"         --query 'Parameter.Value' --output text)
116: COMPOSE_OBJ=$(aws ssm get-parameter --region "$REGION" --name "${ssm_compose_object}" --query 'Parameter.Value' --output text)
117: 
118: # ---- Pull DB app-user creds from Secrets Manager ----
119: DB_USER_JSON=$(aws secretsmanager get-secret-value --region "$REGION" --secret-id "${secret_db_app_user}" --query 'SecretString' --output text)
120: DB_USER=$(echo "$DB_USER_JSON" | jq -r .username)
121: DB_PASS=$(echo "$DB_USER_JSON" | jq -r .password)
122: 
123: # JWT (only used by backend at runtime - pulled by the backend itself via
124: # Secrets Manager too; here we only export the secret name as an env var).
125: JWT_SECRET_NAME="${secret_jwt}"
126: SES_SECRET_NAME="${secret_ses}"
127: ADMIN_SECRET_NAME="${secret_admin}"
128: 
129: # ---- Render .env file (mode 0600, root-owned) ----
130: umask 077
131: cat >/opt/java-app/.env <<EOF
132: # Generated by user-data on $(date -Iseconds)
133: RELEASE_ID=$${RELEASE_ID}
134: BACKEND_IMAGE=${backend_repo_url}:$${BACKEND_TAG}
135: FRONTEND_IMAGE=${frontend_repo_url}:$${FRONTEND_TAG}
136: 
137: AWS_REGION=$${REGION}
138: 
139: DB_HOST=$${DB_HOST}
140: DB_PORT=3306
141: DB_NAME=$${DB_NAME}
142: DB_USERNAME=$${DB_USER}
143: DB_PASSWORD=$${DB_PASS}
144: 
145: JWT_SECRET_NAME=$${JWT_SECRET_NAME}
146: SES_SECRET_NAME=$${SES_SECRET_NAME}
147: ADMIN_SECRET_NAME=$${ADMIN_SECRET_NAME}
148: 
149: APP_PUBLIC_URL=https://${app_subdomain}
150: EOF
151: chmod 0600 /opt/java-app/.env
152: 
153: # ---- Fetch docker-compose.prod.yml from S3 (pointer in SSM) ----
154: if [[ "$${COMPOSE_OBJ}" == s3://* ]]; then
155:   retry 5 5 aws s3 cp "$${COMPOSE_OBJ}" /opt/java-app/docker-compose.yml
156: else
157:   echo "[user-data] WARNING: compose-object SSM value is '$${COMPOSE_OBJ}' (not s3:// URI)."
158:   # Sane default to keep the box up if compose isn't published yet.
159:   cat >/opt/java-app/docker-compose.yml <<'YAML'
160: services:
161:   placeholder:
162:     image: nginx:1.27-alpine
163:     ports: ["8080:80"]
164:     restart: unless-stopped
165: YAML
166: fi
167: 
168: # ---- ECR auth (with retry; ECR rate-limits cold logins occasionally) ----
169: retry 5 5 bash -c "aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${deployment_account}.dkr.ecr.$REGION.amazonaws.com"
170: 
171: # ---- Compose up ----
172: cd /opt/java-app
173: # `pull` failure must NOT be ignored: if a tag is missing, the box should
174: # fail provisioning and be replaced rather than start a stale image.
175: retry 3 10 docker compose --env-file /opt/java-app/.env pull
176: docker compose --env-file /opt/java-app/.env up -d --remove-orphans
177: 
178: # ---- CloudWatch Agent config ----
179: cat >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<JSON
180: {
181:   "agent": { "metrics_collection_interval": 60, "run_as_user": "root" },
182:   "metrics": {
183:     "namespace": "JavaApp/EC2",
184:     "append_dimensions": {
185:       "InstanceId": "\$${aws:InstanceId}",
186:       "AutoScalingGroupName": "\$${aws:AutoScalingGroupName}"
187:     },
188:     "metrics_collected": {
189:       "cpu":  { "measurement": ["cpu_usage_idle","cpu_usage_iowait","cpu_usage_user","cpu_usage_system"], "totalcpu": true },
190:       "mem":  { "measurement": ["mem_used_percent"] },
191:       "disk": { "measurement": ["used_percent"], "resources": ["/"] },
192:       "diskio": { "measurement": ["io_time"] }
193:     }
194:   },
195:   "logs": {
196:     "logs_collected": {
197:       "files": {
198:         "collect_list": [
199:           { "file_path": "/var/log/user-data.log",       "log_group_name": "$${LOG_GROUP}", "log_stream_name": "{instance_id}/user-data" },
200:           { "file_path": "/var/log/cloud-init-output.log","log_group_name": "$${LOG_GROUP}", "log_stream_name": "{instance_id}/cloud-init" },
201:           { "file_path": "/var/lib/docker/containers/*/*-json.log", "log_group_name": "$${LOG_GROUP}", "log_stream_name": "{instance_id}/docker" }
202:         ]
203:       }
204:     }
205:   }
206: }
207: JSON
208: 
209: /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
210:   -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
211: 
212: # ---- Wait for actuator/health BEFORE we hand off to the ASG. ----
213: # The ALB target group also probes /actuator/health, but it does so via the
214: # ALB SG path, which adds a DNS hop. Probing locally first lets us fail
215: # fast and self-mark Unhealthy if the app never comes up, instead of
216: # letting the ASG eventually time out the grace period.
217: echo "[user-data] waiting for /actuator/health on localhost:8080"
218: deadline=$(( $(date +%s) + 240 ))
219: ok=0
220: while (( $(date +%s) < deadline )); do
221:   if curl -fsS --max-time 5 "http://127.0.0.1:8080/actuator/health" | grep -q '"status":"UP"'; then
222:     ok=1
223:     break
224:   fi
225:   sleep 5
226: done
227: 
228: if (( ok != 1 )); then
229:   # Disable the trap so self_unhealthy runs cleanly.
230:   trap - ERR
231:   self_unhealthy "actuator never reported UP within 240s"
232: fi
233: 
234: # Disable the trap before exit so a benign cleanup doesn't trigger it.
235: trap - ERR
236: echo "[user-data] done at $(date -Iseconds)"
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
20:   force_delete         = false
21: 
22:   image_scanning_configuration {
23:     scan_on_push = true
24:   }
25: 
26:   encryption_configuration {
27:     encryption_type = "KMS"
28:     kms_key         = aws_kms_key.app_secrets.arn
29:   }
30: 
31:   tags = local.common_tags
32: }
33: 
34: resource "aws_ecr_lifecycle_policy" "this" {
35:   for_each   = aws_ecr_repository.this
36:   repository = each.value.name
37: 
38:   policy = jsonencode({
39:     rules = [
40:       {
41:         rulePriority = 1
42:         description  = "Keep last 30 SHA-tagged images"
43:         selection = {
44:           tagStatus      = "tagged"
45:           tagPatternList = ["sha-*", "v*"]
46:           countType      = "imageCountMoreThan"
47:           countNumber    = 30
48:         }
49:         action = { type = "expire" }
50:       },
51:       {
52:         rulePriority = 2
53:         description  = "Expire untagged images after 7 days"
54:         selection = {
55:           tagStatus   = "untagged"
56:           countType   = "sinceImagePushed"
57:           countUnit   = "days"
58:           countNumber = 7
59:         }
60:         action = { type = "expire" }
61:       }
62:     ]
63:   })
64: }
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
16:     backend_image_tag  = "${local.secret_prefix}/backend-image-tag"
17:     frontend_image_tag = "${local.secret_prefix}/frontend-image-tag"
18:     release_id         = "${local.secret_prefix}/release-id"
19:     compose_object     = "${local.secret_prefix}/compose-object"
20:     db_endpoint        = "${local.secret_prefix}/db/endpoint"
21:     db_name            = "${local.secret_prefix}/db/name"
22:     log_group_app      = "${local.secret_prefix}/log-group/app"
23:   }
24: 
25:   app_port       = 8080
26:   alb_https_port = 443
27:   alb_http_port  = 80
28:   db_port        = 3306
29: 
30:   # Subnet CIDRs derived from var.vpc_cidr (a /16). Reserves /24s in the /16
31:   # so each tier gets up to 4 AZs without renumbering.
32:   public_subnets   = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
33:   private_app_cidr = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, 10 + i)]
34:   private_db_cidr  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, 20 + i)]
35: }
36: 
37: data "aws_availability_zones" "available" {
38:   state = "available"
39: }
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
 14:   source  = "terraform-aws-modules/vpc/aws"
 15:   version = "~> 5.13"
 16: 
 17:   name = "${local.name_prefix}-vpc"
 18:   cidr = var.vpc_cidr
 19: 
 20:   azs              = slice(data.aws_availability_zones.available.names, 0, var.az_count)
 21:   public_subnets   = local.public_subnets
 22:   private_subnets  = local.private_app_cidr
 23:   database_subnets = local.private_db_cidr
 24: 
 25:   create_database_subnet_group       = true
 26:   create_database_subnet_route_table = true
 27: 
 28:   enable_nat_gateway     = true
 29:   single_nat_gateway     = false
 30:   one_nat_gateway_per_az = true
 31: 
 32:   enable_dns_hostnames = true
 33:   enable_dns_support   = true
 34: 
 35:   # Flow logs (CloudWatch) for forensic visibility (FR-OPS-01).
 36:   enable_flow_log                                 = true
 37:   create_flow_log_cloudwatch_iam_role             = true
 38:   create_flow_log_cloudwatch_log_group            = true
 39:   flow_log_max_aggregation_interval               = 60
 40:   flow_log_cloudwatch_log_group_retention_in_days = var.log_retention_days
 41: 
 42:   public_subnet_tags = {
 43:     Tier                     = "public"
 44:     "kubernetes.io/role/elb" = "1" # harmless tag, useful for any future EKS coexistence
 45:   }
 46:   private_subnet_tags = {
 47:     Tier = "private-app"
 48:   }
 49:   database_subnet_tags = {
 50:     Tier = "private-db"
 51:   }
 52: 
 53:   tags = local.common_tags
 54: }
 55: 
 56: # ----------------------------------------------------------------------------
 57: # VPC Endpoints
 58: # ----------------------------------------------------------------------------
 59: 
 60: # Endpoint security group: allow HTTPS from VPC CIDR.
 61: resource "aws_security_group" "vpce" {
 62:   name        = "${local.name_prefix}-vpce-sg"
 63:   description = "Allow HTTPS from VPC to interface VPC endpoints"
 64:   vpc_id      = module.vpc.vpc_id
 65: 
 66:   ingress {
 67:     description = "HTTPS from VPC"
 68:     from_port   = 443
 69:     to_port     = 443
 70:     protocol    = "tcp"
 71:     cidr_blocks = [var.vpc_cidr]
 72:   }
 73: 
 74:   egress {
 75:     description = "All egress"
 76:     from_port   = 0
 77:     to_port     = 0
 78:     protocol    = "-1"
 79:     cidr_blocks = ["0.0.0.0/0"]
 80:   }
 81: 
 82:   tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpce-sg" })
 83: }
 84: 
 85: locals {
 86:   interface_endpoints = [
 87:     "ssm",
 88:     "ssmmessages",
 89:     "ec2messages",
 90:     "secretsmanager",
 91:     "logs",
 92:     "monitoring",
 93:     "ecr.api",
 94:     "ecr.dkr",
 95:   ]
 96: }
 97: 
 98: resource "aws_vpc_endpoint" "interface" {
 99:   for_each = toset(local.interface_endpoints)
100: 
101:   vpc_id              = module.vpc.vpc_id
102:   service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
103:   vpc_endpoint_type   = "Interface"
104:   subnet_ids          = module.vpc.private_subnets
105:   security_group_ids  = [aws_security_group.vpce.id]
106:   private_dns_enabled = true
107: 
108:   tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpce-${replace(each.value, ".", "-")}" })
109: }
110: 
111: # S3 gateway endpoint - required for ECR layer pulls (ECR stores layers in S3)
112: # and for any direct S3 access (e.g. compose object).
113: resource "aws_vpc_endpoint" "s3" {
114:   vpc_id            = module.vpc.vpc_id
115:   service_name      = "com.amazonaws.${var.aws_region}.s3"
116:   vpc_endpoint_type = "Gateway"
117:   route_table_ids   = concat(module.vpc.private_route_table_ids, module.vpc.database_route_table_ids)
118: 
119:   tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpce-s3" })
120: }
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

## File: infra/envs/prod/secrets.tf
````hcl
  1: ###############################################################################
  2: # Secrets Manager + KMS for application runtime secrets.
  3: #
  4: # - Master DB password is created by RDS-managed master credentials in rds.tf.
  5: # - App-user DB password is created here (Terraform random_password) and must
  6: #   be created inside MySQL via Flyway migration after RDS is up.
  7: # - Admin bootstrap secret is generated and seeded by the backend's startup
  8: #   routine if not already present.
  9: # - JWT signing key is generated here.
 10: # - SES sender config is a plain JSON struct of identity + region.
 11: ###############################################################################
 12: 
 13: # CMK for application secrets, SSM parameters, and CloudWatch log groups.
 14: # Policy must allow CloudWatch Logs service to use the key for the specific
 15: # log groups, otherwise CreateLogGroup fails with AccessDeniedException.
 16: resource "aws_kms_key" "app_secrets" {
 17:   description             = "App secrets, SSM parameters, and log group encryption"
 18:   deletion_window_in_days = 30
 19:   enable_key_rotation     = true
 20: 
 21:   policy = jsonencode({
 22:     Version = "2012-10-17"
 23:     Statement = [
 24:       {
 25:         Sid       = "EnableRootPermissions"
 26:         Effect    = "Allow"
 27:         Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${var.deployment_account_id}:root" }
 28:         Action    = "kms:*"
 29:         Resource  = "*"
 30:       },
 31:       {
 32:         Sid       = "AllowCloudWatchLogsUseOfKey"
 33:         Effect    = "Allow"
 34:         Principal = { Service = "logs.${var.aws_region}.amazonaws.com" }
 35:         Action = [
 36:           "kms:Encrypt",
 37:           "kms:Decrypt",
 38:           "kms:ReEncrypt*",
 39:           "kms:GenerateDataKey*",
 40:           "kms:DescribeKey",
 41:         ]
 42:         Resource = "*"
 43:         Condition = {
 44:           ArnLike = {
 45:             "kms:EncryptionContext:aws:logs:arn" = "arn:${data.aws_partition.current.partition}:logs:${var.aws_region}:${var.deployment_account_id}:log-group:/${var.project}/${var.environment}/*"
 46:           }
 47:         }
 48:       },
 49:       {
 50:         Sid       = "AllowSnsUseOfKey"
 51:         Effect    = "Allow"
 52:         Principal = { Service = "sns.amazonaws.com" }
 53:         Action    = ["kms:Decrypt", "kms:GenerateDataKey*"]
 54:         Resource  = "*"
 55:       },
 56:       {
 57:         Sid       = "AllowEventsToPublishToSnsViaKey"
 58:         Effect    = "Allow"
 59:         Principal = { Service = "events.amazonaws.com" }
 60:         Action    = ["kms:Decrypt", "kms:GenerateDataKey*"]
 61:         Resource  = "*"
 62:       }
 63:     ]
 64:   })
 65: }
 66: 
 67: resource "aws_kms_alias" "app_secrets" {
 68:   name          = "alias/${local.name_prefix}-secrets"
 69:   target_key_id = aws_kms_key.app_secrets.key_id
 70: }
 71: 
 72: # ----------------------------------------------------------------------------
 73: # Application DB user
 74: # ----------------------------------------------------------------------------
 75: resource "random_password" "db_app_user" {
 76:   length           = 32
 77:   special          = true
 78:   override_special = "!#%&*+-=?_"
 79: }
 80: 
 81: resource "random_password" "admin_bootstrap" {
 82:   length  = 24
 83:   special = false
 84: }
 85: 
 86: resource "random_password" "jwt_signing" {
 87:   length  = 64
 88:   special = false
 89: }
 90: 
 91: resource "aws_secretsmanager_secret" "db_app_user" {
 92:   name                    = "${local.secret_prefix}/db/app-user"
 93:   description             = "App user credentials (least-privileged DB role)"
 94:   kms_key_id              = aws_kms_key.app_secrets.arn
 95:   recovery_window_in_days = 7
 96: }
 97: 
 98: resource "aws_secretsmanager_secret_version" "db_app_user" {
 99:   secret_id = aws_secretsmanager_secret.db_app_user.id
100:   secret_string = jsonencode({
101:     username = var.db_app_username
102:     password = random_password.db_app_user.result
103:   })
104: }
105: 
106: # ----------------------------------------------------------------------------
107: # Admin bootstrap (idempotent seed at startup)
108: # ----------------------------------------------------------------------------
109: resource "aws_secretsmanager_secret" "admin" {
110:   name                    = "${local.secret_prefix}/admin"
111:   description             = "Bootstrap admin user. Read once at app startup."
112:   kms_key_id              = aws_kms_key.app_secrets.arn
113:   recovery_window_in_days = 7
114: }
115: 
116: resource "aws_secretsmanager_secret_version" "admin" {
117:   secret_id = aws_secretsmanager_secret.admin.id
118:   secret_string = jsonencode({
119:     username = "admin@${var.root_domain}"
120:     password = random_password.admin_bootstrap.result
121:   })
122: }
123: 
124: # ----------------------------------------------------------------------------
125: # JWT signing secret
126: # ----------------------------------------------------------------------------
127: resource "aws_secretsmanager_secret" "jwt" {
128:   name                    = "${local.secret_prefix}/jwt"
129:   description             = "HMAC signing key for backend JWT"
130:   kms_key_id              = aws_kms_key.app_secrets.arn
131:   recovery_window_in_days = 7
132: }
133: 
134: resource "aws_secretsmanager_secret_version" "jwt" {
135:   secret_id = aws_secretsmanager_secret.jwt.id
136:   secret_string = jsonencode({
137:     signing_key = random_password.jwt_signing.result
138:     issuer      = "https://${var.app_subdomain}"
139:   })
140: }
141: 
142: # ----------------------------------------------------------------------------
143: # SES sender config
144: # ----------------------------------------------------------------------------
145: resource "aws_secretsmanager_secret" "ses" {
146:   name                    = "${local.secret_prefix}/ses"
147:   description             = "SES sender identity / region configuration"
148:   kms_key_id              = aws_kms_key.app_secrets.arn
149:   recovery_window_in_days = 7
150: }
151: 
152: resource "aws_secretsmanager_secret_version" "ses" {
153:   secret_id = aws_secretsmanager_secret.ses.id
154:   secret_string = jsonencode({
155:     region        = var.aws_region
156:     sender_domain = var.ses_sender_subdomain
157:     from_address  = var.ses_from_address
158:   })
159: }
160: 
161: # ----------------------------------------------------------------------------
162: # Non-secret runtime config (kept as SSM Parameter Store, not Secrets Manager)
163: # ----------------------------------------------------------------------------
164: resource "aws_ssm_parameter" "compose_object" {
165:   # The instance user data downloads docker-compose.prod.yml from this
166:   # location. The value is set later via CI (or by an operator copying the
167:   # compose file to S3 and writing the s3:// URI here).
168:   name        = local.ssm_keys.compose_object
169:   description = "S3 URI of docker-compose.prod.yml used by EC2 user data"
170:   type        = "String"
171:   value       = "PENDING"
172: 
173:   lifecycle {
174:     ignore_changes = [value]
175:   }
176: }
177: 
178: resource "aws_ssm_parameter" "backend_image_tag" {
179:   name        = local.ssm_keys.backend_image_tag
180:   description = "Backend image tag (commit SHA) consumed by user data"
181:   type        = "String"
182:   value       = var.initial_backend_image_tag
183: 
184:   lifecycle {
185:     # CI/CD updates this on each release; we don't want Terraform to revert it.
186:     ignore_changes = [value]
187:   }
188: }
189: 
190: resource "aws_ssm_parameter" "frontend_image_tag" {
191:   name  = local.ssm_keys.frontend_image_tag
192:   type  = "String"
193:   value = var.initial_frontend_image_tag
194:   lifecycle {
195:     ignore_changes = [value]
196:   }
197: }
198: 
199: resource "aws_ssm_parameter" "release_id" {
200:   name  = local.ssm_keys.release_id
201:   type  = "String"
202:   value = "bootstrap"
203:   lifecycle {
204:     ignore_changes = [value]
205:   }
206: }
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
 12:   name        = "${local.name_prefix}-alb-sg"
 13:   description = "Public ALB. Accepts HTTPS on 443 and HTTP on 80 (redirect) from the internet."
 14:   vpc_id      = module.vpc.vpc_id
 15:   tags        = merge(local.common_tags, { Name = "${local.name_prefix}-alb-sg" })
 16: }
 17: 
 18: resource "aws_vpc_security_group_ingress_rule" "alb_https" {
 19:   security_group_id = aws_security_group.alb.id
 20:   description       = "Public HTTPS"
 21:   ip_protocol       = "tcp"
 22:   from_port         = local.alb_https_port
 23:   to_port           = local.alb_https_port
 24:   cidr_ipv4         = "0.0.0.0/0"
 25: }
 26: 
 27: # Plain HTTP only exists so the ALB can issue a 301 to HTTPS. No traffic
 28: # reaches the app tier on port 80; the ALB's own listener handles the
 29: # redirect locally.
 30: resource "aws_vpc_security_group_ingress_rule" "alb_http_redirect" {
 31:   security_group_id = aws_security_group.alb.id
 32:   description       = "Public HTTP (redirect to HTTPS)"
 33:   ip_protocol       = "tcp"
 34:   from_port         = local.alb_http_port
 35:   to_port           = local.alb_http_port
 36:   cidr_ipv4         = "0.0.0.0/0"
 37: }
 38: 
 39: resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
 40:   security_group_id            = aws_security_group.alb.id
 41:   description                  = "ALB to app tier"
 42:   ip_protocol                  = "tcp"
 43:   from_port                    = local.app_port
 44:   to_port                      = local.app_port
 45:   referenced_security_group_id = aws_security_group.app.id
 46: }
 47: 
 48: # ----------------------------------------------------------------------------
 49: # App SG - private app tier
 50: # ----------------------------------------------------------------------------
 51: resource "aws_security_group" "app" {
 52:   name        = "${local.name_prefix}-app-sg"
 53:   description = "App tier. Accepts traffic from ALB SG only."
 54:   vpc_id      = module.vpc.vpc_id
 55:   tags        = merge(local.common_tags, { Name = "${local.name_prefix}-app-sg" })
 56: }
 57: 
 58: resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
 59:   security_group_id            = aws_security_group.app.id
 60:   description                  = "From ALB on 8080"
 61:   ip_protocol                  = "tcp"
 62:   from_port                    = local.app_port
 63:   to_port                      = local.app_port
 64:   referenced_security_group_id = aws_security_group.alb.id
 65: }
 66: 
 67: # Egress: HTTPS for ECR/AWS APIs, MySQL to RDS SG, NTP, package mirrors.
 68: resource "aws_vpc_security_group_egress_rule" "app_https" {
 69:   security_group_id = aws_security_group.app.id
 70:   description       = "HTTPS egress (AWS APIs via VPCE, package mirrors via NAT)"
 71:   ip_protocol       = "tcp"
 72:   from_port         = 443
 73:   to_port           = 443
 74:   cidr_ipv4         = "0.0.0.0/0"
 75: }
 76: 
 77: resource "aws_vpc_security_group_egress_rule" "app_http" {
 78:   security_group_id = aws_security_group.app.id
 79:   description       = "HTTP egress (apt mirrors, docker)"
 80:   ip_protocol       = "tcp"
 81:   from_port         = 80
 82:   to_port           = 80
 83:   cidr_ipv4         = "0.0.0.0/0"
 84: }
 85: 
 86: resource "aws_vpc_security_group_egress_rule" "app_dns_udp" {
 87:   security_group_id = aws_security_group.app.id
 88:   description       = "DNS"
 89:   ip_protocol       = "udp"
 90:   from_port         = 53
 91:   to_port           = 53
 92:   cidr_ipv4         = "0.0.0.0/0"
 93: }
 94: 
 95: resource "aws_vpc_security_group_egress_rule" "app_ntp" {
 96:   security_group_id = aws_security_group.app.id
 97:   description       = "NTP"
 98:   ip_protocol       = "udp"
 99:   from_port         = 123
100:   to_port           = 123
101:   cidr_ipv4         = "0.0.0.0/0"
102: }
103: 
104: resource "aws_vpc_security_group_egress_rule" "app_to_rds" {
105:   security_group_id            = aws_security_group.app.id
106:   description                  = "MySQL to RDS"
107:   ip_protocol                  = "tcp"
108:   from_port                    = local.db_port
109:   to_port                      = local.db_port
110:   referenced_security_group_id = aws_security_group.rds.id
111: }
112: 
113: # ----------------------------------------------------------------------------
114: # RDS SG - private DB tier
115: # ----------------------------------------------------------------------------
116: resource "aws_security_group" "rds" {
117:   name        = "${local.name_prefix}-rds-sg"
118:   description = "RDS MySQL. Accepts 3306 from app SG only."
119:   vpc_id      = module.vpc.vpc_id
120:   tags        = merge(local.common_tags, { Name = "${local.name_prefix}-rds-sg" })
121: }
122: 
123: resource "aws_vpc_security_group_ingress_rule" "rds_from_app" {
124:   security_group_id            = aws_security_group.rds.id
125:   description                  = "MySQL from app SG"
126:   ip_protocol                  = "tcp"
127:   from_port                    = local.db_port
128:   to_port                      = local.db_port
129:   referenced_security_group_id = aws_security_group.app.id
130: }
131: # RDS SG has no egress rules - DB doesn't initiate outbound traffic.
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
 24:     steps:
 25:       - uses: actions/checkout@v4
 26:       - uses: aws-actions/configure-aws-credentials@v4
 27:         with:
 28:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
 29:           aws-region: ${{ vars.AWS_REGION }}
 30:           role-session-name: gha-app-deploy
 31:       - id: tag
 32:         run: |
 33:           TAG="${{ github.event.inputs.image_tag }}"
 34:           if [ -z "$TAG" ]; then TAG="sha-${GITHUB_SHA::12}"; fi
 35:           echo "tag=$TAG" >> $GITHUB_OUTPUT
 36:       - uses: aws-actions/amazon-ecr-login@v2
 37:         id: ecr
 38:       - name: Resolve ECR repo URLs
 39:         id: repos
 40:         run: |
 41:           ACC="${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
 42:           REG="${{ vars.AWS_REGION }}"
 43:           echo "backend=$ACC.dkr.ecr.$REG.amazonaws.com/java-app/backend"   >> $GITHUB_OUTPUT
 44:           echo "frontend=$ACC.dkr.ecr.$REG.amazonaws.com/java-app/frontend" >> $GITHUB_OUTPUT
 45:       - name: Build + push backend
 46:         run: |
 47:           docker build -t ${{ steps.repos.outputs.backend }}:${{ steps.tag.outputs.tag }} app/backend
 48:           docker push ${{ steps.repos.outputs.backend }}:${{ steps.tag.outputs.tag }}
 49:       - name: Build + push frontend
 50:         run: |
 51:           docker build -t ${{ steps.repos.outputs.frontend }}:${{ steps.tag.outputs.tag }} app/frontend
 52:           docker push ${{ steps.repos.outputs.frontend }}:${{ steps.tag.outputs.tag }}
 53:       - name: Update SSM release params
 54:         run: |
 55:           aws ssm put-parameter --name "/java-app/prod/backend-image-tag"  --type String --overwrite --value "${{ steps.tag.outputs.tag }}"
 56:           aws ssm put-parameter --name "/java-app/prod/frontend-image-tag" --type String --overwrite --value "${{ steps.tag.outputs.tag }}"
 57:           aws ssm put-parameter --name "/java-app/prod/release-id"         --type String --overwrite --value "${{ github.sha }}"
 58:       - name: Resolve ASG name
 59:         id: asg
 60:         run: |
 61:           NAME=$(aws autoscaling describe-auto-scaling-groups \
 62:             --query "AutoScalingGroups[?Tags[?Key=='Project' && Value=='java-app'] && Tags[?Key=='Environment' && Value=='prod']].AutoScalingGroupName | [0]" \
 63:             --output text)
 64:           if [ "$NAME" = "None" ] || [ -z "$NAME" ]; then
 65:             # Fallback to deterministic name pattern
 66:             NAME="java-app-prod-asg"
 67:           fi
 68:           echo "name=$NAME" >> $GITHUB_OUTPUT
 69:       - name: Trigger ASG instance refresh
 70:         id: refresh
 71:         run: |
 72:           REFRESH_ID=$(aws autoscaling start-instance-refresh \
 73:             --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
 74:             --preferences '{"MinHealthyPercentage":100,"MaxHealthyPercentage":200,"InstanceWarmup":180,"AutoRollback":true}' \
 75:             --query 'InstanceRefreshId' --output text)
 76:           echo "id=$REFRESH_ID" >> $GITHUB_OUTPUT
 77:       - name: Wait for refresh to complete
 78:         run: |
 79:           set -e
 80:           for i in $(seq 1 90); do
 81:             S=$(aws autoscaling describe-instance-refreshes \
 82:               --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
 83:               --instance-refresh-ids "${{ steps.refresh.outputs.id }}" \
 84:               --query 'InstanceRefreshes[0].Status' --output text)
 85:             P=$(aws autoscaling describe-instance-refreshes \
 86:               --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
 87:               --instance-refresh-ids "${{ steps.refresh.outputs.id }}" \
 88:               --query 'InstanceRefreshes[0].PercentageComplete' --output text)
 89:             echo "refresh status=$S percent=$P"
 90:             case "$S" in
 91:               Successful) exit 0 ;;
 92:               Failed|Cancelled|RollbackFailed|RollbackSuccessful)
 93:                 echo "refresh ended with $S"; exit 1 ;;
 94:             esac
 95:             sleep 20
 96:           done
 97:           echo "timed out waiting for refresh"
 98:           exit 1
 99:       - name: Post-deploy smoke
100:         run: |
101:           for i in $(seq 1 30); do
102:             if curl -fsS --max-time 10 "https://java.talorlik.com/actuator/health" | grep -q '"status":"UP"'; then
103:               echo "smoke ok"; exit 0
104:             fi
105:             sleep 10
106:           done
107:           echo "smoke failed"; exit 1
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
 19: #
 20: # Run sparingly. The whole point of the bootstrap stack staying intact is
 21: # that the next `infra-apply` rebuilds the env without you re-creating the
 22: # state bucket.
 23: ###############################################################################
 24: name: infra-destroy
 25: on:
 26:   workflow_dispatch:
 27:     inputs:
 28:       confirm:
 29:         description: 'Type DESTROY (uppercase) to confirm'
 30:         required: true
 31:         default: ''
 32:       run_app_cleanup:
 33:         description: 'First run app-layer cleanup (recommended)'
 34:         type: boolean
 35:         required: false
 36:         default: true
 37: permissions:
 38:   id-token: write
 39:   contents: read
 40: concurrency:
 41:   group: infra-destroy
 42:   cancel-in-progress: false
 43: jobs:
 44:   destroy:
 45:     name: tear down infra
 46:     runs-on: ubuntu-latest
 47:     environment: prod
 48:     steps:
 49:       - name: Validate confirmation phrase
 50:         run: |
 51:           if [ "${{ github.event.inputs.confirm }}" != "DESTROY" ]; then
 52:             echo "::error::confirm input must be exactly 'DESTROY'."
 53:             exit 1
 54:           fi
 55:       - uses: actions/checkout@v4
 56:       - uses: aws-actions/configure-aws-credentials@v4
 57:         with:
 58:           role-to-assume: ${{ secrets.DEPLOYMENT_ROLE_ARN }}
 59:           aws-region: ${{ vars.AWS_REGION }}
 60:           role-session-name: gha-infra-destroy
 61:       - uses: hashicorp/setup-terraform@v3
 62:         with:
 63:           terraform_version: 1.9.8
 64:       # -------------------------------------------------------------------
 65:       # 2. App-layer cleanup (best-effort, idempotent).
 66:       # -------------------------------------------------------------------
 67:       - name: Resolve ASG name
 68:         if: ${{ github.event.inputs.run_app_cleanup == 'true' }}
 69:         id: asg
 70:         run: |
 71:           NAME=$(aws autoscaling describe-auto-scaling-groups \
 72:             --query "AutoScalingGroups[?Tags[?Key=='Project' && Value=='java-app'] && Tags[?Key=='Environment' && Value=='prod']].AutoScalingGroupName | [0]" \
 73:             --output text)
 74:           if [ "$NAME" = "None" ] || [ -z "$NAME" ]; then NAME="java-app-prod-asg"; fi
 75:           echo "name=$NAME" >> "$GITHUB_OUTPUT"
 76:       - name: Scale ASG to 0
 77:         if: ${{ github.event.inputs.run_app_cleanup == 'true' }}
 78:         run: |
 79:           aws autoscaling update-auto-scaling-group \
 80:             --auto-scaling-group-name "${{ steps.asg.outputs.name }}" \
 81:             --min-size 0 --desired-capacity 0 --max-size 0 || true
 82:           for i in $(seq 1 60); do
 83:             COUNT=$(aws autoscaling describe-auto-scaling-groups \
 84:               --auto-scaling-group-names "${{ steps.asg.outputs.name }}" \
 85:               --query "AutoScalingGroups[0].Instances | length(@)" \
 86:               --output text 2>/dev/null || echo "0")
 87:             echo "in-service instances: $COUNT"
 88:             if [ "$COUNT" = "0" ]; then break; fi
 89:             sleep 15
 90:           done
 91:       - name: Purge ECR images
 92:         if: ${{ github.event.inputs.run_app_cleanup == 'true' }}
 93:         run: |
 94:           for repo in java-app/backend java-app/frontend; do
 95:             IDS=$(aws ecr list-images --repository-name "$repo" --query 'imageIds[*]' --output json 2>/dev/null || echo "[]")
 96:             COUNT=$(echo "$IDS" | jq 'length')
 97:             if [ "$COUNT" -gt 0 ]; then
 98:               echo "$IDS" | jq -c '. as $a | range(0; ($a | length); 100) | $a[.:.+100]' | \
 99:                 while read -r CHUNK; do
100:                   aws ecr batch-delete-image --repository-name "$repo" --image-ids "$CHUNK" || true
101:                 done
102:             fi
103:           done
104:       # -------------------------------------------------------------------
105:       # 3. Stop ALB from writing new logs, then disable deletion protection,
106:       #    then empty buckets that TF refuses to remove (versioned).
107:       # -------------------------------------------------------------------
108:       - name: Disable ALB access logs and deletion protection
109:         run: |
110:           set -euo pipefail
111:           ARN=$(aws elbv2 describe-load-balancers \
112:             --query "LoadBalancers[?starts_with(LoadBalancerName, 'java-app-prod-alb')].LoadBalancerArn | [0]" \
113:             --output text)
114:           if [ -n "$ARN" ] && [ "$ARN" != "None" ]; then
115:             aws elbv2 modify-load-balancer-attributes \
116:               --load-balancer-arn "$ARN" \
117:               --attributes Key=access_logs.s3.enabled,Value=false \
118:                            Key=deletion_protection.enabled,Value=false
119:           else
120:             echo "no ALB found - it may already be gone"
121:           fi
122:       - name: Empty ALB log bucket
123:         run: |
124:           set -euo pipefail
125:           B="java-app-prod-alb-logs-${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
126:           if ! aws s3api head-bucket --bucket "$B" 2>/dev/null; then
127:             echo "bucket $B not present, skipping"
128:             exit 0
129:           fi
130:           # Paginate, build full delete payload in one jq call, stop when empty.
131:           while :; do
132:             PAYLOAD=$(aws s3api list-object-versions \
133:                         --bucket "$B" --max-items 900 --output json 2>/dev/null \
134:                       | jq -c '{Objects: [((.Versions // [])[]),
135:                                           ((.DeleteMarkers // [])[])
136:                                           | {Key, VersionId}],
137:                                Quiet: true}')
138:             COUNT=$(printf '%s' "$PAYLOAD" | jq '.Objects | length')
139:             [ "$COUNT" -eq 0 ] && break
140:             aws s3api delete-objects --bucket "$B" --delete "$PAYLOAD"
141:           done
142:       - name: Empty config (compose) bucket
143:         run: |
144:           set -euo pipefail
145:           B="java-app-prod-config-${{ vars.DEPLOYMENT_ACCOUNT_ID }}"
146:           if ! aws s3api head-bucket --bucket "$B" 2>/dev/null; then
147:             echo "bucket $B not present, skipping"
148:             exit 0
149:           fi
150:           while :; do
151:             PAYLOAD=$(aws s3api list-object-versions \
152:                         --bucket "$B" --max-items 900 --output json 2>/dev/null \
153:                       | jq -c '{Objects: [((.Versions // [])[]),
154:                                           ((.DeleteMarkers // [])[])
155:                                           | {Key, VersionId}],
156:                                Quiet: true}')
157:             COUNT=$(printf '%s' "$PAYLOAD" | jq '.Objects | length')
158:             [ "$COUNT" -eq 0 ] && break
159:             aws s3api delete-objects --bucket "$B" --delete "$PAYLOAD"
160:           done
161:       # -------------------------------------------------------------------
162:       # 5. Terraform init, then state surgery + RDS prep, then destroy.
163:       # -------------------------------------------------------------------
164:       - name: terraform init
165:         working-directory: infra/envs/prod
166:         run: |
167:           terraform init \
168:             -backend-config="bucket=java-app-tfstate-${{ vars.DEPLOYMENT_ACCOUNT_ID }}-${{ vars.AWS_REGION }}" \
169:             -backend-config="region=${{ vars.AWS_REGION }}"
170:       # Detach service-linked roles from state. They are account-wide and
171:       # AWS recreates them automatically on next ALB / ASG creation; deleting
172:       # them here is unsafe and racy with ALB destroy.
173:       - name: Detach service-linked roles from state
174:         working-directory: infra/envs/prod
175:         run: |
176:           set -euo pipefail
177:           for ADDR in \
178:               aws_iam_service_linked_role.elb \
179:               aws_iam_service_linked_role.autoscaling; do
180:             if terraform state list | grep -qx "$ADDR"; then
181:               terraform state rm "$ADDR"
182:             else
183:               echo "$ADDR not in state, skipping"
184:             fi
185:           done
186:       # Disable RDS deletion protection imperatively, let any in-flight
187:       # modify settle, and purge orphan retained automated backups left
188:       # from prior failed destroys (those pin the parameter group's KMS
189:       # key and bloat backup quota).
190:       - name: Prepare RDS for destroy
191:         run: |
192:           set -euo pipefail
193:           DBI="java-app-prod-mysql"
194:           if aws rds describe-db-instances --db-instance-identifier "$DBI" >/dev/null 2>&1; then
195:             aws rds modify-db-instance \
196:               --db-instance-identifier "$DBI" \
197:               --no-deletion-protection \
198:               --apply-immediately >/dev/null
199:             # Wait up to ~30 min for available; ignore terminal failures.
200:             aws rds wait db-instance-available \
201:               --db-instance-identifier "$DBI" || true
202:           else
203:             echo "RDS instance $DBI not present"
204:           fi
205:           # Purge any retained automated backups for this DBI. delete_automated_backups
206:           # only fires inside DeleteDBInstance; orphans from earlier runs need this.
207:           aws rds describe-db-instance-automated-backups \
208:             --query "DBInstanceAutomatedBackups[?DBInstanceIdentifier=='$DBI'].DBInstanceAutomatedBackupsArn" \
209:             --output text | tr '\t' '\n' | while read -r ARN; do
210:               [ -z "$ARN" ] && continue
211:               echo "deleting orphan automated backup $ARN"
212:               aws rds delete-db-instance-automated-backup \
213:                 --db-instance-automated-backups-arn "$ARN" || true
214:             done
215:       - name: terraform destroy
216:         working-directory: infra/envs/prod
217:         env:
218:           TF_VAR_aws_region: ${{ vars.AWS_REGION }}
219:           TF_VAR_deployment_account_id: ${{ vars.DEPLOYMENT_ACCOUNT_ID }}
220:           TF_VAR_domain_account_id: ${{ vars.DOMAIN_ACCOUNT_ID }}
221:           TF_VAR_domain_account_route53_role_arn: ${{ secrets.DOMAIN_ROUTE53_ROLE_ARN }}
222:           TF_VAR_hosted_zone_id: ${{ vars.HOSTED_ZONE_ID }}
223:           TF_VAR_acm_certificate_arn: ${{ secrets.ACM_CERTIFICATE_ARN }}
224:           TF_VAR_rds_deletion_protection: "false"
225:           TF_VAR_rds_skip_final_snapshot: "true"
226:           TF_VAR_rds_delete_automated_backups: "true"
227:           TF_VAR_alb_logs_force_destroy: "true"
228:         run: |
229:           terraform destroy -input=false -auto-approve
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
 16:   name              = "/${var.project}/${var.environment}/app"
 17:   retention_in_days = var.log_retention_days
 18:   kms_key_id        = aws_kms_key.app_secrets.arn
 19:   tags              = local.common_tags
 20: }
 21: 
 22: resource "aws_ssm_parameter" "log_group_app" {
 23:   name  = local.ssm_keys.log_group_app
 24:   type  = "String"
 25:   value = aws_cloudwatch_log_group.app.name
 26: }
 27: 
 28: # ----------------------------------------------------------------------------
 29: # User-data script
 30: #
 31: # Renders a templated bash script that installs Docker + Compose + CloudWatch
 32: # Agent, fetches release metadata from SSM and the compose file from S3,
 33: # performs ECR auth, then `docker compose up -d`.
 34: # ----------------------------------------------------------------------------
 35: locals {
 36:   user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tpl", {
 37:     aws_region         = var.aws_region
 38:     ssm_compose_object = local.ssm_keys.compose_object
 39:     ssm_backend_tag    = local.ssm_keys.backend_image_tag
 40:     ssm_frontend_tag   = local.ssm_keys.frontend_image_tag
 41:     ssm_release_id     = local.ssm_keys.release_id
 42:     ssm_db_endpoint    = local.ssm_keys.db_endpoint
 43:     ssm_db_name        = local.ssm_keys.db_name
 44:     secret_db_app_user = aws_secretsmanager_secret.db_app_user.name
 45:     secret_admin       = aws_secretsmanager_secret.admin.name
 46:     secret_jwt         = aws_secretsmanager_secret.jwt.name
 47:     secret_ses         = aws_secretsmanager_secret.ses.name
 48:     backend_repo_url   = aws_ecr_repository.this["backend"].repository_url
 49:     frontend_repo_url  = aws_ecr_repository.this["frontend"].repository_url
 50:     log_group_name     = aws_cloudwatch_log_group.app.name
 51:     deployment_account = var.deployment_account_id
 52:     app_subdomain      = var.app_subdomain
 53:   }))
 54: }
 55: 
 56: # ----------------------------------------------------------------------------
 57: # Launch Template + ASG
 58: # ----------------------------------------------------------------------------
 59: module "asg" {
 60:   source  = "terraform-aws-modules/autoscaling/aws"
 61:   version = "~> 7.7"
 62: 
 63:   name = "${local.name_prefix}-asg"
 64: 
 65:   min_size            = var.asg_min_size
 66:   desired_capacity    = var.asg_desired_capacity
 67:   max_size            = var.asg_max_size
 68:   vpc_zone_identifier = module.vpc.private_subnets
 69:   health_check_type   = "ELB"
 70: 
 71:   # First boot on a fresh Ubuntu image runs apt + AWS CLI v2 install + CWA
 72:   # install + ECR pull + Spring Boot startup. On t3.small with cold caches
 73:   # this regularly takes 4-7 min. 300s grace was racing the slowest path
 74:   # and producing one unhealthy instance per refresh; 600s gives Spring
 75:   # Boot plus the actuator probe enough headroom.
 76:   health_check_grace_period = 600
 77: 
 78:   # Attach to ALB target group created in alb.tf.
 79:   target_group_arns = [module.alb.target_groups["app"].arn]
 80: 
 81:   # Launch Template
 82:   create_launch_template = true
 83:   launch_template_name   = "${local.name_prefix}-lt"
 84:   update_default_version = true
 85: 
 86:   image_id      = data.aws_ssm_parameter.ubuntu_ami.value
 87:   instance_type = var.instance_type
 88:   user_data     = local.user_data
 89: 
 90:   iam_instance_profile_name = aws_iam_instance_profile.app.name
 91: 
 92:   security_groups = [aws_security_group.app.id]
 93: 
 94:   metadata_options = {
 95:     http_endpoint               = "enabled"
 96:     http_tokens                 = "required" # IMDSv2 required
 97:     http_put_response_hop_limit = 2          # 2 = container-friendly (Docker bridge)
 98:     instance_metadata_tags      = "enabled"
 99:   }
100: 
101:   block_device_mappings = [
102:     {
103:       device_name = "/dev/sda1"
104:       ebs = {
105:         volume_size           = 30
106:         volume_type           = "gp3"
107:         encrypted             = true
108:         delete_on_termination = true
109:       }
110:     }
111:   ]
112: 
113:   tag_specifications = [
114:     {
115:       resource_type = "instance"
116:       tags          = merge(local.common_tags, { Name = "${local.name_prefix}-app" })
117:     },
118:     {
119:       resource_type = "volume"
120:       tags          = local.common_tags
121:     }
122:   ]
123: 
124:   # Target tracking on ALB request count per target.
125:   scaling_policies = {
126:     request_count = {
127:       policy_type = "TargetTrackingScaling"
128:       target_tracking_configuration = {
129:         predefined_metric_specification = {
130:           predefined_metric_type = "ALBRequestCountPerTarget"
131:           resource_label         = "${module.alb.arn_suffix}/${module.alb.target_groups["app"].arn_suffix}"
132:         }
133:         target_value = 200
134:       }
135:     }
136:     cpu = {
137:       policy_type = "TargetTrackingScaling"
138:       target_tracking_configuration = {
139:         predefined_metric_specification = {
140:           predefined_metric_type = "ASGAverageCPUUtilization"
141:         }
142:         target_value = 60
143:       }
144:     }
145:   }
146: 
147:   # Instance refresh: launch-before-terminate posture (min_healthy=100).
148:   instance_refresh = {
149:     strategy = "Rolling"
150:     preferences = {
151:       min_healthy_percentage = 100
152:       max_healthy_percentage = 200
153:       # Match health_check_grace_period; warmup of 180s undercounts a cold
154:       # boot and starts pre-tracking metrics on a not-yet-ready instance.
155:       instance_warmup = 300
156:       auto_rollback   = true
157:     }
158:     triggers = ["tag"]
159:   }
160: 
161:   enabled_metrics = [
162:     "GroupInServiceInstances",
163:     "GroupDesiredCapacity",
164:     "GroupTotalInstances",
165:     "GroupPendingInstances",
166:     "GroupTerminatingInstances",
167:   ]
168: 
169:   tags = local.common_tags
170: 
171:   depends_on = [
172:     aws_iam_service_linked_role.autoscaling,
173:     aws_iam_service_linked_role.elb,
174:   ]
175: }
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
 48: data "aws_iam_policy_document" "app_inline" {
 49:   # Secrets Manager read for known ARNs.
 50:   statement {
 51:     sid    = "ReadAppSecrets"
 52:     effect = "Allow"
 53:     actions = [
 54:       "secretsmanager:GetSecretValue",
 55:       "secretsmanager:DescribeSecret",
 56:     ]
 57:     resources = [
 58:       aws_secretsmanager_secret.db_app_user.arn,
 59:       aws_secretsmanager_secret.admin.arn,
 60:       aws_secretsmanager_secret.jwt.arn,
 61:       aws_secretsmanager_secret.ses.arn,
 62:       module.rds.db_instance_master_user_secret_arn,
 63:     ]
 64:   }
 65: 
 66:   # SSM Parameter Store reads under the project namespace.
 67:   statement {
 68:     sid    = "ReadAppSsmParams"
 69:     effect = "Allow"
 70:     actions = [
 71:       "ssm:GetParameter",
 72:       "ssm:GetParameters",
 73:       "ssm:GetParametersByPath",
 74:     ]
 75:     resources = ["arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${var.deployment_account_id}:parameter${local.secret_prefix}/*"]
 76:   }
 77: 
 78:   # KMS decrypt for the secrets/parameters CMK.
 79:   statement {
 80:     sid       = "DecryptAppCmk"
 81:     effect    = "Allow"
 82:     actions   = ["kms:Decrypt", "kms:DescribeKey"]
 83:     resources = [aws_kms_key.app_secrets.arn]
 84:   }
 85: 
 86:   # CloudWatch Logs PutLog from app + Docker.
 87:   statement {
 88:     sid    = "PutCloudWatchLogs"
 89:     effect = "Allow"
 90:     actions = [
 91:       "logs:CreateLogGroup",
 92:       "logs:CreateLogStream",
 93:       "logs:PutLogEvents",
 94:       "logs:DescribeLogStreams",
 95:       "logs:DescribeLogGroups",
 96:     ]
 97:     resources = ["*"]
 98:   }
 99: 
100:   # SES: send only from the approved identity.
101:   statement {
102:     sid    = "SesSendFromApprovedIdentity"
103:     effect = "Allow"
104:     actions = [
105:       "ses:SendEmail",
106:       "ses:SendRawEmail",
107:     ]
108:     resources = [
109:       "arn:${data.aws_partition.current.partition}:ses:${var.aws_region}:${var.deployment_account_id}:identity/${var.ses_sender_subdomain}",
110:     ]
111:   }
112: 
113:   # ECR: GetAuthorizationToken is account-scoped (must be *).
114:   statement {
115:     sid       = "EcrAuth"
116:     effect    = "Allow"
117:     actions   = ["ecr:GetAuthorizationToken"]
118:     resources = ["*"]
119:   }
120: 
121:   # Allow the user-data boot script to mark its own instance Unhealthy if
122:   # the actuator never returns UP within the boot deadline. Without this
123:   # the box would linger as a black hole behind the ALB until the grace
124:   # period expires; with it the ASG replaces it immediately.
125:   # SetInstanceHealth has no resource-level scoping in IAM, so this must
126:   # be Resource:* and is gated by the aws:SourceArn condition matching the
127:   # caller's own instance ARN, scoping it in practice to instances of THIS
128:   # ASG even if the role were ever reused elsewhere.
129:   statement {
130:     sid       = "SelfMarkInstanceUnhealthy"
131:     effect    = "Allow"
132:     actions   = ["autoscaling:SetInstanceHealth"]
133:     resources = ["*"]
134:   }
135: }
136: 
137: resource "aws_iam_policy" "app_inline" {
138:   name   = "${local.name_prefix}-app-inline"
139:   policy = data.aws_iam_policy_document.app_inline.json
140: }
141: 
142: resource "aws_iam_role_policy_attachment" "app_inline" {
143:   role       = aws_iam_role.app_instance.name
144:   policy_arn = aws_iam_policy.app_inline.arn
145: }
146: 
147: resource "aws_iam_instance_profile" "app" {
148:   name = "${local.name_prefix}-app-instance"
149:   role = aws_iam_role.app_instance.name
150: }
151: 
152: ###############################################################################
153: # AWS Service-Linked Roles
154: #
155: # EC2 Auto Scaling and Elastic Load Balancing both rely on account-scoped
156: # SLRs. AWS auto-creates them on first use, but the first-use creation can
157: # race against ASG capacity validation, producing
158: # "Access denied when attempting to assume role
159: #  .../AWSServiceRoleForAutoScaling" errors.
160: #
161: # Managing them in Terraform with import blocks makes the dependency explicit
162: # and idempotent across both fresh accounts and accounts where the SLRs
163: # already exist (Terraform 1.5+ import blocks).
164: ###############################################################################
165: 
166: resource "aws_iam_service_linked_role" "autoscaling" {
167:   aws_service_name = "autoscaling.amazonaws.com"
168:   description      = "Default SLR for EC2 Auto Scaling"
169:   lifecycle {
170:     # Description is AWS-managed; ignore drift so Terraform never tries to
171:     # rewrite it.
172:     ignore_changes = [description]
173:   }
174: }
175: 
176: resource "aws_iam_service_linked_role" "elb" {
177:   aws_service_name = "elasticloadbalancing.amazonaws.com"
178:   description      = "Default SLR for Elastic Load Balancing"
179:   lifecycle {
180:     ignore_changes = [description]
181:   }
182: }
183: 
184: # If the SLRs already exist in the account, Terraform imports them on the
185: # next plan/apply rather than failing with "service role name has been
186: # taken". If the SLRs do NOT exist (brand-new account), comment out these
187: # import blocks before applying - Terraform will then create them.
188: import {
189:   to = aws_iam_service_linked_role.autoscaling
190:   id = "arn:${data.aws_partition.current.partition}:iam::${var.deployment_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
191: }
192: 
193: import {
194:   to = aws_iam_service_linked_role.elb
195:   id = "arn:${data.aws_partition.current.partition}:iam::${var.deployment_account_id}:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing"
196: }
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
143:   description = "RDS MySQL engine version. 8.0 lets RDS choose the latest 8.0.x."
144:   type        = string
145:   default     = "8.0"
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
201:   type    = number
202:   default = 30
203: }
204: 
205: # ----------------------------------------------------------------------------
206: # WAF
207: # ----------------------------------------------------------------------------
208: variable "enable_waf" {
209:   type    = bool
210:   default = true
211: }
212: 
213: # ----------------------------------------------------------------------------
214: # Destroy-time overrides
215: #
216: # Kept safe by default. The infra-destroy workflow flips these via TF_VAR_* so
217: # that a single `terraform destroy` can tear the env down without manual
218: # pre-steps. Do not flip them in normal apply runs.
219: # ----------------------------------------------------------------------------
220: variable "rds_deletion_protection" {
221:   description = "Whether RDS deletion protection is enabled. Override to false at destroy time."
222:   type        = bool
223:   default     = true
224: }
225: 
226: variable "rds_skip_final_snapshot" {
227:   description = "Skip the RDS final snapshot at destroy time. Override to true at destroy time."
228:   type        = bool
229:   default     = false
230: }
231: 
232: variable "alb_logs_force_destroy" {
233:   description = "Force-destroy the ALB log bucket even if non-empty. Override to true at destroy time."
234:   type        = bool
235:   default     = false
236: }
237: 
238: variable "rds_delete_automated_backups" {
239:   description = "Delete retained automated backups when the instance is destroyed. Override to true at destroy time."
240:   type        = bool
241:   default     = false
242: }
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
45: .cowork/
46: 
47: # Frontend / node
48: node_modules/
49: dist/
50: .next/
51: .nuxt/
52: .cache/
53: .parcel-cache/
54: playwright-report/
55: test-results/
56: 
57: # Terraform
58: .terraform/
59: .terraform.lock.hcl
60: *.tfstate
61: *.tfstate.*
62: *.tfplan
63: crash.log
64: 
65: # Env / secrets
66: .env
67: .env.*
68: !.env.example
69: *.pem
70: *.key
71: 
72: # OS
73: .DS_Store
74: Thumbs.db
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
 12:   backend:
 13:     name: backend tests
 14:     runs-on: ubuntu-latest
 15:     steps:
 16:       - uses: actions/checkout@v4
 17:       - uses: actions/setup-java@v4
 18:         with:
 19:           distribution: temurin
 20:           java-version: "21"
 21:           cache: maven
 22:       - name: Backend unit + integration tests (Testcontainers MySQL)
 23:         working-directory: app/backend
 24:         run: mvn -B -ntp verify
 25:       - name: Upload surefire reports
 26:         if: always()
 27:         uses: actions/upload-artifact@v4
 28:         with:
 29:           name: backend-test-reports
 30:           path: |
 31:             app/backend/target/surefire-reports/**
 32:             app/backend/target/failsafe-reports/**
 33:   frontend:
 34:     name: frontend lint/build (no-op for vanilla JS)
 35:     runs-on: ubuntu-latest
 36:     steps:
 37:       - uses: actions/checkout@v4
 38:       - name: Sanity check static assets
 39:         run: |
 40:           test -f app/frontend/src/index.html
 41:           test -f app/frontend/nginx.conf
 42:   compose-smoke:
 43:     name: docker compose smoke + playwright
 44:     runs-on: ubuntu-latest
 45:     needs: [backend, frontend]
 46:     steps:
 47:       - uses: actions/checkout@v4
 48:       - name: Build images and start compose stack
 49:         working-directory: app/docker
 50:         run: |
 51:           docker compose -f docker-compose.local.yml build
 52:           docker compose -f docker-compose.local.yml up -d
 53:           docker compose -f docker-compose.local.yml ps
 54:       - name: Wait for backend health
 55:         run: |
 56:           for i in $(seq 1 60); do
 57:             if curl -fsS http://localhost:8080/actuator/health; then
 58:               echo
 59:               echo "backend ready"
 60:               exit 0
 61:             fi
 62:             sleep 5
 63:           done
 64:           echo "backend never became healthy"
 65:           docker compose -f app/docker/docker-compose.local.yml logs --no-color || true
 66:           exit 1
 67:       - name: Setup Node + Playwright
 68:         uses: actions/setup-node@v4
 69:         with:
 70:           node-version: "24"
 71:       - name: Install + run Playwright
 72:         working-directory: tests/e2e
 73:         env:
 74:           E2E_BASE_URL: http://localhost:8080
 75:         run: |
 76:           npm install
 77:           npx playwright install --with-deps chromium
 78:           npm run test:ci
 79:       - name: Compose logs (always)
 80:         if: always()
 81:         working-directory: app/docker
 82:         run: docker compose -f docker-compose.local.yml logs --no-color || true
 83:       - name: Compose down
 84:         if: always()
 85:         working-directory: app/docker
 86:         run: docker compose -f docker-compose.local.yml down -v
 87:       - name: Upload Playwright report
 88:         if: always()
 89:         uses: actions/upload-artifact@v4
 90:         with:
 91:           name: playwright-report
 92:           path: tests/e2e/playwright-report
 93:   iac-checks:
 94:     name: terraform fmt/validate + tflint + checkov
 95:     runs-on: ubuntu-latest
 96:     steps:
 97:       - uses: actions/checkout@v4
 98:       - uses: hashicorp/setup-terraform@v3
 99:         with:
100:           terraform_version: 1.9.8
101:       - name: terraform fmt
102:         run: terraform fmt -check -recursive infra
103:       - name: validate bootstrap
104:         working-directory: infra/bootstrap
105:         run: terraform init -backend=false && terraform validate
106:       - name: validate prod
107:         working-directory: infra/envs/prod
108:         run: terraform init -backend=false && terraform validate
109:       - uses: terraform-linters/setup-tflint@v4
110:         with: { tflint_version: latest }
111:       - run: tflint --init && tflint --recursive
112:       - name: checkov
113:         uses: bridgecrewio/checkov-action@master
114:         with:
115:           directory: infra
116:           framework: terraform
117:           soft_fail: true
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
 30:   bucket        = "${local.name_prefix}-alb-logs-${var.deployment_account_id}"
 31:   force_destroy = var.alb_logs_force_destroy
 32:   tags          = local.common_tags
 33: }
 34: 
 35: resource "aws_s3_bucket_public_access_block" "alb_logs" {
 36:   bucket                  = aws_s3_bucket.alb_logs.id
 37:   block_public_acls       = true
 38:   block_public_policy     = true
 39:   ignore_public_acls      = true
 40:   restrict_public_buckets = true
 41: }
 42: 
 43: resource "aws_s3_bucket_ownership_controls" "alb_logs" {
 44:   bucket = aws_s3_bucket.alb_logs.id
 45:   rule {
 46:     object_ownership = "BucketOwnerEnforced"
 47:   }
 48: }
 49: 
 50: resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
 51:   bucket = aws_s3_bucket.alb_logs.id
 52:   rule {
 53:     # ALB log delivery requires SSE-S3 (AES256), not SSE-KMS, for older
 54:     # account-id-based grant; keep AES256 for compatibility.
 55:     apply_server_side_encryption_by_default {
 56:       sse_algorithm = "AES256"
 57:     }
 58:   }
 59: }
 60: 
 61: resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
 62:   bucket = aws_s3_bucket.alb_logs.id
 63:   rule {
 64:     id     = "expire"
 65:     status = "Enabled"
 66: 
 67:     # Empty filter = applies to all objects (required by aws provider 5.x).
 68:     filter {}
 69: 
 70:     expiration {
 71:       days = 90
 72:     }
 73: 
 74:     abort_incomplete_multipart_upload {
 75:       days_after_initiation = 7
 76:     }
 77:   }
 78: }
 79: 
 80: data "aws_iam_policy_document" "alb_logs" {
 81:   # Legacy regions (incl. us-east-1): writes come from the per-region ELB
 82:   # AWS-owned account. Source: AWS docs - "Enable access logs for your
 83:   # Application Load Balancer".
 84:   statement {
 85:     sid       = "AllowELBAccountPutObject"
 86:     effect    = "Allow"
 87:     actions   = ["s3:PutObject"]
 88:     resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${var.deployment_account_id}/*"]
 89:     principals {
 90:       type        = "AWS"
 91:       identifiers = ["arn:${data.aws_partition.current.partition}:iam::${local.elb_log_account_id}:root"]
 92:     }
 93:   }
 94: 
 95:   # Newer regions / future-proofing: writes come from the ELB log-delivery
 96:   # service principal. Harmless in legacy regions.
 97:   statement {
 98:     sid       = "AllowELBLogDeliveryServicePut"
 99:     effect    = "Allow"
100:     actions   = ["s3:PutObject"]
101:     resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${var.deployment_account_id}/*"]
102:     principals {
103:       type        = "Service"
104:       identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
105:     }
106:   }
107: 
108:   statement {
109:     sid       = "AllowELBLogDeliveryServiceGetAcl"
110:     effect    = "Allow"
111:     actions   = ["s3:GetBucketAcl"]
112:     resources = [aws_s3_bucket.alb_logs.arn]
113:     principals {
114:       type        = "Service"
115:       identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
116:     }
117:   }
118: 
119:   statement {
120:     sid       = "DenyInsecureTransport"
121:     effect    = "Deny"
122:     actions   = ["s3:*"]
123:     resources = [aws_s3_bucket.alb_logs.arn, "${aws_s3_bucket.alb_logs.arn}/*"]
124:     principals {
125:       type        = "*"
126:       identifiers = ["*"]
127:     }
128:     condition {
129:       test     = "Bool"
130:       variable = "aws:SecureTransport"
131:       values   = ["false"]
132:     }
133:   }
134: }
135: 
136: resource "aws_s3_bucket_policy" "alb_logs" {
137:   bucket = aws_s3_bucket.alb_logs.id
138:   policy = data.aws_iam_policy_document.alb_logs.json
139: }
140: 
141: # ----------------------------------------------------------------------------
142: # ALB
143: # ----------------------------------------------------------------------------
144: module "alb" {
145:   source  = "terraform-aws-modules/alb/aws"
146:   version = "~> 9.10"
147: 
148:   name               = "${local.name_prefix}-alb"
149:   load_balancer_type = "application"
150: 
151:   vpc_id          = module.vpc.vpc_id
152:   subnets         = module.vpc.public_subnets
153:   security_groups = [aws_security_group.alb.id]
154: 
155:   enable_deletion_protection = true
156:   drop_invalid_header_fields = true
157:   idle_timeout               = 60
158: 
159:   access_logs = {
160:     bucket  = aws_s3_bucket.alb_logs.id
161:     enabled = true
162:     # No prefix - keeps bucket-policy resource path simple as
163:     # bucket-arn/AWSLogs/<account>/*. If you reintroduce a prefix here,
164:     # you must add the same prefix to the s3:PutObject Resource list in
165:     # data "aws_iam_policy_document" "alb_logs".
166:   }
167: 
168:   listeners = {
169:     # Public HTTPS - terminates TLS using the wildcard ACM cert and forwards
170:     # to the app target group on HTTP/8080.
171:     https = {
172:       port            = local.alb_https_port
173:       protocol        = "HTTPS"
174:       ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
175:       certificate_arn = var.acm_certificate_arn
176: 
177:       forward = {
178:         target_group_key = "app"
179:       }
180:     }
181: 
182:     # Public HTTP - 301 redirect to HTTPS so users typing
183:     # http://java.talorlik.com land on the secure URL automatically.
184:     http_redirect = {
185:       port     = local.alb_http_port
186:       protocol = "HTTP"
187: 
188:       redirect = {
189:         port        = tostring(local.alb_https_port)
190:         protocol    = "HTTPS"
191:         status_code = "HTTP_301"
192:       }
193:     }
194:   }
195: 
196:   # Ensure the ELB SLR is in place before creating the ALB.
197:   depends_on = [aws_iam_service_linked_role.elb]
198: 
199:   target_groups = {
200:     app = {
201:       name                 = "${local.name_prefix}-tg"
202:       backend_protocol     = "HTTP"
203:       backend_port         = local.app_port
204:       target_type          = "instance"
205:       deregistration_delay = 30
206:       protocol_version     = "HTTP1"
207: 
208:       # Don't auto-register - the ASG handles target registration.
209:       create_attachment = false
210: 
211:       health_check = {
212:         enabled             = true
213:         path                = "/actuator/health"
214:         protocol            = "HTTP"
215:         port                = "traffic-port"
216:         matcher             = "200"
217:         healthy_threshold   = 2
218:         unhealthy_threshold = 3
219:         interval            = 15
220:         timeout             = 5
221:       }
222: 
223:       stickiness = {
224:         enabled = false
225:         type    = "lb_cookie"
226:       }
227:     }
228:   }
229: 
230:   tags = local.common_tags
231: }
````

## File: infra/envs/prod/rds.tf
````hcl
  1: ###############################################################################
  2: # RDS MySQL (private, Multi-AZ, encrypted)
  3: #
  4: # - Master password managed by RDS in Secrets Manager (rotated by AWS).
  5: # - App user is created by Flyway with credentials from Secrets Manager.
  6: # - Backups, deletion protection, performance insights, and slow-query logs
  7: #   are enabled per TR-DB-001..008.
  8: ###############################################################################
  9: 
 10: resource "aws_db_parameter_group" "mysql" {
 11:   name        = "${local.name_prefix}-mysql8"
 12:   family      = "mysql8.0"
 13:   description = "Custom MySQL 8.0 parameter group"
 14: 
 15:   # UTF-8 across the board
 16:   parameter {
 17:     name  = "character_set_server"
 18:     value = "utf8mb4"
 19:   }
 20:   parameter {
 21:     name  = "collation_server"
 22:     value = "utf8mb4_0900_ai_ci"
 23:   }
 24: 
 25:   # Slow query logging
 26:   parameter {
 27:     name         = "slow_query_log"
 28:     value        = "1"
 29:     apply_method = "immediate"
 30:   }
 31:   parameter {
 32:     name         = "long_query_time"
 33:     value        = "1"
 34:     apply_method = "immediate"
 35:   }
 36:   parameter {
 37:     name         = "log_output"
 38:     value        = "FILE"
 39:     apply_method = "immediate"
 40:   }
 41: 
 42:   # Connection sizing - tune as load grows
 43:   parameter {
 44:     name         = "max_connections"
 45:     value        = "200"
 46:     apply_method = "pending-reboot"
 47:   }
 48: 
 49:   tags = local.common_tags
 50: }
 51: 
 52: module "rds" {
 53:   source  = "terraform-aws-modules/rds/aws"
 54:   version = "~> 6.10"
 55: 
 56:   identifier = "${local.name_prefix}-mysql"
 57: 
 58:   engine               = "mysql"
 59:   engine_version       = var.rds_engine_version
 60:   family               = "mysql8.0"
 61:   major_engine_version = "8.0"
 62:   instance_class       = var.rds_instance_class
 63: 
 64:   allocated_storage     = var.rds_allocated_storage_gb
 65:   max_allocated_storage = var.rds_max_allocated_storage_gb
 66:   storage_type          = "gp3"
 67:   storage_encrypted     = true
 68:   kms_key_id            = aws_kms_key.app_secrets.arn
 69: 
 70:   db_name  = var.db_name
 71:   username = "dbadmin" # master user; password is RDS-managed below
 72:   port     = local.db_port
 73: 
 74:   # RDS-managed master password in Secrets Manager (rotated by AWS).
 75:   manage_master_user_password             = true
 76:   master_user_secret_kms_key_id           = aws_kms_key.app_secrets.arn
 77:   master_user_password_rotate_immediately = false
 78: 
 79:   multi_az               = true
 80:   publicly_accessible    = false
 81:   vpc_security_group_ids = [aws_security_group.rds.id]
 82:   db_subnet_group_name   = module.vpc.database_subnet_group_name
 83: 
 84:   backup_retention_period          = 14
 85:   backup_window                    = "03:00-04:00"
 86:   maintenance_window               = "Sun:04:30-Sun:05:30"
 87:   deletion_protection              = var.rds_deletion_protection
 88:   delete_automated_backups         = var.rds_delete_automated_backups
 89:   skip_final_snapshot              = var.rds_skip_final_snapshot
 90:   final_snapshot_identifier_prefix = "${local.name_prefix}-mysql-final"
 91: 
 92:   # Use the AWS-managed default option group. Custom option groups are the
 93:   # only kind that can wedge a destroy via retained snapshots/backups; we
 94:   # have no MySQL options to set (everything tunable for our workload lives
 95:   # in aws_db_parameter_group.mysql), so the default OG is sufficient and
 96:   # cannot be lockup-blocked.
 97:   create_db_option_group = false
 98:   option_group_name      = "default:mysql-8-0"
 99: 
100:   performance_insights_enabled          = true
101:   performance_insights_retention_period = 7
102: 
103:   monitoring_interval    = 60
104:   create_monitoring_role = true
105:   monitoring_role_name   = "${local.name_prefix}-rds-monitoring"
106: 
107:   # Use the parameter group we manage outside the module (above).
108:   parameter_group_name            = aws_db_parameter_group.mysql.name
109:   create_db_parameter_group       = false
110:   enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
111: 
112:   tags = local.common_tags
113: }
114: 
115: # Expose the DB endpoint to user-data via SSM (non-secret).
116: resource "aws_ssm_parameter" "db_endpoint" {
117:   name  = local.ssm_keys.db_endpoint
118:   type  = "String"
119:   value = module.rds.db_instance_address
120: }
121: 
122: resource "aws_ssm_parameter" "db_name" {
123:   name  = local.ssm_keys.db_name
124:   type  = "String"
125:   value = var.db_name
126: }
````
