# Automated Unattended Ubuntu ISO Builder

This project uses **Ansible** to automatically download, extract, customize, and rebuild an unattended Ubuntu installation ISO.  
It produces a fully automated installation image with predefined user, network, and partition settings.

---

## 📌 Features

- Download the specified Ubuntu ISO automatically  
- Extract ISO contents into a working directory  
- Inject autoinstall configuration (user, network, storage setup)  
- Rebuild a fully unattended ISO  
- Output ready-to-use ISO in `/var/www/html/isos/`  
- Modular design using Ansible roles  

---

## 📁 Playbook Overview

The playbook is executed on the **localhost** with privilege escalation enabled:

- Uses the role: `create_custom_iso_unattended`
- Gathers system facts
- Defines variables for:
  - Distribution flavour/version  
  - Paths for working directory, ISO download, extraction, and output  
  - Network configuration  
  - Default user and password  
  - Boot/swap partition sizes  

---

## 🧰 Variables

| Variable | Description |
|----------|-------------|
| `flavour` | Linux distribution flavour (`ubuntu`) |
| `version` | Ubuntu version (`24.04`) |
| `working_dir` | ISO extraction working directory |
| `iso_download_url` | URL for downloading official Ubuntu ISO |
| `iso_download_dest` | Local download path for ISO |
| `iso_output_path` | Final unattended ISO output path |
| `network_ip` | Static IP for installed OS |
| `default_user` | Username for created default user |
| `default_user_password` | SHA-512 hashed password |
| `default_ssh_public_key` | SSH public key added to autoinstall |
| `boot_size` | Boot partition size |
| `swap_size` | Swap partition size |

---

## ▶️ Running the Playbook

Install Ansible:

```bash
sudo apt install ansible -y
