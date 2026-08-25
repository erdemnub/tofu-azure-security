# Azure Zero-Trust Infrastructure Baseline with OpenTofu

This repository contains Infrastructure as Code (IaC) written in OpenTofu to provision an enterprise-grade, secure, and isolated Azure environment based on Zero Trust principles.

## Architecture Overview

* **Network Segmentation:** Dedicated Virtual Network (`10.0.0.0/16`) and Subnet (`10.0.1.0/24`) architecture.
* **Traffic Hardening:** Network Security Group (NSG) configured with explicit `DenyAllInbound` (Priority 4096) to eliminate unintended perimeter exposure.
* **Key Vault Hardening:** Public access strictly disabled (`public_network_access_enabled = false`), default network rule set to `Deny`, and Azure RBAC authorization enforced.
* **Private Link & DNS Resolution:** Key Vault is completely isolated from the public internet using an Azure **Private Endpoint** and resolved securely via `privatelink.vaultcore.azure.net` Private DNS Zone linked directly to the VNet.

## Project Structure

```text
├── main.tf              # Resource group & base configurations
├── network.tf           # VNet, Subnet, NSG, and Security Rules
├── private_endpoint.tf  # Private DNS Zone, VNet Link, and Private Endpoint
├── variables.tf         # Parameterized inputs and naming conventions
├── .gitignore           # Ignores sensitive state files and provider binaries
└── .terraform.lock.hcl  # Deterministic provider dependency lock

Installation :  we have to register Microsoft's services.

```bash
 az provider register --namespace Microsoft.Web 
az provider register --namespace Microsoft.DBforPostgreSQL
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.ManagedIdentity
```

