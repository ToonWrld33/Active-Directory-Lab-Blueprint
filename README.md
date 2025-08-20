# 📐 Active-Directory-Lab-Blueprint

Build a **mini enterprise IT environment** using **VirtualBox**, perfect for learning and practicing Active Directory, DNS, DHCP, and Group Policy.  
This lab is fully documented with **110+ screenshots** and clear step-by-step instructions — designed to be beginner-friendly with **no prior AD experience required**.

---

## 📌 Lab Overview

- 🖥️ **Two virtual machines**:
  - `DC01`: Windows Server 2025 Domain Controller
  - `CLIENT01`: Windows 11 workstation
- 🌐 **Networking**: VirtualBox NAT Network (`AD_HOME_LAB`)
- 🧱 **Domain Setup**: `toonwrld.local`
- 🔐 **Active Directory**: OUs, Users, Groups, delegation, and password resets
- 🧠 **Group Policy** walkthroughs + baseline GPO automation
- ⚡ **PowerShell** scripts to automate common admin tasks

---

## 🛠 Requirements

### 📅 Software Downloads
- 🔗 [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- 🔗 [Windows Server 2025 ISO](https://www.microsoft.com/en-us/evalcenter/) *(Evaluation Center)*
- 🔗 [Windows 11 ISO](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise)

### 💾 System Requirements
- Minimum: **4 GB RAM** (8 GB recommended)
- At least **100 GB free disk space**
- Basic knowledge of Windows and networking

---

## 📘 Project Guides

### 🔧 [Lab Setup Guide](./AD_HOME_LAB.md)
Step-by-step walkthrough to build your AD lab from scratch using **VirtualBox**.  
Includes every step (1–110) with screenshots — from downloads to domain join.

### 🎯 [Active Directory Tasks Walkthrough](./AD_TASKS.md)
Practice real-world administration tasks:  
- Create and manage OUs, users, groups  
- Reset passwords & manage logon attempts  
- Apply and test GPOs  

### ⚡ [PowerShell Scripts](./scripts/)
Practical automation examples:  
- Bulk create OUs, groups, and users from CSV  
- Delegate rights (e.g., Helpdesk reset for Sales)  
- Apply baseline GPOs (wallpaper, logon banner)  
- Export AD state (CSV inventories + GPO reports)  

---

## 📸 Screenshots

All guides include **my own screenshots** from the lab environment in VirtualBox.  
The `toonwrld.local` domain is visible throughout, confirming it’s a hands-on build.

---

## ☕ Support & Contributions

If this repo helps you:

- ⭐ Star it to support the project!  
- 🔧 Open issues for questions or suggestions  
- 📂 Fork and adapt the lab for your own domain  

---

## 📬 Contact

For inquiries or feedback, please open an issue on the [GitHub Issues page](https://github.com/ToonWrld33/Active-Directory-Lab-Blueprint/issues).

---

## 🙋‍♂️ About This Project

This project is focused on helping learners and junior IT professionals practice and understand Active Directory in a lab environment.  

- 🎓 CompTIA **Security+** & **Network+** certified  
- 📂 Building hands-on labs to improve IT & cybersecurity skills  
- 🧰 Passionate about automation, scripting, and creating practical guides  

---

**Blueprint complete. Take this foundation, break things, fix them, and sharpen your skills — that’s how you grow.** 📐 
