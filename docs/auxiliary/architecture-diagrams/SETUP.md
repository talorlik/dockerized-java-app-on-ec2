# ENVIRONMENT SETUP GUIDE

This guide provides detailed, step-by-step instructions for setting up the development environment for the Architecture Diagrams Python project on macOS and Ubuntu Linux.

## PREREQUISITES

- Python 3.7 or higher
- Git (optional, for cloning the repository)
- Terminal/shell access
- VS Code or Cursor IDE (optional, for viewing diagrams in-editor)
- **AWS CLI** (for retrieving role ARNs from Secrets Manager, seeding Parameter Store, and assuming roles)
- **jq** (for parsing the `github-role` secret and Terraform/plan JSON)
- **Terraform** 1.14 or higher (for collecting plan JSON from each layer; see AGENT.md)
- **AWS credentials** (logged in via SSO or with assumed-role credentials in the environment so you can read Secrets Manager and, after assuming the deployment role, run Terraform plan and Parameter Store)

## VERIFY PREREQUISITES

Run these checks before collecting Terraform JSON or generating diagrams. Fix any failures before proceeding.

### Check AWS CLI

```bash
command -v aws || { echo "ERROR: AWS CLI not found. Install it: https://aws.amazon.com/cli/"; exit 1; }
aws --version
```

### Check jq

```bash
command -v jq || { echo "ERROR: jq not found. Install it: macOS: brew install jq; Ubuntu: sudo apt install jq"; exit 1; }
jq --version
```

### Check Terraform

```bash
command -v terraform || { echo "ERROR: Terraform not found. Install Terraform 1.14+: https://developer.hashicorp.com/terraform/install"; exit 1; }
terraform version
```

### Check AWS credentials (SSO or assumed role)

You must have valid AWS credentials so that `aws sts get-caller-identity` succeeds. If you use SSO, run `aws sso login` first (and ensure your profile or environment points to it).

```bash
aws sts get-caller-identity || { echo "ERROR: Not logged in to AWS. Run 'aws sso login' (or configure credentials) and retry."; exit 1; }
```

Optional: print the current identity to confirm which account/role you are using:

```bash
aws sts get-caller-identity --query 'Arn' --output text
```

### Check Python and Graphviz

```bash
command -v python3 || { echo "ERROR: python3 not found."; exit 1; }
python3 --version

command -v dot || { echo "ERROR: Graphviz (dot) not found. Install graphviz for your OS."; exit 1; }
dot -V
```

## MACOS SETUP

### STEP 1: INSTALL HOMEBREW (IF NOT ALREADY INSTALLED)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, follow any additional instructions to add Homebrew to your PATH.

### STEP 2: INSTALL PYTHON 3

```bash
# Check if Python 3 is installed
python3 --version

# If not installed or version is too old, install via Homebrew
brew install python3
```

### STEP 3: INSTALL GRAPHVIZ SYSTEM DEPENDENCY

GraphViz is required for rendering diagrams and must be installed at the system level before installing Python packages.

```bash
brew install graphviz

# Verify installation
which dot
dot -V
```

You should see output showing the GraphViz version (e.g., `dot - graphviz version 2.50.0`).

### STEP 4: NAVIGATE TO PROJECT DIRECTORY

```bash
cd /Users/talo/www/dockerized-java-app-on-ec2/docs/auxiliary/architecture-diagrams
```

### STEP 5: CREATE PYTHON VIRTUAL ENVIRONMENT

```bash
python3 -m venv venv
```

This creates a `venv` directory containing an isolated Python environment.

### STEP 6: ACTIVATE VIRTUAL ENVIRONMENT

```bash
source venv/bin/activate
```

Your prompt should now show `(venv)` prefix, indicating the virtual environment is active.

### STEP 7: INSTALL PYGRAPHVIZ WITH EXPLICIT PATHS

**Critical Step for macOS**: pygraphviz requires explicit paths to Homebrew's GraphViz installation. Run this command exactly as shown:

```bash
pip install --config-settings="--global-option=build_ext" \
  --config-settings="--global-option=-I$(brew --prefix graphviz)/include/" \
  --config-settings="--global-option=-L$(brew --prefix graphviz)/lib/" \
  pygraphviz
```

This tells pip where to find GraphViz header files and libraries that Homebrew installed.

### STEP 8: INSTALL REMAINING PYTHON PACKAGES

```bash
pip install diagrams graphviz graphviz2drawio
```

**Note**: Additional dependencies (`puremagic`, `svg.path`, `jinja2`, etc.) are installed automatically.

### STEP 9: VERIFY INSTALLATION

```bash
# Check installed packages
pip list

# You should see:
# - diagrams
# - graphviz
# - graphviz2drawio
# - pygraphviz
# (plus their dependencies: jinja2, puremagic, svg.path, pre-commit, etc.)

# Test by running an example diagram
python contoso_architecture.py
```

If successful, you'll find generated files in the `diagrams/` subdirectory.

## UBUNTU SETUP

### STEP 1: UPDATE PACKAGE MANAGER

```bash
sudo apt update
sudo apt upgrade -y
```

### STEP 2: INSTALL PYTHON 3 AND DEVELOPMENT TOOLS

```bash
# Install Python 3, pip, and venv
sudo apt install -y python3 python3-pip python3-venv

# Install build essentials (required for compiling pygraphviz)
sudo apt install -y build-essential

# Verify Python installation
python3 --version
```

### STEP 3: INSTALL GRAPHVIZ SYSTEM DEPENDENCIES

GraphViz and its development files are required for both rendering and building pygraphviz.

```bash
# Install GraphViz and development headers
sudo apt install -y graphviz libgraphviz-dev pkg-config

# Verify installation
which dot
dot -V
```

### STEP 4: NAVIGATE TO PROJECT DIRECTORY

```bash
cd /Users/talo/www/dockerized-java-app-on-ec2/docs/auxiliary/architecture-diagrams
```

### STEP 5: CREATE PYTHON VIRTUAL ENVIRONMENT

```bash
python3 -m venv venv
```

### STEP 6: ACTIVATE VIRTUAL ENVIRONMENT

```bash
source venv/bin/activate
```

Your prompt should now show `(venv)` prefix.

### STEP 7: UPGRADE PIP, SETUPTOOLS, AND WHEEL

```bash
pip install --upgrade pip setuptools wheel
```

This ensures compatibility with modern package building.

### STEP 8: INSTALL PYGRAPHVIZ

On Ubuntu, pygraphviz usually finds the GraphViz libraries automatically if `libgraphviz-dev` is installed:

```bash
pip install pygraphviz
```

**If you encounter errors**, try with explicit paths:

```bash
pip install --global-option=build_ext \
  --global-option="-I/usr/include/graphviz" \
  --global-option="-L/usr/lib/graphviz/" \
  pygraphviz
```

### STEP 9: INSTALL REMAINING PYTHON PACKAGES

```bash
pip install diagrams graphviz graphviz2drawio
```

**Note**: Additional dependencies (`puremagic`, `svg.path`, `jinja2`, etc.) are installed automatically.

### STEP 10: VERIFY INSTALLATION

```bash
# Check installed packages
pip list

# Test by running an example diagram
python contoso_architecture.py
```

Generated files will appear in the `diagrams/` subdirectory.

## IDE SETUP (VS CODE / CURSOR)

To view and edit diagrams directly within your IDE, install the Draw.io extension.

### OPTION 1: INSTALL VIA GUI

1. Open VS Code or Cursor
2. Click on the Extensions icon in the sidebar (or press `Cmd+Shift+X` on macOS / `Ctrl+Shift+X` on Ubuntu)
3. Search for "Draw.io Integration"
4. Click **Install** on the extension by "hediet.vscode-drawio"
5. Restart the editor if prompted

### OPTION 2: INSTALL VIA COMMAND LINE

**VS Code:**

```bash
code --install-extension hediet.vscode-drawio
```

**Cursor:**

```bash
cursor --install-extension hediet.vscode-drawio
```

### USING THE EXTENSION

Once installed, you can:

1. **View `.drawio` files**: Simply click on any `.drawio` file in the file explorer to open it in the Draw.io editor within your IDE
2. **Edit diagrams**: The extension provides a full graphical editor with drag-and-drop capabilities
3. **Export**: Right-click on an open diagram and select export options (PNG, SVG, PDF)
4. **Preview PNG files**: PNG diagrams can be viewed directly in the editor by clicking on them

### VIEWING DIAGRAMS IN THE IDE

After generating diagrams with your Python scripts, you can view them in multiple ways:

- **PNG files**: Click to preview in the editor
- **`.drawio` files**: Click to open in the Draw.io editor for editing
- **Split view**: Open both the Python script and the generated diagram side-by-side for quick iteration

### ALTERNATIVE EXTENSIONS

You may also want to consider:

- **"Graphviz Preview"** (joaompinto.vscode-graphviz): For previewing `.dot` files directly

  ```bash
  code --install-extension joaompinto.vscode-graphviz
  # or
  cursor --install-extension joaompinto.vscode-graphviz
  ```

- **"Image preview"**: Built into VS Code/Cursor - no installation needed for PNG viewing

## USING AI ASSISTANTS (COPILOT / CURSOR AGENT)

Once your environment is set up, you can use AI coding assistants to help generate diagram scripts. Here are two sample prompts to get you started:

### SAMPLE PROMPT 1: THREE-TIER WEB APPLICATION

```text
Create a Python script using the diagrams library to generate an AWS architecture diagram for a three-tier web application with the following components:

1. Frontend tier:
  - CloudFront for global content delivery
  - Application Load Balancer (ALB) in a public subnet
  - Background color: light blue (#E3F2FD)

2. Application tier:
  - 2 EC2 instances in an Auto Scaling group within private app subnet
  - Lambda as an alternative serverless compute option
  - Background color: light purple (#F3E5F5)

3. Data tier:
  - RDS (PostgreSQL/MySQL) with read replica
  - S3 bucket for object storage
  - Background color: light orange (#FFF3E0)

4. Security and monitoring:
  - AWS Secrets Manager for secrets management
  - Connection from EC2 to Secrets Manager (dotted line labeled "Secrets")
  - CloudWatch connected to all tiers (dotted green lines)

Requirements:
- Use orthogonal splines for clean lines
- Generate PNG, DOT, and convert to DRAWIO format
- Save output to diagrams/three_tier_web_app
- Group related resources in clusters with appropriate styling
- Add meaningful edge labels (HTTPS, SQL, etc.)
```

### SAMPLE PROMPT 2: PARSE TERRAFORM IAC TEMPLATE

```text
Create a Python script that parses Terraform configuration files and automatically generates an AWS architecture diagram. The script should:

1. Read all .tf files in the directory
2. Extract AWS resources using regex patterns:
  - Match: resource "aws_*" "resource_name"
  - Capture the resource type and name
3. Map Terraform resource types to appropriate diagrams library icons:
  - aws_vpc → VPC
  - aws_subnet → subnet within VPC cluster
  - aws_instance → EC2
  - aws_eip → ElasticIP
  - aws_security_group → SecurityGroup
  - aws_s3_bucket → S3
  - aws_db_instance → RDS
  - aws_rds_cluster → Aurora
4. Detect relationships:
  - Parse depends_on attributes
  - Find resource references (e.g., "${aws_subnet.example.id}")
5. Create logical grouping:
  - Group subnets within VPC clusters
  - Use background colors to distinguish tiers
6. Generate output as PNG, DOT, and DRAWIO formats
7. Use orthogonal layout with proper spacing (nodesep=0.8, ranksep=1.2)

Save the output to diagrams/terraform_parsed_architecture.
```

### TIPS FOR EFFECTIVE PROMPTS

1. **Be specific about components**: List exact Azure services you want included
2. **Specify layout preferences**: Mention orthogonal lines, spacing, direction (TB/LR)
3. **Include styling requirements**: Background colors, edge styles, labels
4. **Define grouping logic**: Clusters, tiers, subnets
5. **Request multiple output formats**: PNG, DOT, DRAWIO
6. **For IaC parsing**: Specify the template location and parsing strategy
7. **Reference AGENTS.md**: Ask the AI to follow patterns documented in AGENTS.md for consistency

### EXAMPLE WORKFLOW WITH AI ASSISTANT

1. **Start with a prompt** (like the examples above)
2. **Review generated script**: Check imports, icon names (case-sensitive!), and structure
3. **Run the script**: `python your_diagram_script.py`
4. **Check for errors**: Fix any import errors or missing icons
5. **View results**: Open the `.drawio` file in VS Code/Cursor to see the editable version
6. **Iterate**: Ask the AI to adjust colors, layout, or add missing components
7. **Manual refinement**: Use the Draw.io editor for final polish

## COMMON ISSUES AND TROUBLESHOOTING

### ISSUE: "EXECUTABLENOTFOUND: FAILED TO EXECUTE 'DOT'"

**Cause**: GraphViz is not installed or not in PATH.

**Solution**:

- **macOS**: Run `brew install graphviz`
- **Ubuntu**: Run `sudo apt install graphviz`

Verify with `which dot` and `dot -V`.

### ISSUE: "FATAL ERROR: 'GRAPHVIZ/CGRAPH.H' FILE NOT FOUND" (MACOS)

**Cause**: pygraphviz cannot find GraphViz header files installed by Homebrew.

**Solution**: Use the explicit path installation command from Step 7 of the macOS setup.

### ISSUE: PYGRAPHVIZ BUILD FAILURE ON UBUNTU

**Cause**: Missing development headers.

**Solution**:

```bash
sudo apt install -y libgraphviz-dev pkg-config build-essential
pip install pygraphviz
```

### ISSUE: "IMPORTERROR: NO MODULE NAMED DIAGRAMS"

**Cause**: Virtual environment is not activated or packages not installed.

**Solution**:

```bash
source venv/bin/activate
pip install diagrams graphviz graphviz2drawio
```

### ISSUE: PERMISSION DENIED ERRORS

**Cause**: Trying to install packages globally without sudo.

**Solution**: Always use a virtual environment. Never use `sudo pip`.

### ISSUE: DRAW.IO EXTENSION NOT OPENING `.DRAWIO` FILES

**Cause**: File association not configured or extension not enabled.

**Solution**:

1. Right-click the `.drawio` file
2. Select "Open With..."
3. Choose "Draw.io Editor"
4. Check "Configure file association for '.drawio'"

### ISSUE: AI-GENERATED SCRIPT HAS INCORRECT ICON NAMES

**Cause**: Icon class names in the diagrams library are case-sensitive and may not match intuition.

**Solution**: Verify available icons:

```python
from diagrams.aws import compute, network, database
print(dir(compute))
print(dir(network))
print(dir(database))
```

Common mistakes:

- ❌ `Ec2` → ✅ `EC2`
- ❌ `Rds` → ✅ `RDS`
- ❌ `S3Bucket` → ✅ `S3`

## DEACTIVATING THE VIRTUAL ENVIRONMENT

When you're done working:

```bash
deactivate
```

This returns you to your system's default Python environment.

## REACTIVATING FOR FUTURE WORK

Each time you return to work on the project:

```bash
cd /path/to/Architecture_Diagrams_Python_AI/Arch_Diagrams
source venv/bin/activate
```

## TESTING YOUR SETUP

Create a minimal test script to verify everything works:

```python
# test_setup.py
from diagrams import Diagram, Cluster
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC

with Diagram("Test Setup", filename="diagrams/test", outformat=["png", "dot"], show=False):
  with Cluster("VPC"):
      vpc = VPC("vpc")
      vm = EC2("test-vm")
      vpc >> vm

print("✓ Diagram generation successful!")

# Test draw.io conversion
import subprocess
subprocess.run(["graphviz2drawio", "diagrams/test.dot", "-o", "diagrams/test.drawio"], check=True)
print("✓ Draw.io conversion successful!")
```

Run the test:

```bash
python test_setup.py
```

If both checkmarks appear and files are created in `diagrams/`, your environment is correctly configured.

Then open `diagrams/test.drawio` in VS Code/Cursor to verify the IDE extension works.

## SUMMARY OF REQUIRED PACKAGES

### SYSTEM LEVEL

- **macOS**: `graphviz` (via Homebrew)
- **Ubuntu**: `graphviz`, `libgraphviz-dev`, `pkg-config`, `build-essential`

### PYTHON (VIA PIP)

**Core packages to install:**

- `pygraphviz` (requires special installation on macOS)
- `diagrams`
- `graphviz` (Python bindings)
- `graphviz2drawio`

**Auto-installed dependencies:**

- `jinja2`, `MarkupSafe` (required by diagrams)
- `puremagic`, `svg.path` (required by graphviz2drawio)
- `pre-commit` and its dependencies (required by diagrams)

### OPTIONAL: AWS ARCHITECTURE DIAGRAMS

The `diagrams` library includes built-in support for AWS resources. No additional packages are needed-simply import from `diagrams.aws.*` in your scripts.

For CloudFormation template parsing: `boto3`, `troposphere`

### IDE EXTENSIONS (OPTIONAL BUT RECOMMENDED)

- **Draw.io Integration** (hediet.vscode-drawio) - for editing `.drawio` files
- **Graphviz Preview** (joaompinto.vscode-graphviz) - for previewing `.dot` files
