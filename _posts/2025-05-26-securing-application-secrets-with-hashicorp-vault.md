---
layout: post
title: "Securing Application Secrets with HashiCorp Vault: Implementation Guide"
categories:
  - security
  - infrastructure
tags:
  - vault
  - hashicorp
  - secrets management
  - devsecops
  - security
---

In today's infrastructure landscape, applications rely on numerous secrets: API keys, database credentials, encryption keys, and more. Hardcoding these secrets into your codebase is not just a security risk—it's a maintenance nightmare. When credentials need rotation, you'll find yourself updating code across multiple services and redeploying everything. This is where a dedicated secrets management solution becomes essential.
<!--more-->
HashiCorp Vault is an industry-standard tool that solves this problem by centralizing secret management with strong access controls. In this guide, I'll walk you through implementing Vault in your infrastructure, from basic setup to advanced configurations.

## The Problem with Traditional Secret Management

Before diving into Vault, let's understand the common anti-patterns for secrets management:

1. **Hardcoded Secrets**: Embedding credentials directly in code
2. **Environment Variables**: Better than hardcoding, but difficult to rotate and often leaked in logs
3. **Configuration Files**: Frequently committed to source control by accident
4. **Shared Password Managers**: Not designed for application usage
5. **Cloud Provider Solutions**: Create vendor lock-in

All these approaches have security weaknesses and operational limitations. Let's explore how Vault solves these problems.

### Vault and the 12-Factor App Methodology

You might be wondering: "Doesn't the 12-Factor App methodology recommend using environment variables for configuration? Is Vault contradicting that principle?"

The 12-Factor App's third principle ("Config") suggests storing configuration in the environment. This remains sound advice for most configuration parameters, but when it comes to sensitive credentials, there are additional security considerations.

Vault actually complements the 12-Factor methodology rather than contradicting it:

1. **Separation of code and config**: Vault maintains this separation—your code still doesn't contain secrets
2. **Environment-specific settings**: Vault can store different credentials for different environments
3. **Enhanced security**: Vault adds encryption, access controls, rotation, and audit capabilities

The modern best practice is to use:
- Environment variables for non-sensitive configuration (ports, feature flags, etc.)
- Vault for sensitive credentials (API keys, database passwords, etc.)
- Environment variables to configure the Vault connection itself

This approach preserves the spirit of 12-Factor while adding much-needed security controls for sensitive information.

## What is HashiCorp Vault?

Vault is a secrets management tool that provides:

- **Centralized Secret Storage**: A single source of truth for credentials
- **Dynamic Secrets**: Generate short-lived credentials on demand
- **Encryption as a Service**: Encrypt/decrypt data without managing keys
- **Leasing & Renewal**: Automatic credential rotation
- **Audit Trail**: Track who accessed which secrets and when

## Setting Up Vault with Docker

Let's start with a simple Vault implementation using Docker:

### 1. Create a Development Instance

```bash
mkdir -p ~/vault-demo/config
```

Create a configuration file:

```bash
cat > ~/vault-demo/config/vault.json << EOF
{
  "backend": {
    "file": {
      "path": "/vault/file"
    }
  },
  "listener": {
    "tcp": {
      "address": "0.0.0.0:8200",
      "tls_disable": 1
    }
  },
  "ui": true
}
EOF
```

Start Vault with Docker:

```bash
docker run --name vault \
  -p 8200:8200 \
  -v ~/vault-demo/config:/vault/config \
  -v ~/vault-demo/file:/vault/file \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=dev-only-token' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  --cap-add=IPC_LOCK \
  hashicorp/vault:latest
```

### 2. Initialize Vault

For a production setup (unlike our dev mode above), you'll need to initialize the Vault:

```bash
docker exec -it vault vault operator init
```

This command returns unseal keys and a root token. **Store these securely**—they're critical for accessing your Vault.

### 3. Unseal the Vault

For production deployments, you'll need to unseal the Vault after initialization:

```bash
docker exec -it vault vault operator unseal <unseal-key-1>
docker exec -it vault vault operator unseal <unseal-key-2>
docker exec -it vault vault operator unseal <unseal-key-3>
```

### 4. Log In to Vault

```bash
docker exec -it vault vault login
Token (will be hidden): <root-token>
```

You can also access the UI at http://localhost:8200.

## Storing and Retrieving Static Secrets

The simplest use-case is storing static secrets:

### 1. Enable the KV Secrets Engine

```bash
docker exec -it vault vault secrets enable -version=2 kv
```

### 2. Store a Secret

```bash
docker exec -it vault vault kv put kv/database/config username="db_user" password="super_secure_password"
```

### 3. Retrieve the Secret

```bash
docker exec -it vault vault kv get kv/database/config
```

## Accessing Vault from Applications

Let's see how to integrate Vault with a Node.js application:

### Install the Vault Client Library

```bash
npm install node-vault
```

### Create a Simple Application

```javascript
// app.js
const vault = require('node-vault')({
  apiVersion: 'v1',
  endpoint: 'http://localhost:8200',
  token: process.env.VAULT_TOKEN // Never hardcode the token
});

async function getDatabaseCredentials() {
  try {
    const result = await vault.read('kv/data/database/config');
    const { username, password } = result.data.data;
    console.log(`Retrieved credentials - Username: ${username}`);
    return { username, password };
  } catch (error) {
    console.error('Error retrieving secrets:', error.message);
    throw error;
  }
}

// Use the credentials to connect to a database
async function connectToDatabase() {
  const credentials = await getDatabaseCredentials();
  // Use credentials.username and credentials.password to establish connection
  console.log('Database connection established successfully');
}

connectToDatabase();
```

Run your application:

```bash
VAULT_TOKEN=dev-only-token node app.js
```

## Dynamic Secrets: Database Credentials

Static secrets are just the beginning. Vault's real power lies in dynamic secrets – credentials generated on demand and automatically revoked after use.

### 1. Start a PostgreSQL Instance

```bash
docker run --name postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -d postgres:latest
```

### 2. Enable the Database Secrets Engine

```bash
docker exec -it vault vault secrets enable database
```

### 3. Configure the PostgreSQL Connection

```bash
docker exec -it vault vault write database/config/postgresql \
  plugin_name=postgresql-database-plugin \
  allowed_roles="app-role" \
  connection_url="postgresql://postgres:postgres@host.docker.internal:5432/postgres?sslmode=disable" \
  username="postgres" \
  password="postgres"
```

### 4. Create a Role for Dynamic Credentials

```bash
docker exec -it vault vault write database/roles/app-role \
  db_name=postgresql \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
  default_ttl="1h" \
  max_ttl="24h"
```

### 5. Retrieve Dynamic Credentials

```bash
docker exec -it vault vault read database/creds/app-role
```

This returns temporary credentials that Vault will automatically revoke after the TTL expires.

## Implementing in a Node.js Application

Let's update our application to use dynamic credentials:

```javascript
// dynamic-app.js
const vault = require('node-vault')({
  apiVersion: 'v1',
  endpoint: 'http://localhost:8200',
  token: process.env.VAULT_TOKEN
});

const { Client } = require('pg');

async function getDynamicDatabaseCredentials() {
  try {
    const result = await vault.read('database/creds/app-role');
    const { username, password } = result.data;
    console.log(`Got dynamic credentials - Username: ${username}`);
    
    // Store the lease_id for later revocation
    const leaseId = result.lease_id;
    return { username, password, leaseId };
  } catch (error) {
    console.error('Error retrieving dynamic secrets:', error.message);
    throw error;
  }
}

async function connectToDatabase() {
  const credentials = await getDynamicDatabaseCredentials();
  
  const client = new Client({
    host: 'localhost',
    port: 5432,
    database: 'postgres',
    user: credentials.username,
    password: credentials.password
  });

  try {
    await client.connect();
    console.log('Connected to PostgreSQL with dynamic credentials');
    
    // Perform database operations
    const result = await client.query('SELECT current_timestamp');
    console.log('Query result:', result.rows[0]);
    
    await client.end();
    
    // Optional: Revoke credentials early if you're done with them
    // await vault.revoke({ lease_id: credentials.leaseId });
    // console.log('Credentials revoked');
    
  } catch (dbError) {
    console.error('Database error:', dbError);
  }
}

connectToDatabase();
```

## Authentication Methods

So far, we've been using the root token, which isn't suitable for production. Vault offers multiple authentication methods:

### 1. AppRole Authentication

First, enable the AppRole auth method:

```bash
docker exec -it vault vault auth enable approle
```

Create a policy:

```bash
docker exec -it vault bash -c 'cat > /tmp/app-policy.hcl << EOF
path "database/creds/app-role" {
  capabilities = ["read"]
}
path "kv/data/database/config" {
  capabilities = ["read"]
}
EOF'

docker exec -it vault vault policy write app-policy /tmp/app-policy.hcl
```

Create an AppRole:

```bash
docker exec -it vault vault write auth/approle/role/my-app \
  secret_id_ttl=10m \
  token_num_uses=10 \
  token_ttl=20m \
  token_max_ttl=30m \
  secret_id_num_uses=40 \
  policies="app-policy"
```

Get the RoleID:

```bash
docker exec -it vault vault read auth/approle/role/my-app/role-id
```

Generate a SecretID:

```bash
docker exec -it vault vault write -force auth/approle/role/my-app/secret-id
```

### 2. Authenticating with AppRole in Node.js

```javascript
// approle-auth.js
const vault = require('node-vault')({
  apiVersion: 'v1',
  endpoint: 'http://localhost:8200'
});

async function authenticateWithAppRole() {
  const roleId = 'YOUR_ROLE_ID';
  const secretId = 'YOUR_SECRET_ID';
  
  try {
    const result = await vault.approleLogin({
      role_id: roleId,
      secret_id: secretId
    });
    
    // Update token for future requests
    vault.token = result.auth.client_token;
    console.log('Successfully authenticated with AppRole');
    return vault;
  } catch (error) {
    console.error('Authentication failed:', error.message);
    throw error;
  }
}

async function getDatabaseCredentials(authenticatedVault) {
  const result = await authenticatedVault.read('database/creds/app-role');
  return result.data;
}

async function main() {
  try {
    const authenticatedVault = await authenticateWithAppRole();
    const dbCreds = await getDatabaseCredentials(authenticatedVault);
    console.log('Retrieved credentials:', dbCreds.username);
    
    // Use credentials...
    
  } catch (error) {
    console.error('Error in main process:', error);
  }
}

main();
```

## Configuring Production Vault

For production use, consider these essential configs:

### High Availability Setup

Vault supports HA with multiple nodes sharing a storage backend:

```bash
cat > production-config.hcl << EOF
storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/path/to/fullchain.pem"
  tls_key_file  = "/path/to/privkey.pem"
}

api_addr = "https://vault.example.com:8200"
ui = true
EOF
```

### Auto-Unsealing

For production, consider using Vault's auto-unseal feature with cloud KMS:

```bash
# AWS KMS example
seal "awskms" {
  region     = "us-west-2"
  kms_key_id = "alias/vault-unseal-key"
}
```

## Best Practices for Vault in Production

1. **Use TLS**: Always enable TLS for production Vault instances
2. **Auto-Unsealing**: Use cloud provider KMS for auto-unsealing
3. **Audit Logging**: Enable audit logs to track all Vault operations
4. **HA Configuration**: Use a clustered setup for high availability
5. **Backup Strategy**: Regularly backup your Vault data
6. **Least Privilege**: Grant minimal permissions through policies
7. **Token TTLs**: Use short-lived tokens with appropriate TTLs
8. **Certificate Management**: Consider using Vault's PKI secrets engine for certificate management

## Managing the Complexity Trade-off

It's important to acknowledge that implementing Vault introduces additional complexity to your infrastructure:

### Infrastructure Overhead

1. **New Critical System**: Vault becomes a new mission-critical component that must be highly available
2. **Operational Expertise**: Teams need knowledge of Vault configuration and operation
3. **Bootstrapping Challenge**: The "secret zero" problem (how to securely authenticate to Vault initially)
4. **Additional Points of Failure**: Potential unavailability could impact application startup

### Mitigating Strategies

To manage this complexity effectively:

1. **Start Small**: Begin with a single critical service or application before rolling out widely
2. **Caching Mechanisms**: Implement client-side caching with appropriate TTLs to reduce Vault dependency
3. **Fallback Mechanisms**: Design applications with fallback options if Vault is temporarily unreachable
4. **Monitoring and Alerting**: Implement comprehensive monitoring of your Vault instances
5. **Clear Ownership**: Define explicit responsibility for Vault maintenance and operation

### When Vault's Complexity May Not Be Worth It

For some scenarios, the overhead of Vault might exceed its benefits:

- **Small applications** with few secrets and minimal rotation requirements
- **Development environments** where security isn't as critical
- **Simple deployment models** with just one or two services
- **Teams lacking operational capacity** to manage an additional critical service

In these cases, a simpler approach using environment variables with appropriate restrictions might be sufficient.

## Vault Beyond Secret Storage

Vault is more than just a secrets manager. It offers several other useful capabilities:

### Encryption as a Service

Enable the Transit engine for encryption operations without exposing keys:

```bash
docker exec -it vault vault secrets enable transit
docker exec -it vault vault write -f transit/keys/my-encryption-key
```

Encrypt data:

```bash
docker exec -it vault vault write transit/encrypt/my-encryption-key \
  plaintext=$(echo "sensitive data" | base64)
```

Decrypt data:

```bash
docker exec -it vault vault write transit/decrypt/my-encryption-key \
  ciphertext="vault:v1:8SDd3..."
```

### PKI (Public Key Infrastructure)

Vault can act as your own Certificate Authority:

```bash
docker exec -it vault vault secrets enable pki
docker exec -it vault vault secrets tune -max-lease-ttl=87600h pki
```

Generate root CA:

```bash
docker exec -it vault vault write -field=certificate pki/root/generate/internal \
  common_name="example.com" \
  ttl=87600h > root_ca.crt
```

Configure a role:

```bash
docker exec -it vault vault write pki/roles/example-dot-com \
  allowed_domains="example.com" \
  allow_subdomains=true \
  max_ttl="720h"
```

Generate a certificate:

```bash
docker exec -it vault vault write pki/issue/example-dot-com \
  common_name="service.example.com"
```

## Balancing 12-Factor and Security with Vault

In our examples, you might have noticed we're still using environment variables like `VAULT_TOKEN`:

```bash
VAULT_TOKEN=dev-only-token node app.js
```

This demonstrates the balanced approach: we use environment variables for Vault configuration, while Vault itself manages the actual secrets. This hybrid approach gives us:

1. **Simplified deployment**: Environment-specific Vault connections via environment variables
2. **Runtime secret retrieval**: Applications fetch secrets when needed, not at startup
3. **Rotation without restarts**: Credentials can change without requiring application redeployment
4. **Security safeguards**: Centralized access controls, audit logging, and encryption

## Conclusion

HashiCorp Vault transforms how we manage secrets in modern applications by providing a secure, centralized system that addresses many traditional security risks. While the setup may seem complex initially, the security benefits are substantial:

1. **No Hardcoded Secrets**: Applications retrieve credentials at runtime
2. **Automatic Rotation**: Credentials can expire and rotate automatically 
3. **Fine-grained Access Control**: Each service gets only the access it needs
4. **Audit Trail**: Every secret access is logged
5. **Multiple Authentication Methods**: Support for various authentication systems

By implementing Vault in your infrastructure, you not only improve security but also simplify operations. Instead of managing secrets across multiple services and configuration files, you have a central system of record with strong governance controls.

The implementation we've covered here is just the beginning. As your organization grows, Vault can scale with you, providing more advanced features like namespaces for multi-tenancy and sentinel policies for complex access control.

Have you implemented a secrets management solution in your infrastructure? Share your experiences in the comments!
