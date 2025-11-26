# Copilot Instructions for Custom Unattended ISO Builder

## Project Overview
This Ansible project automates the creation of unattended installation ISOs for Linux distributions (Ubuntu, Debian, Rocky, CentOS, Red Hat). The playbook downloads official distribution ISOs, extracts and modifies them with pre-configured installation settings, and rebuilds fully automated installation media.

## Architecture & Key Components

### Three-Layer Design
1. **Main Playbook** (`create_custom_iso_unattended.yml`): Entry point that:
   - Sets variables for distribution flavor (ubuntu, debian, rocky, centos, redhat)
   - Dynamically constructs download URLs based on flavor and version
   - Routes to role-specific implementations via conditional `include_role`

2. **Role Structure** (`roles/{ubuntu,redhat}_create_custom_iso_unattended/`):
   - **Ubuntu/Debian Role**: Uses cloud-init autoinstall format
   - **RedHat/CentOS/Rocky Role**: Uses Kickstart (anaconda-ks.cfg) format
   - Each role follows standard task organization: `prepwork.yml` → `create_*_iso.yml` → `cleanup.yml`

3. **Configuration Templates**:
   - Ubuntu: Jinja2-templated `autoinstall.yaml` (cloud-init format)
   - RedHat: Jinja2-templated `anaconda-ks.cfg.j2` (Kickstart format)

### Variable Passing Pattern
Variables are injected at role inclusion time via nested `vars:` blocks in main playbook. Critical variables include:
- `flavour`: Distribution type (drives conditional role inclusion)
- `working_dir`: ISO staging directory
- `iso_download_dest`, `iso_output_path`: File paths
- `default_user`, `default_user_password`: Hashed credentials
- `network_ip`, `default_gateway`, `network_cidr`: Static network config
- `boot_size`, `swap_size`: Partition sizing (bytes)

## ISO Creation Workflow

### Prepwork Phase (`prepwork.yml`)
1. Install distribution-specific tools:
   - **Debian**: `isolinux`, `genisoimage`, `xorriso`, `p7zip-full`
   - **Snap**: `ubuntu-image`
2. Check if ISO already cached (avoid re-download)
3. Mount base ISO to `iso_mount_path` (/mnt/iso)
4. Extract ISO using `7z x` to `iso_extract_path`

### ISO Customization (`create_*_iso.yml`)
**Ubuntu Path**:
- Template `autoinstall.yaml` from `roles/ubuntu_create_custom_iso_unattended/templates/`
- Insert grub menu entry for autoinstall boot option via `blockinfile`
- Rebuild ISO using `xorriso` with mkisofs flags

**RedHat Path** (similar structure, different template format)

### Cleanup (`cleanup.yml`)
Removes working artifacts and unmounts ISO (implicit in error handling block)

## Critical Developer Workflows

### Modifying Installation Configuration
- **For Ubuntu**: Edit `roles/ubuntu_create_custom_iso_unattended/templates/autoinstall.yaml`
  - Cloud-init format; storage config uses partition/lvm/format/mount objects
  - Remember to escape Jinja2 variables: `{{ variable_name }}`
  - Network config is netplan-based (version 2)

- **For RedHat**: Edit `roles/redhat_create_custom_iso_unattended/templates/anaconda-ks.cfg.j2`
  - Kickstart format; storage defined via `part`, `volgroup`, `logvol` directives
  - Password must be SHA-512 hashed

### Adding New Distribution Support
1. Create new role: `roles/{flavour}_create_custom_iso_unattended/`
2. Copy task structure from existing role (prepwork/create/cleanup)
3. Implement role-specific template in `templates/`
4. Add conditional role inclusion in `create_custom_iso_unattended.yml` with when clause
5. Add download URL pattern to main playbook's `set_fact` task

### Running Locally
```bash
# Install Ansible
sudo apt install ansible

# Run playbook (requires sudo for mount operations)
ansible-playbook create_custom_iso_unattended.yml
```

## Project-Specific Patterns & Conventions

### Error Handling
- All roles wrapped in `block/rescue` pattern
- Prepwork success checked via `when: prepwork is succeeded`
- Cleanup always executes on failure (rescue block)

### Password Hashing
- Passwords pre-hashed as SHA-512 (e.g., in vars block)
- Ubuntu uses `default_user_password` directly
- RedHat has separate `rootpw` and `user` passwords

### Partition Sizing Convention
- Sizes specified in bytes with 'B' suffix (e.g., `2147483648B` = 2GB)
- Ubuntu uses LVM (logical volumes: lv-boot, lv-swap, lv-root)
- RedHat uses simpler partition scheme with separate boot partition

### Grub Menu Entry Injection
- Ubuntu only: `blockinfile` inserts autoinstall entry before default menuentry
- Entry references `/autoinstall.yaml` in extracted ISO root via `ds=nocloud;s=` parameter

## External Dependencies

### Package Requirements (`requirements.txt`)
- Ansible 2.13+ (core 2.20+) with Jinja2 for templating
- Yamllint 1.37+ for YAML validation
- PyYAML 6.0+ for parsing

### System Requirements
- Must run with `become: yes` (sudo) for mount operations
- Requires: `xorriso`, `genisoimage`, `7zip`, Apache2 for output serving
- Uses `ansible_facts['os_family']` to branch Debian-specific installs

## Integration Points

- **Input**: Official distribution ISO URLs (Ubuntu, Rocky, etc.)
- **Output**: `/var/www/html/isos/` directory (Apache-served for VM provisioning)
- **SSH Key**: Injected via template variables for passwordless access
- **Network**: Static IP configuration in cloud-init/kickstart templates
