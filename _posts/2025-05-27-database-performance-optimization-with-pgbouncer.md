---
layout: post
title: "Database Performance Optimization with PgBouncer: Connection Pooling Implementation"
categories:
  - database
  - performance
  - infrastructure
tags:
  - postgresql
  - pgbouncer
  - connection pooling
  - database optimization
  - performance engineering
---

In modern applications, database connections are often one of the first performance bottlenecks you'll encounter. Each connection to your PostgreSQL database consumes memory and CPU resources, and creating new connections is costly. As your application scales, poorly managed database connections can degrade performance or even crash your database entirely. This is where connection pooling comes in..
<!--more-->

PgBouncer is a lightweight connection pooler for PostgreSQL that can dramatically improve your application's performance and scalability by efficiently managing database connections. In this article, I'll walk you through why connection pooling matters and how to implement PgBouncer in your infrastructure.. 

## The Problem: Database Connection Overload

Before diving into PgBouncer, let's understand the problems it solves:

### The Cost of Database Connections

Each PostgreSQL connection:
- Consumes ~2-10MB of memory, depending on configuration
- Requires a server process (using CPU resources)
- Takes time to establish (SSL handshake, authentication)
- Counts against `max_connections` (typically 100-300 in most setups)

### Common Connection Anti-patterns

1. **Connection per Request**: Creating a new database connection for each HTTP request
2. **Connection Leaks**: Failing to properly close connections
3. **Fixed-size Application Pools**: Setting large connection pools in each application instance
4. **Connection Spikes**: Sudden bursts of connection requests during traffic spikes

When your application has multiple instances, each with its own connection pool, the total number of connections can quickly exceed the database's capacity, leading to errors like:

```
FATAL: sorry, too many clients already
```

## Enter PgBouncer

PgBouncer sits between your application and your PostgreSQL database, maintaining a pool of connections that are reused across client requests. It provides:

- **Connection Pooling**: Reuse existing connections rather than creating new ones
- **Connection Queuing**: Queue connection requests when all pooled connections are in use
- **Pool Modes**: Different pooling strategies for different use cases
- **Lightweight Design**: Minimal memory footprint and low CPU usage

## Setting Up PgBouncer with Docker

Let's implement PgBouncer using Docker:

### 1. Create a Configuration Directory

```bash
mkdir -p ~/pgbouncer-demo/config
```

### 2. Create a PgBouncer Configuration File

```bash
cat > ~/pgbouncer-demo/config/pgbouncer.ini << EOF
[databases]
* = host=postgres port=5432

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 20
min_pool_size = 10
reserve_pool_size = 5
reserve_pool_timeout = 5
max_db_connections = 50
max_user_connections = 50
server_reset_query = DISCARD ALL
server_check_delay = 30
server_check_query = SELECT 1
server_idle_timeout = 600
EOF
```

### 3. Create a User Authentication File

```bash
cat > ~/pgbouncer-demo/config/userlist.txt << EOF
"postgres" "md5$(echo -n 'postgrespostgres' | md5sum | cut -d ' ' -f 1)"
EOF
```

### 4. Start PostgreSQL for Testing

```bash
docker run --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -d postgres:13
```

### 5. Start PgBouncer Container

```bash
docker run --name pgbouncer \
  --link postgres:postgres \
  -p 6432:6432 \
  -v ~/pgbouncer-demo/config/pgbouncer.ini:/etc/pgbouncer/pgbouncer.ini \
  -v ~/pgbouncer-demo/config/userlist.txt:/etc/pgbouncer/userlist.txt \
  -d edoburu/pgbouncer
```

### 6. Test the Connection

```bash
psql -h localhost -p 6432 -U postgres postgres
```

You're now connecting to PostgreSQL through PgBouncer!

## PgBouncer Pooling Modes Explained

PgBouncer offers three pooling modes, each suitable for different use cases:

### 1. Session Pooling (default)

```ini
pool_mode = session
```

In this mode, a client connection is assigned a server connection for the entire duration of the client session. This mode is the safest but least efficient for connection reuse.

**Best for**: Applications that rely on session state, prepared statements, or temporary tables.

### 2. Transaction Pooling

```ini
pool_mode = transaction
```

In this mode, a client is assigned a server connection only for the duration of a transaction. This dramatically increases connection reuse efficiency.

**Best for**: Most modern web applications and APIs that use short transactions.

**Limitations**: Cannot use prepared statements, session-level advisory locks, or other session-based features across transactions.

### 3. Statement Pooling

```ini
pool_mode = statement
```

In this mode, a server connection is assigned to a client for the duration of a single statement. This provides maximum connection reuse but is the most restrictive.

**Best for**: Specific high-throughput scenarios with simple queries.

**Limitations**: Multi-statement transactions are not supported.

## Performance Comparison

Let's see the impact of PgBouncer with a simple benchmarking example using `pgbench`:

### Without PgBouncer:

```bash
pgbench -h localhost -p 5432 -U postgres -c 50 -j 50 -t 1000 postgres
```

### With PgBouncer:

```bash
pgbench -h localhost -p 6432 -U postgres -c 50 -j 50 -t 1000 postgres
```

In typical scenarios, you might see:
- 20-40% higher throughput for simple queries
- 80-90% reduction in connection time
- Significantly lower PostgreSQL resource usage under load
- Ability to handle 5-10x more concurrent clients

## Monitoring PgBouncer

To ensure optimal performance, you should monitor PgBouncer's operation:

### 1. Show Active Connections

Connect to PgBouncer's admin console:

```bash
psql -h localhost -p 6432 -U postgres pgbouncer
```

View the current connection status:

```sql
SHOW POOLS;
```

This returns details about active connection pools:

```
database  |  user  | cl_active | cl_waiting | sv_active | sv_idle | sv_used | sv_tested | sv_login | maxwait | maxwait_us | pool_mode 
----------+--------+-----------+------------+-----------+---------+---------+-----------+----------+---------+------------+-----------
postgres  | postgres |        1 |          0 |         1 |       9 |       0 |         0 |        0 |       0 |          0 | transaction
```

### 2. Show Connection Statistics

```sql
SHOW STATS;
```

### 3. Configure for Prometheus Monitoring

For production environments, you can use tools like `pgbouncer_exporter` to send metrics to Prometheus:

```bash
docker run --name pgbouncer-exporter \
  -p 9127:9127 \
  -e DATA_SOURCE_NAME="postgresql://postgres:postgres@pgbouncer:6432/pgbouncer?sslmode=disable" \
  -d prometheuscommunity/pgbouncer-exporter
```

## PgBouncer in Production

For a production setup, consider these additional configurations:

### High Availability Setup

For high availability, run multiple PgBouncer instances behind a load balancer:

```bash
docker-compose up -d --scale pgbouncer=3
```

### Setting Connection Pool Size

The optimal connection pool size depends on your workload, but a good starting point is:

```
default_pool_size = (max_connections × 0.8) ÷ (number_of_pgbouncer_instances × expected_number_of_databases)
```

For example, with a PostgreSQL `max_connections` of 100, two PgBouncer instances, and one database:

```
default_pool_size = (100 × 0.8) ÷ (2 × 1) = 40
```

### Connection Queuing

PgBouncer can queue connection requests when all pooled connections are in use:

```ini
max_client_conn = 3000
default_pool_size = 40
```

This allows up to 3000 client connections, but only 40 actual connections to PostgreSQL per pool.

## Implementing PgBouncer with Node.js

Here's how to use PgBouncer with a Node.js application:

```javascript
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 6432,           // PgBouncer port instead of 5432
  user: 'postgres',
  password: 'postgres',
  database: 'postgres',
  max: 10,              // Client pool size can be smaller with PgBouncer
  idleTimeoutMillis: 30000
});

async function query(text, params) {
  const client = await pool.connect();
  try {
    return await client.query(text, params);
  } finally {
    client.release(); // Always release the client back to the pool
  }
}

async function testConnection() {
  for (let i = 0; i < 100; i++) {
    const result = await query('SELECT NOW()');
    console.log(`Query ${i+1}: ${result.rows[0].now}`);
  }
}

testConnection().catch(e => console.error(e));
```

## Python with PgBouncer

For Python applications, update your connection string:

```python
import psycopg2
import time

def test_connection():
    for i in range(100):
        # Connect through PgBouncer
        conn = psycopg2.connect(
            host="localhost",
            port="6432",  # PgBouncer port
            database="postgres",
            user="postgres",
            password="postgres"
        )
        cursor = conn.cursor()
        cursor.execute("SELECT NOW()")
        result = cursor.fetchone()
        print(f"Query {i+1}: {result[0]}")
        cursor.close()
        conn.close()  # This returns the connection to PgBouncer's pool

test_connection()
```

## Common Pitfalls and Solutions

### 1. Prepared Statements in Transaction Pooling Mode

**Symptom**: Errors like `prepared statement "p1" does not exist`

**Solution**: Either use session pooling mode or disable prepared statements in your client:

```javascript
// Node.js example
const pool = new Pool({
  host: 'localhost',
  port: 6432,
  // ...other options
  prepared_statements: false  // Disable prepared statements
});
```

### 2. Connection Timeout Issues

**Symptom**: `remaining connection slots are reserved for non-replication superuser connections`

**Solution**: Adjust your reserve pool settings:

```ini
reserve_pool_size = 10
reserve_pool_timeout = 5
```

### 3. Not Closing Connections Properly

**Symptom**: Growing number of connections in `cl_active` but few in `sv_active`

**Solution**: Ensure your application code properly closes connections after use.

## Case Study: Scaling a High-Traffic API

One of my clients was experiencing database connection issues with their API, which handled ~1,000 requests per second at peak. Each API server maintained its own connection pool of 20 connections. With 10 API servers, they were using 200 PostgreSQL connections, approaching their `max_connections` limit of 300.

After implementing PgBouncer:
- Each API server's connection pool was reduced to 5 connections
- PgBouncer maintained a pool of 50 connections to the database
- Total connections decreased from 200 to 50
- Response time improved by 23%
- Database CPU usage decreased by 30%
- They could scale to 30 API servers without increasing database connections

## Beyond PgBouncer: Additional Performance Optimizations

While PgBouncer addresses connection management, consider these additional optimizations:

1. **Statement Timeout**: Prevent long-running queries from impacting performance
   ```ini
   statement_timeout = 30000  # 30 seconds
   ```

2. **Query Optimization**: Use `EXPLAIN ANALYZE` to identify slow queries

3. **Connection Limiting Per User/Database**: Set specific limits for different applications
   ```ini
   max_user_connections = 50
   ```

4. **Server-side Statement Caching**: Enable PostgreSQL's prepared statement cache
   ```ini
   server_prepare = auto
   ```

## Conclusion

PgBouncer offers a lightweight yet powerful solution to PostgreSQL connection management. By implementing connection pooling, you can:

- Significantly increase the number of clients your database can handle
- Reduce connection overhead and latency
- Maintain stable performance during traffic spikes
- Scale your application horizontally without scaling database connections

While it requires some initial configuration, the performance benefits make it well worth the effort for any production PostgreSQL deployment. PgBouncer has become an essential component in my database optimization toolkit, especially for high-traffic applications.

How are you currently managing your database connections? Have you implemented connection pooling in your infrastructure? Share your experiences in the comments!

---

*For more on database optimization, check out my other articles on performance engineering and infrastructure best practices.*
